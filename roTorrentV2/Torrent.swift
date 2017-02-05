//
//  Torrent.swift
//  roTorrent
//
//  Created by Romain Hild on 18/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class Torrent : NSObject
{
    var name: String = ""
    var hashT: String = ""
    var date: Date = Date()
    var ratio: Double = 0
    var size: Int64 = 0
    var sizeCompleted: Int64 = 1
    var sizeLeft: Int64 = 0
    var sizeUP: Int64 = 0
    var path: String = ""
    var directory: String = ""
    var speedDL: Int64 = 0
    var speedUP: Int64 = 0
    var leechers: Int = 0
    var seeders: Int = 0
    var allSeeders: Int?
    var allLeechers: Int?
    var state: Int = 0
    var isActive: Int = 0
    var message: String?
    var numberOfFiles: Int = 0
    var listOfFiles = [String]()
    var listOfFilesSize = [Int64]()
    var numberOfTrackers: Int = 0
    var listOfTrackers = [String]()
    var listOfTrackersSeeders = [Int]()
    var listOfTrackersLeechers = [Int]()
    var isFilesInit = false
    var isTrakersInit = false

    
    init(array: [XMLRPCType]) {
        super.init()
        setName(array[0])
        setHash(array[1])
        setDate(array[2])
        setRatio(array[3])
        setSize(array[4])
        setSizeCompleted(array[5])
        setSizeLeft(array[6])
        setSizeUp(array[7])
        setPath(array[8])
        setDirectory(array[9])
        setSpeedDL(array[10])
        setSpeedUP(array[11])
        setLeechers(array[12])
        setSeeders(array[13])
        setState(array[14])
        setIsActive(array[15])
        setMessage(array[16])
        setNumberOfFiles(array[17])
        setNumberOfTrackers(array[18])
    }
    
    func initFiles(_ xmlArray: XMLRPCType) {
        switch xmlArray {
        case .xmlrpcArray(let array):
            for xmlItem in array {
                switch xmlItem {
                case .xmlrpcArray(let arrayFile):
                    setFile(arrayFile)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func initTrackers(_ xmlArray: XMLRPCType) {
        switch xmlArray {
        case .xmlrpcArray(let array):
            for xmlItem in array {
                switch xmlItem {
                case .xmlrpcArray(let arrayTracker):
                    setTracker(arrayTracker)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func setName(_ xmlName: XMLRPCType) {
        switch xmlName {
        case .xmlrpcString(let newName):
            self.name = newName
        default:
            break
        }
    }
    
    func setHash(_ xmlHash: XMLRPCType) {
        switch xmlHash {
        case .xmlrpcString(let newHash):
            self.hashT = newHash
        default:
            break
        }
    }
    
    func setDate(_ xmlCreationDate: XMLRPCType) {
        switch xmlCreationDate {
        case .xmlrpcDate(let newDate):
            self.date = newDate
        case .xmlrpcInt(let dateAsInt):
            self.date = Date(timeIntervalSince1970: TimeInterval(dateAsInt))
        default:
            break
        }
    }
    
    func setSize(_ xmlSize: XMLRPCType) {
        switch xmlSize {
        case .xmlrpcInt(let newSize):
            self.size = Int64(newSize)
        default:
            break
        }
    }
    
    func setSizeCompleted(_ xmlSize: XMLRPCType) {
        switch xmlSize {
        case .xmlrpcInt(let newSize):
            self.sizeCompleted = Int64(newSize)
        default:
            break
        }
    }
    
    func setSizeLeft(_ xmlSize: XMLRPCType) {
        switch xmlSize {
        case .xmlrpcInt(let newSize):
            self.sizeLeft = Int64(newSize)
        default:
            break
        }
    }
    
    func setSizeUp(_ xmlSize: XMLRPCType) {
        switch xmlSize {
        case .xmlrpcInt(let newSize):
            self.sizeUP = Int64(newSize)
        default:
            break
        }
    }
    
    func setPath(_ xmlPath: XMLRPCType) {
        switch xmlPath {
        case .xmlrpcString(let newPath):
            self.path = newPath
        default:
            break
        }
    }
    
    func setDirectory(_ xmlDirectory: XMLRPCType) {
        switch xmlDirectory {
        case .xmlrpcString(var newDirectory):
            let s = NSString(string: newDirectory)
            let r = newDirectory.range(of: s.lastPathComponent)
            newDirectory.removeSubrange(r!)
            self.directory = newDirectory
        default:
            break
        }
    }
    
    func setSpeedDL(_ xmlSpeed: XMLRPCType) {
        switch xmlSpeed {
        case .xmlrpcInt(let newSize):
            self.speedDL = Int64(newSize)
        default:
            break
        }
    }
    
    func setSpeedUP(_ xmlSpeed: XMLRPCType) {
        switch xmlSpeed {
        case .xmlrpcInt(let newSize):
            self.speedUP = Int64(newSize)
        default:
            break
        }
    }
    
    func setLeechers(_ xmlLeechers: XMLRPCType) {
        switch xmlLeechers {
        case .xmlrpcInt(let newLeechers):
            self.leechers = newLeechers
        default:
            break
        }
    }
    
    func setSeeders(_ xmlSeeders: XMLRPCType) {
        switch xmlSeeders {
        case .xmlrpcInt(let newSeeders):
            self.seeders = newSeeders
        default:
            break
        }
    }
    
    func setRatio(_ xmlRatio: XMLRPCType) {
        switch xmlRatio {
        case .xmlrpcDouble(let newRatio):
            self.ratio = newRatio
        case .xmlrpcInt(let ratioAsInt):
            self.ratio = Double(ratioAsInt)/1000
        default:
            break
        }
    }
    
    func setState(_ xmlState: XMLRPCType) {
        switch xmlState {
        case .xmlrpcInt(let newState):
            self.state = newState
        default:
            break
        }
    }
    
    func setIsActive(_ xmlIsActive: XMLRPCType) {
        switch xmlIsActive {
        case .xmlrpcInt(let newActivity):
            self.isActive = newActivity
        default:
            break
        }
    }
    
    func setMessage(_ xmlMessage: XMLRPCType) {
        switch xmlMessage {
        case .xmlrpcString(let newMessage):
            self.message = newMessage
        case .xmlrpcNil:
            self.message = nil
        default:
            break
        }
    }
    
    func setNumberOfFiles(_ xmlNbFiles: XMLRPCType) {
        switch xmlNbFiles {
        case .xmlrpcInt(let newNbFiles):
            self.numberOfFiles = newNbFiles
        default:
            break
        }
    }
    
    func setNumberOfTrackers(_ xmlNbTrackers: XMLRPCType) {
        switch xmlNbTrackers {
        case .xmlrpcInt(let newNbTrackers):
            self.numberOfTrackers = newNbTrackers
        default:
            break
        }
    }
    
    func setFile(_ xmlFile: [XMLRPCType]) {
        let xmlFileName = xmlFile[0]
        switch xmlFileName {
        case .xmlrpcString(let filename):
            listOfFiles.append(filename)
        default:
            break
        }
        
        let xmlSize = xmlFile[1]
        switch xmlSize {
        case .xmlrpcInt(let size):
            listOfFilesSize.append(Int64(size))
        default:
            break
        }
    }
    
    func setTracker(_ xmlTracker: [XMLRPCType]) {
        let xmlURL = xmlTracker[0]
        switch xmlURL {
        case .xmlrpcString(let url):
            listOfTrackers.append(url)
        default:
            break
        }
        
        let xmlSeeders = xmlTracker[1]
        switch xmlSeeders {
        case .xmlrpcInt(let seed):
            listOfTrackersSeeders.append(seed)
            if var _ = allSeeders {
                self.allSeeders! += seed
            } else {
                allSeeders = seed
            }
        default:
            break
        }
        
        let xmlLeechers = xmlTracker[2]
        switch xmlLeechers {
        case .xmlrpcInt(let leech):
            listOfTrackersLeechers.append(leech)
            if var _ = allLeechers {
                self.allLeechers! += leech
            } else {
                allLeechers = leech
            }
        default:
            break
        }
    }
    
    func refreshState(_ xmltype: XMLRPCType) {
        switch xmltype {
        case .xmlrpcArray(let xmlarray):
            switch xmlarray[0] {
            case .xmlrpcArray(let xmlState):
                self.setState(xmlState[0])
            default:
                break
            }
            switch xmlarray[1] {
            case .xmlrpcArray(let xmlState):
                self.setIsActive(xmlState[0])
            default:
                break
            }
            switch xmlarray[2] {
            case .xmlrpcArray(let xmlState):
                self.setMessage(xmlState[0])
            default:
                break
            }
        default:
            break
        }
    }
    
    func refreshDirAndPath(_ xmltype: XMLRPCType) {
        switch xmltype {
        case .xmlrpcArray(let xmlarray):
            switch xmlarray[0] {
            case .xmlrpcArray(let xmlDir):
                self.setDirectory(xmlDir[0])
            default:
                break
            }
            switch xmlarray[1] {
            case .xmlrpcArray(let xmlPath):
                self.setPath(xmlPath[0])
            default:
                break
            }
        default:
            break
        }
    }
    
    func match(_ search: String) -> Bool {
        if !search.isEmpty {
            var searchAsRegex = search.replacingOccurrences(of: " ", with: ".")
            searchAsRegex = searchAsRegex.replacingOccurrences(of: "_", with: ".")
            searchAsRegex = searchAsRegex.replacingOccurrences(of: "-", with: ".")
            let b = name.range(of: searchAsRegex, options: [.regularExpression, .caseInsensitive])
            return (b != nil)
        } else {
            return true
        }
    }

    func isFilterBy(_ filter: FilterBy = .all) -> Bool {
        let filtered: Bool
        switch filter {
        case .all:
            filtered = true
        case .sending:
            filtered = speedUP > 0
        case .receiving:
            filtered = speedDL > 0
        case .seeding:
            filtered = (sizeLeft == 0)
        case .leeching:
            filtered = (sizeLeft != 0)
        case .error:
            filtered = (message != nil)
        case .pause:
            filtered = (isActive == 0)
        case .stop:
            filtered = (state == 0)
        case .active:
            filtered = (isActive == 1) && (state == 1)
//        case .Directory(let dir):
//            filtered = (directory == dir)
//        case .Tracker(let track):
//            filtered = listOfTrackers.reduce(false) { $0 || NSURL(string: $1)!.host! == track }
        }
        return filtered
    }
    
    func isOrderedBefore(_ second: Torrent, by sort: SortingBy, inOrder order: SortingOrder) -> Bool {
        let b: Bool
        switch sort {
        case .date:
            switch date.compare(second.date) {
            case .orderedAscending:
                b = true
            case .orderedDescending, .orderedSame:
                b = false
            }
        case .name:
            switch name.compare(second.name) {
            case .orderedAscending:
                b = true
            case .orderedDescending, .orderedSame:
                b = false
            }
        case .send:
            b = sizeUP < second.sizeUP
        case .size:
            b = size < second.size
            //        case .Seeders:
            //            b = true
            //        case .Leechers:
            //            b = true
        }
        switch order {
        case .ascending:
            return b
        case .descending:
            return !b
        }
    }
}

class Torrents {
    fileprivate var torrents = [Torrent]()
    
    func initWithXmlArray(_ xmlArray: XMLRPCType) {
        torrents.removeAll()
        switch xmlArray {
        case .xmlrpcArray(let torrentsArray):
            for xmlTorrentArray in torrentsArray {
                switch xmlTorrentArray {
                case .xmlrpcArray(let torrentArray):
                    let torrent = Torrent(array: torrentArray)
                    torrents.append(torrent)
                default:
                    break
                }
            }
        default:
            break
        }
    }
}

extension Torrents: Sequence {
    func makeIterator() -> AnyIterator<Torrent> {
        var nextIndex = 0
        return AnyIterator<Torrent> {
            if nextIndex < self.torrents.count {
                nextIndex += 1
                return self.torrents[nextIndex-1]
            } else {
                return nil
            }
        }
    }
}

extension Torrents: Collection {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i+1
    }

    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return torrents.count
    }

    subscript(index: Int) -> Torrent {
        return torrents[index]
    }
}
