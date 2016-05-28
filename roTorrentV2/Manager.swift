//
//  Manager.swift
//  roTorrent
//
//  Created by Romain Hild on 18/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class Manager: NSObject, NSCoding {
    
    let urlComponents: NSURLComponents
    var url: NSURL? {
        return urlComponents.URL
    }
    let session = NSURLSession.sharedSession()
    var mutableRequest: NSMutableURLRequest?
    var dataTask: NSURLSessionDataTask?
    
    var torrents = Torrents()
    var torrentsToDisplay = [Torrent]()
    var sortDlIn = SortingOrder.Ascending {
        didSet {
            updateTorrentsToDiplay()
        }
    }
    var sortDlBy = SortingBy.Date {
        didSet {
            updateTorrentsToDiplay()
        }
    }
    var filterDlBy = FilterBy.All {
        didSet {
            updateTorrentsToDiplay()
        }
    }
    
    var feeds = [RSSFeed]()
    var feedToDisplay: RSSFeed? {
        didSet {
            updateItemsToDisplay()
        }
    }
    var itemsToDisplay = [RSSItem]()
    var feedsCount: Int {
        return itemsToDisplay.count
    }
    
    override init() {
        urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        
        feeds = [RSSFeed]()
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        if let host = aDecoder.decodeObjectForKey("host") as? String {
            urlComponents.host = host
        }
        if let user = aDecoder.decodeObjectForKey("user") as? String {
            urlComponents.user = user
        }
        if let password = aDecoder.decodeObjectForKey("password") as? String {
            urlComponents.password = password
        }
        if let path = aDecoder.decodeObjectForKey("path") as? String {
            urlComponents.path = path
        }
        if let feeds = aDecoder.decodeObjectForKey("feeds") as? [RSSFeed] {
            self.feeds = feeds
        }
        if let feedToDisplay = aDecoder.decodeObjectForKey("feedToDisplay") as? RSSFeed {
            self.feedToDisplay = feedToDisplay
        }
        if let sortIn = SortingOrder(rawValue: aDecoder.decodeIntegerForKey("sortDlIn")) {
            self.sortDlIn = sortIn
        }
        if let sortBy = SortingBy(rawValue: aDecoder.decodeIntegerForKey("sortDlBy")) {
            self.sortDlBy = sortBy
        }
        if let filterBy = FilterBy(rawValue: aDecoder.decodeIntegerForKey("filterDlBy")) {
            self.filterDlBy = filterBy
        }
        
        super.init()

        updateFeeds()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let host = urlComponents.host {
            aCoder.encodeObject(host, forKey: "host")
        }
        if let user = urlComponents.user {
            aCoder.encodeObject(user, forKey: "user")
        }
        if let password = urlComponents.password {
            aCoder.encodeObject(password, forKey: "password")
        }
        if let path = urlComponents.path {
            aCoder.encodeObject(path, forKey: "path")
        }
        aCoder.encodeObject(feeds, forKey: "feeds")
        if let feedToDisplay = feedToDisplay {
            aCoder.encodeObject(feedToDisplay, forKey: "feedToDisplay")
        }
        aCoder.encodeInteger(sortDlIn.rawValue, forKey: "sortDlIn")
        aCoder.encodeInteger(sortDlBy.rawValue, forKey: "sortDlBy")
        aCoder.encodeInteger(filterDlBy.rawValue, forKey: "filterDlBy")
    }
    
    func call(call: RTorrentCall, completionHandler: Response<XMLRPCType,NSError> -> Void) {
        if let task = dataTask {
            task.cancel()
        }
        initPostRequestWithCall(call )
        if let mutableRequest = mutableRequest {
            dataTask = session.dataTaskWithRequest(mutableRequest) {
                data, response, error in
                guard error == nil else {
                    completionHandler(Response.Failure(error!))
                    return
                }
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    guard httpResponse.statusCode == 200 else {
                        let ui = [NSLocalizedDescriptionKey: "Network Error!\nPlease try again or check the settings."]
                        let e = NSError(domain: "Request", code: 1, userInfo: ui)
                        completionHandler(.Failure(e))
                        return
                    }
                    if let data = data {
                        switch call {
                        case .MethodSignature, .MethodHelp, .AddTorrentRaw, .State:
                            print(String(data: data, encoding: NSUTF8StringEncoding))
                        default:
                            break
                        }
                        let parser = XMLRPCParser(data: data)
                        let success = parser.parse()
                        if success {
                            completionHandler(.Success(parser.result))
                            return
                        } else {
                            let ui = [NSLocalizedDescriptionKey: "Data corrupted!\nPlease try again."]
                            let e = NSError(domain: "Request", code: 2, userInfo: ui)
                            completionHandler(.Failure(e))
                            return
                        }
                    } else {
                        let ui = [NSLocalizedDescriptionKey: "Data not found!\nPlease try again."]
                        let e = NSError(domain: "Request", code: 3, userInfo: ui)
                        completionHandler(.Failure(e))
                        return
                    }
                } else {
                    let ui = [NSLocalizedDescriptionKey: "Network Error!\n Please try again or check the settings."]
                    let e = NSError(domain: "Request", code: 4, userInfo: ui)
                    completionHandler(.Failure(e))
                    return
                }
            }
            dataTask?.resume()
        } else {
            let ui = [NSLocalizedDescriptionKey: "URL not valid\nPlease check the settings."]
            let e = NSError(domain: "Request", code: 5, userInfo: ui)
            completionHandler(.Failure(e))
        }
    }
    
    func initPostRequestWithCall(call: RTorrentCall) {
        mutableRequest = nil
        let body = call.body
        let bodyData = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let length = body.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        if let host = urlComponents.host where !host.isEmpty, let url = url {
            mutableRequest = NSMutableURLRequest(URL: url)
            mutableRequest!.setValue("text/xml", forHTTPHeaderField: "Content-Type")
            mutableRequest!.setValue("roTorrent", forHTTPHeaderField: "User-Agent")
            mutableRequest!.setValue(String(length), forHTTPHeaderField: "Current-Length")
            mutableRequest!.HTTPBody = bodyData
            mutableRequest!.HTTPMethod = "POST"
        }
    }
    
    func callToInitList(view: String = "main") -> RTorrentCall {
        let list = [RTorrentCall.Filename(""), RTorrentCall.Hash(""), RTorrentCall.Date(""), RTorrentCall.Ratio(""), RTorrentCall.Size(""), RTorrentCall.SizeCompleted(""), RTorrentCall.SizeLeft(""), RTorrentCall.SizeUP(""), RTorrentCall.Path(""), RTorrentCall.Directory(""), RTorrentCall.SpeedDL(""), RTorrentCall.SpeedUP(""), RTorrentCall.Leechers(""), RTorrentCall.Seeders(""), RTorrentCall.State(""), RTorrentCall.IsActive(""), RTorrentCall.Message(""), RTorrentCall.NumberOfFiles(""), RTorrentCall.NumberOfTrackers("")]
        return RTorrentCall.DMultiCall(view, list)
    }
    
    func callToInitFilesForTorrent(torrent: Torrent) -> RTorrentCall {
        let list = [RTorrentCall.FilesName(""), RTorrentCall.FilesSize("")]
        return RTorrentCall.FMultiCall(torrent.hashT, list)
    }
    
    func callToInitTrackersForTorrent(torrent: Torrent) -> RTorrentCall {
        let list = [RTorrentCall.TrackerURL(""), RTorrentCall.TrackerSeeders(""), RTorrentCall.TrackerLeechers("")]
        return RTorrentCall.TMultiCall(torrent.hashT, list)
    }
    func updateItemsToDisplay() {
        if let feedToDisplay = feedToDisplay {
            itemsToDisplay = feedToDisplay.items.sort(<)
        } else {
            itemsToDisplay = feeds.reduce([RSSItem]()){ $0+$1.items }.sort(<)
        }
    }
    
    func updateFeeds() {
        for feed in feeds {
            feed.update()
        }
        updateItemsToDisplay()
    }
    
    func appendRSS(feed: RSSFeed) {
        feeds.append(feed)
        updateItemsToDisplay()
    }
    
    func removeFeed(feed: RSSFeed?) {
        if let feed = feed, index = feeds.indexOf(feed) {
            if feedToDisplay == feed {
                feedToDisplay = nil
            }
            feeds.removeAtIndex(index)
        } else {
            feedToDisplay = nil
            feeds.removeAll()
        }
        updateItemsToDisplay()
    }
    
    func numberOtItemsToDisplay(searchText: String?) -> Int {
        if let searchText = searchText {
            return itemsToDisplay.filter { $0.match(searchText) }.count
        } else {
            return itemsToDisplay.count
        }
    }
    
    func itemToDisplayAtIndexPath(indexPath: NSIndexPath, thatMatch searchText: String?) -> RSSItem {
        if let searchText = searchText {
            return itemsToDisplay.filter { $0.match(searchText) }[indexPath.row]
        } else {
            return itemsToDisplay[indexPath.row]
        }
    }
    
    func updateTorrentsToDiplay() {
        torrentsToDisplay = torrents.filter { $0.isFilterBy(filterDlBy) }
        torrentsToDisplay.sortInPlace { $0.isOrderedBefore($1, by: sortDlBy, inOrder: sortDlIn) }
    }
    
    func numberOfTorrentToDispplay(searchText: String?) -> Int {
        if let searchText = searchText {
            return torrentsToDisplay.filter { $0.match(searchText) }.count
        } else {
            return torrentsToDisplay.count
        }
    }
    
    func torrentAtIndexPath(indexPath: NSIndexPath, searchText: String?) -> Torrent {
        if let searchText = searchText {
            return torrentsToDisplay.filter { $0.match(searchText) }[indexPath.row]
        } else {
            return torrentsToDisplay[indexPath.row]
        }
    }
}

enum Response<SuccessType, FailureType>
{
    case Success(SuccessType)
    case Failure(FailureType)
}

enum SortingOrder: Int {
    case Ascending = 0
    case Descending
    
    static var count: Int { return SortingOrder.Descending.rawValue + 1}
    static func stringOf(index: Int) -> String {
        if let sortOrder = SortingOrder(rawValue: index) {
            switch sortOrder {
            case .Ascending:
                return "Ascending"
            case .Descending:
                return "Descending"
            }
        } else {
            return ""
        }
    }
}

enum SortingBy: Int {
    case Date = 0
    case Name
    case Size
    case Send
    
    static var count: Int { return SortingBy.Send.rawValue + 1}
    static func stringOf(index: Int) -> String {
        if let sortBy = SortingBy(rawValue: index) {
            switch sortBy {
            case .Date:
                return "Date"
            case .Name:
                return "Name"
            case .Size:
                return "Size"
            case .Send:
                return "Send"
            }
        } else {
            return ""
        }
    }
}

enum FilterBy: Int {
    case All = 0
    case Sending
    case Receiving
    case Seeding
    case Leeching
    case Error
    case Pause
    case Stop
    case Active
    
    static var count: Int { return FilterBy.Active.rawValue + 1}
    static func stringOf(index: Int) -> String {
        if let filterBy = FilterBy(rawValue: index) {
            switch filterBy {
            case .All:
                return "All"
            case .Sending:
                return "Sending"
            case .Receiving:
                return "Receiving"
            case .Seeding:
                return "Seeding"
            case .Leeching:
                return "Leeching"
            case .Error:
                return "Error"
            case .Pause:
                return "Pause"
            case .Stop:
                return "Stop"
            case .Active:
                return "Active"
                
            }
        } else {
            return ""
        }
    }
    
}

