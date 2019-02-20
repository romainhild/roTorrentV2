//
//  Manager.swift
//  roTorrent
//
//  Created by Romain Hild on 18/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class Manager: NSObject, NSCoding {
    
    let urlComponents: URLComponents
    var url: URL? {
        return urlComponents.url
    }
    let session = URLSession.shared
    var mutableRequest: NSMutableURLRequest?
    var dataTask: URLSessionDataTask?
    
    var torrents = Torrents()
    var torrentsToDisplay = [Torrent]()
    var sortDlIn = SortingOrder.ascending {
        didSet {
            updateTorrentsToDiplay()
        }
    }
    var sortDlBy = SortingBy.date {
        didSet {
            updateTorrentsToDiplay()
        }
    }
    var filterDlBy = FilterBy.all {
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
        urlComponents = URLComponents()
        urlComponents.scheme = "https"
        
        feeds = [RSSFeed]()
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        urlComponents = URLComponents()
        urlComponents.scheme = "https"
        if let host = aDecoder.decodeObject(forKey: "host") as? String {
            urlComponents.host = host
        }
        if let user = aDecoder.decodeObject(forKey: "user") as? String {
            urlComponents.user = user
        }
        if let password = aDecoder.decodeObject(forKey: "password") as? String {
            urlComponents.password = password
        }
        if let path = aDecoder.decodeObject(forKey: "path") as? String {
            urlComponents.path = path
        }
        if let feeds = aDecoder.decodeObject(forKey: "feeds") as? [RSSFeed] {
            self.feeds = feeds
        }
        if let feedToDisplay = aDecoder.decodeObject(forKey: "feedToDisplay") as? RSSFeed {
            self.feedToDisplay = feedToDisplay
        }
        if let sortIn = SortingOrder(rawValue: aDecoder.decodeInteger(forKey: "sortDlIn")) {
            self.sortDlIn = sortIn
        }
        if let sortBy = SortingBy(rawValue: aDecoder.decodeInteger(forKey: "sortDlBy")) {
            self.sortDlBy = sortBy
        }
        if let filterBy = FilterBy(rawValue: aDecoder.decodeInteger(forKey: "filterDlBy")) {
            self.filterDlBy = filterBy
        }
        
        super.init()

        updateFeeds()
    }
    
    func encode(with aCoder: NSCoder) {
        if let host = urlComponents.host {
            aCoder.encode(host, forKey: "host")
        }
        if let user = urlComponents.user {
            aCoder.encode(user, forKey: "user")
        }
        if let password = urlComponents.password {
            aCoder.encode(password, forKey: "password")
        }
//        if let path = urlComponents.path {
            aCoder.encode(urlComponents.path, forKey: "path")
//        }
        aCoder.encode(feeds, forKey: "feeds")
        if let feedToDisplay = feedToDisplay {
            aCoder.encode(feedToDisplay, forKey: "feedToDisplay")
        }
        aCoder.encode(sortDlIn.rawValue, forKey: "sortDlIn")
        aCoder.encode(sortDlBy.rawValue, forKey: "sortDlBy")
        aCoder.encode(filterDlBy.rawValue, forKey: "filterDlBy")
    }
    
    func call(_ call: RTorrentCall, completionHandler: @escaping (Response<XMLRPCType,NSError>) -> Void) {
        if let task = dataTask {
            task.cancel()
        }
        initPostRequestWithCall(call )
        if let mutableRequest = mutableRequest {
            dataTask = session.dataTask(with: mutableRequest, completionHandler: {
                data, response, error in
                guard error == nil else {
                    completionHandler(Response.failure(error!))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    guard httpResponse.statusCode == 200 else {
                        let ui = [NSLocalizedDescriptionKey: "Network Error!\nPlease try again or check the settings."]
                        let e = NSError(domain: "Request", code: 1, userInfo: ui)
                        completionHandler(.failure(e))
                        return
                    }
                    if let data = data {
                        switch call {
                        case .systemMultiCall, .setDirectory, .moveFile, .execute:
                            print(String(data: data, encoding: String.Encoding.utf8))
                        default:
                            break
                        }
                        let parser = XMLRPCParser(data: data)
                        let success = parser.parse()
                        if success {
                            completionHandler(.success(parser.result))
                            return
                        } else {
                            let ui = [NSLocalizedDescriptionKey: "Data corrupted!\nPlease try again."]
                            let e = NSError(domain: "Request", code: 2, userInfo: ui)
                            completionHandler(.failure(e))
                            return
                        }
                    } else {
                        let ui = [NSLocalizedDescriptionKey: "Data not found!\nPlease try again."]
                        let e = NSError(domain: "Request", code: 3, userInfo: ui)
                        completionHandler(.failure(e))
                        return
                    }
                } else {
                    let ui = [NSLocalizedDescriptionKey: "Network Error!\n Please try again or check the settings."]
                    let e = NSError(domain: "Request", code: 4, userInfo: ui)
                    completionHandler(.failure(e))
                    return
                }
            }) 
            dataTask?.resume()
        } else {
            let ui = [NSLocalizedDescriptionKey: "URL not valid\nPlease check the settings."]
            let e = NSError(domain: "Request", code: 5, userInfo: ui)
            completionHandler(.failure(e))
        }
    }
    
    func initPostRequestWithCall(_ call: RTorrentCall) {
        mutableRequest = nil
        let body = call.body
        let bodyData = body.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let length = body.lengthOfBytes(using: String.Encoding.utf8)
        
        if let host = urlComponents.host, !host.isEmpty, let url = url {
            mutableRequest = NSMutableURLRequest(url: url)
            mutableRequest!.setValue("text/xml", forHTTPHeaderField: "Content-Type")
            mutableRequest!.setValue("roTorrent", forHTTPHeaderField: "User-Agent")
            mutableRequest!.setValue(String(length), forHTTPHeaderField: "Current-Length")
            mutableRequest!.httpBody = bodyData
            mutableRequest!.httpMethod = "POST"
        }
    }
    
    func callToInitList(_ view: String = "main") -> RTorrentCall {
        let list = [RTorrentCall.filename(""), RTorrentCall.hash(""), RTorrentCall.date(""), RTorrentCall.ratio(""), RTorrentCall.size(""), RTorrentCall.sizeCompleted(""), RTorrentCall.sizeLeft(""), RTorrentCall.sizeUP(""), RTorrentCall.path(""), RTorrentCall.directory(""), RTorrentCall.speedDL(""), RTorrentCall.speedUP(""), RTorrentCall.leechers(""), RTorrentCall.seeders(""), RTorrentCall.state(""), RTorrentCall.isActive(""), RTorrentCall.message(""), RTorrentCall.numberOfFiles(""), RTorrentCall.numberOfTrackers("")]
        return RTorrentCall.dMultiCall(view, list)
    }
    
    func callToInitFilesForTorrent(_ torrent: Torrent) -> RTorrentCall {
        let list = [RTorrentCall.filesName(""), RTorrentCall.filesSize("")]
        return RTorrentCall.fMultiCall(torrent.hashT, list)
    }
    
    func callToInitTrackersForTorrent(_ torrent: Torrent) -> RTorrentCall {
        let list = [RTorrentCall.trackerURL(""), RTorrentCall.trackerSeeders(""), RTorrentCall.trackerLeechers("")]
        return RTorrentCall.tMultiCall(torrent.hashT, list)
    }
    
    func callToRefreshState(_ torrent: Torrent) -> RTorrentCall {
        let list = [RTorrentCall.state(torrent.hashT), RTorrentCall.isActive(torrent.hashT), RTorrentCall.message(torrent.hashT)]
        return RTorrentCall.systemMultiCall(list)
    }
    
    func callToMoveTorrent(_ torrent: Torrent, inNewDirectory directory: String) -> RTorrentCall {
        let list = [RTorrentCall.stop(torrent.hashT), RTorrentCall.setDirectory(torrent.hashT, directory), RTorrentCall.moveFile(torrent.path, directory), RTorrentCall.start(torrent.hashT)]
        return RTorrentCall.systemMultiCall(list)
    }
    
    func callTorRefreshDirAndPath(_ torrent: Torrent) -> RTorrentCall {
        let list = [RTorrentCall.directory(torrent.hashT), RTorrentCall.path(torrent.hashT)]
        return RTorrentCall.systemMultiCall(list)
    }
    
    func callToEraseAndDelete(_ torrent: Torrent) -> RTorrentCall {
        let list = [RTorrentCall.deleteFiles(torrent.path), RTorrentCall.erase(torrent.hashT)]
        return RTorrentCall.systemMultiCall(list)
    }
    
    func updateItemsToDisplay() {
        if let feedToDisplay = feedToDisplay {
            itemsToDisplay = feedToDisplay.items.sorted(by: <)
        } else {
            itemsToDisplay = feeds.reduce([RSSItem]()){ $0+$1.items }.sorted(by: <)
        }
    }
    
    func updateFeeds() {
        for feed in feeds {
            _ = feed.update()
        }
        updateItemsToDisplay()
    }
    
    func appendRSS(_ feed: RSSFeed) {
        feeds.append(feed)
        updateItemsToDisplay()
    }
    
    func removeFeed(_ feed: RSSFeed?) {
        if let feed = feed, let index = feeds.index(of: feed) {
            if feedToDisplay == feed {
                feedToDisplay = nil
            }
            feeds.remove(at: index)
        } else {
            feedToDisplay = nil
            feeds.removeAll()
        }
        updateItemsToDisplay()
    }
    
    func numberOtItemsToDisplay(_ searchText: String?) -> Int {
        if let searchText = searchText {
            return itemsToDisplay.filter { $0.match(searchText) }.count
        } else {
            return itemsToDisplay.count
        }
    }
    
    func itemToDisplayAtIndexPath(_ indexPath: IndexPath, thatMatch searchText: String?) -> RSSItem {
        if let searchText = searchText {
            return itemsToDisplay.filter { $0.match(searchText) }[indexPath.row]
        } else {
            return itemsToDisplay[indexPath.row]
        }
    }
    
    func updateTorrentsToDiplay() {
        torrentsToDisplay = torrents.filter { $0.isFilterBy(filterDlBy) }
        torrentsToDisplay.sort { $0.isOrderedBefore($1, by: sortDlBy, inOrder: sortDlIn) }
    }
    
    func numberOfTorrentToDispplay(_ searchText: String?) -> Int {
        if let searchText = searchText {
            return torrentsToDisplay.filter { $0.match(searchText) }.count
        } else {
            return torrentsToDisplay.count
        }
    }
    
    func torrentAtIndexPath(_ indexPath: IndexPath, searchText: String?) -> Torrent {
        if let searchText = searchText {
            return torrentsToDisplay.filter { $0.match(searchText) }[indexPath.row]
        } else {
            return torrentsToDisplay[indexPath.row]
        }
    }
}

enum Response<SuccessType, FailureType>
{
    case success(SuccessType)
    case failure(FailureType)
}

enum SortingOrder: Int {
    case ascending = 0
    case descending
    
    static var count: Int { return SortingOrder.descending.rawValue + 1}
    static func stringOf(_ index: Int) -> String {
        if let sortOrder = SortingOrder(rawValue: index) {
            switch sortOrder {
            case .ascending:
                return "Ascending"
            case .descending:
                return "Descending"
            }
        } else {
            return ""
        }
    }
}

enum SortingBy: Int {
    case date = 0
    case name
    case size
    case send
    
    static var count: Int { return SortingBy.send.rawValue + 1}
    static func stringOf(_ index: Int) -> String {
        if let sortBy = SortingBy(rawValue: index) {
            switch sortBy {
            case .date:
                return "Date"
            case .name:
                return "Name"
            case .size:
                return "Size"
            case .send:
                return "Send"
            }
        } else {
            return ""
        }
    }
}

enum FilterBy: Int {
    case all = 0
    case sending
    case receiving
    case seeding
    case leeching
    case error
    case pause
    case stop
    case active
    
    static var count: Int { return FilterBy.active.rawValue + 1}
    static func stringOf(_ index: Int) -> String {
        if let filterBy = FilterBy(rawValue: index) {
            switch filterBy {
            case .all:
                return "All"
            case .sending:
                return "Sending"
            case .receiving:
                return "Receiving"
            case .seeding:
                return "Seeding"
            case .leeching:
                return "Leeching"
            case .error:
                return "Error"
            case .pause:
                return "Pause"
            case .stop:
                return "Stop"
            case .active:
                return "Active"
                
            }
        } else {
            return ""
        }
    }
    
}

