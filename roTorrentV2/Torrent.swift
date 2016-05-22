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
    var date: NSDate = NSDate()
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
    
    func setName(xmlName: XMLRPCType) {
        switch xmlName {
        case .XMLRPCString(let newName):
            self.name = newName
        default:
            break
        }
    }
    
    func setHash(xmlHash: XMLRPCType) {
        switch xmlHash {
        case .XMLRPCString(let newHash):
            self.hashT = newHash
        default:
            break
        }
    }
    
    func setDate(xmlCreationDate: XMLRPCType) {
        switch xmlCreationDate {
        case .XMLRPCDate(let newDate):
            self.date = newDate
        case .XMLRPCInt(let dateAsInt):
            self.date = NSDate(timeIntervalSince1970: NSTimeInterval(dateAsInt))
        default:
            break
        }
    }
    
    func setSize(xmlSize: XMLRPCType) {
        switch xmlSize {
        case .XMLRPCInt(let newSize):
            self.size = Int64(newSize)
        default:
            break
        }
    }
    
    func setSizeCompleted(xmlSize: XMLRPCType) {
        switch xmlSize {
        case .XMLRPCInt(let newSize):
            self.sizeCompleted = Int64(newSize)
        default:
            break
        }
    }
    
    func setSizeLeft(xmlSize: XMLRPCType) {
        switch xmlSize {
        case .XMLRPCInt(let newSize):
            self.sizeLeft = Int64(newSize)
        default:
            break
        }
    }
    
    func setSizeUp(xmlSize: XMLRPCType) {
        switch xmlSize {
        case .XMLRPCInt(let newSize):
            self.sizeUP = Int64(newSize)
        default:
            break
        }
    }
    
    func setPath(xmlPath: XMLRPCType) {
        switch xmlPath {
        case .XMLRPCString(let newPath):
            self.path = newPath
        default:
            break
        }
    }
    
    func setDirectory(xmlDirectory: XMLRPCType) {
        switch xmlDirectory {
        case .XMLRPCString(var newDirectory):
            let s = NSString(string: newDirectory)
            let r = newDirectory.rangeOfString(s.lastPathComponent)
            newDirectory.removeRange(r!)
            self.directory = newDirectory
        default:
            break
        }
    }
    
    func setSpeedDL(xmlSpeed: XMLRPCType) {
        switch xmlSpeed {
        case .XMLRPCInt(let newSize):
            self.speedDL = Int64(newSize)
        default:
            break
        }
    }
    
    func setSpeedUP(xmlSpeed: XMLRPCType) {
        switch xmlSpeed {
        case .XMLRPCInt(let newSize):
            self.speedUP = Int64(newSize)
        default:
            break
        }
    }
    
    func setLeechers(xmlLeechers: XMLRPCType) {
        switch xmlLeechers {
        case .XMLRPCInt(let newLeechers):
            self.leechers = newLeechers
        default:
            break
        }
    }
    
    func setSeeders(xmlSeeders: XMLRPCType) {
        switch xmlSeeders {
        case .XMLRPCInt(let newSeeders):
            self.seeders = newSeeders
        default:
            break
        }
    }
    
    func setRatio(xmlRatio: XMLRPCType) {
        switch xmlRatio {
        case .XMLRPCDouble(let newRatio):
            self.ratio = newRatio
        case .XMLRPCInt(let ratioAsInt):
            self.ratio = Double(ratioAsInt)/1000
        default:
            break
        }
    }
    
    func setState(xmlState: XMLRPCType) {
        switch xmlState {
        case .XMLRPCInt(let newState):
            self.state = newState
        default:
            break
        }
    }
    
    func setIsActive(xmlIsActive: XMLRPCType) {
        switch xmlIsActive {
        case .XMLRPCInt(let newActivity):
            self.isActive = newActivity
        default:
            break
        }
    }
    
    func setMessage(xmlMessage: XMLRPCType) {
        switch xmlMessage {
        case .XMLRPCString(let newMessage):
            self.message = newMessage
        case .XMLRPCNil:
            self.message = nil
        default:
            break
        }
    }
    
    func setNumberOfFiles(xmlNbFiles: XMLRPCType) {
        switch xmlNbFiles {
        case .XMLRPCInt(let newNbFiles):
            self.numberOfFiles = newNbFiles
        default:
            break
        }
    }
    
    func setNumberOfTrackers(xmlNbTrackers: XMLRPCType) {
        switch xmlNbTrackers {
        case .XMLRPCInt(let newNbTrackers):
            self.numberOfTrackers = newNbTrackers
        default:
            break
        }
    }
    
    func setFile(xmlFile: [XMLRPCType]) {
        let xmlFileName = xmlFile[0]
        switch xmlFileName {
        case .XMLRPCString(let filename):
            listOfFiles.append(filename)
        default:
            break
        }
        
        let xmlSize = xmlFile[1]
        switch xmlSize {
        case .XMLRPCInt(let size):
            listOfFilesSize.append(Int64(size))
        default:
            break
        }
    }
    
    func setTracker(xmlTracker: [XMLRPCType]) {
        let xmlURL = xmlTracker[0]
        switch xmlURL {
        case .XMLRPCString(let url):
            listOfTrackers.append(url)
        default:
            break
        }
        
        let xmlSeeders = xmlTracker[1]
        switch xmlSeeders {
        case .XMLRPCInt(let seed):
            listOfTrackersSeeders.append(seed)
            if var allSeeders = allSeeders {
                allSeeders += seed
            } else {
                allSeeders = seed
            }
        default:
            break
        }
        
        let xmlLeechers = xmlTracker[2]
        switch xmlLeechers {
        case .XMLRPCInt(let leech):
            listOfTrackersLeechers.append(leech)
            if var allLeechers = allLeechers {
                allLeechers += leech
            } else {
                allLeechers = leech
            }
        default:
            break
        }
    }
    
    func match(search: String) -> Bool {
        if !search.isEmpty {
            var searchAsRegex = search.stringByReplacingOccurrencesOfString(" ", withString: ".")
            searchAsRegex = searchAsRegex.stringByReplacingOccurrencesOfString("_", withString: ".")
            searchAsRegex = searchAsRegex.stringByReplacingOccurrencesOfString("-", withString: ".")
            let b = name.rangeOfString(searchAsRegex, options: [.RegularExpressionSearch, .CaseInsensitiveSearch])
            return (b != nil)
        } else {
            return true
        }
    }
}

class Torrents {
    private var torrents = [Torrent]()
    
    func initWithXmlArray(xmlArray: XMLRPCType) {
        torrents.removeAll()
        switch xmlArray {
        case .XMLRPCArray(let torrentsArray):
            for xmlTorrentArray in torrentsArray {
                switch xmlTorrentArray {
                case .XMLRPCArray(let torrentArray):
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

extension Torrents: SequenceType {
    func generate() -> AnyGenerator<Torrent> {
        var nextIndex = 0
        return AnyGenerator<Torrent> {
            if nextIndex < self.torrents.count {
                nextIndex += 1
                return self.torrents[nextIndex-1]
            } else {
                return nil
            }
        }
    }
}

extension Torrents: CollectionType {
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
