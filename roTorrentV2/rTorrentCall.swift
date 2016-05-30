//
//  rTorrentCall.swift
//  roTorrent
//
//  Created by Romain Hild on 19/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

enum RTorrentCall {
    
    case AddTorrent(String, String)
    case AddTorrentRaw(String)
    case ListMethods
    case MethodSignature(String)
    case MethodHelp(String)
    case DlList
    case ViewList
    case BaseDirectory
    case Execute([String])
    case ListDirectories(String)
    case MoveFile(String, String)
    case DeleteFiles(String)
    case LoadURL(String)
    case Filename(String)
    case Hash(String)
    case Date(String)
    case Size(String)
    case SizeCompleted(String)
    case SizeLeft(String)
    case SizeUP(String)
    case Path(String)
    case Directory(String)
    case SpeedDL(String)
    case SpeedUP(String)
    case Leechers(String)
    case Seeders(String)
    case Ratio(String)
    case State(String)
    case Message(String)
    case IsActive(String)
    case IsOpen(String)
    case Views(String)
    case NumberOfFiles(String)
    case NumberOfTrackers(String)
    case Pause(String)
    case Resume(String)
    case Start(String)
    case Stop(String)
    case SetDirectory(String, String)
    case Erase(String)
    case DMultiCall(String,[RTorrentCall])
    case FilesName(String)
    case FilesSize(String)
    case FMultiCall(String,[RTorrentCall])
    case TrackerURL(String)
    case TrackerSeeders(String)
    case TrackerLeechers(String)
    case TMultiCall(String,[RTorrentCall])
    case SystemMultiCall([RTorrentCall])
    
    var methodName: String {
        switch self {
        case .AddTorrent:
            return "schedule"
        case .AddTorrentRaw:
            return "load_raw_start"
        case .ListMethods:
            return "system.listMethods"
        case .MethodSignature:
            return "system.methodSignature"
        case .MethodHelp:
            return "system.methodHelp"
        case DlList:
            return "download_list"
        case ViewList:
            return "view_list"
        case BaseDirectory:
            return "get_directory"
        case Execute, .ListDirectories, .MoveFile, .DeleteFiles:
            return "execute_capture"
        case LoadURL:
            return "load_start"
        case Filename:
            return "d.get_base_filename"
        case Hash:
            return "d.get_hash"
        case Date:
            return "d.timestamp.started"
        case Size:
            return "d.get_size_bytes"
        case SizeCompleted:
            return "d.get_completed_bytes"
        case SizeLeft:
            return "d.get_left_bytes"
        case SizeUP:
            return "d.get_up_total"
        case Path:
            return "d.get_base_path"
        case Directory:
            return "d.get_directory_base"
        case SpeedDL:
            return "d.get_down_rate"
        case SpeedUP:
            return "d.get_up_rate"
        case Leechers:
            return "d.get_peers_accounted"
        case Seeders:
            return "d.get_peers_complete"
        case Ratio:
            return "d.get_ratio"
        case State:
            return "d.get_state"
        case Message:
            return "d.get_message"
        case .IsActive:
            return "d.is_active"
        case .IsOpen:
            return "d.is_open"
        case .Views:
            return "d.views"
        case .NumberOfFiles:
            return "d.get_size_files"
        case .NumberOfTrackers:
            return "d.get_tracker_size"
        case .Pause:
            return "d.pause"
        case .Resume:
            return "d.resume"
        case .Start:
            return "d.start"
        case .Stop:
            return "d.stop"
        case .SetDirectory:
            return "d.set_directory"
        case .Erase:
            return "d.erase"
        case DMultiCall:
            return "d.multicall"
        case FilesName:
            return "f.path"
        case FilesSize:
            return "f.get_size_bytes"
        case FMultiCall:
            return "f.multicall"
        case TrackerURL:
            return "t.get_url"
        case TrackerSeeders:
            return "t.get_scrape_complete"
        case TrackerLeechers:
            return "t.get_scrape_incomplete"
        case TMultiCall:
            return "t.multicall"
        case .SystemMultiCall:
            return "system.multicall"
        }
    }
    
    var paramList: [String] {
        var p = [String]()
        switch self {
        case AddTorrent(let torrent, let directory):
            p.append("<value><string>add_torrent</string></value>")
            p.append("<value><string>0</string></value>")
            p.append("<value><string>0</string></value>")
            var pp = "<value><string>load_start=\(torrent)"
            if !directory.isEmpty {
                pp += ",d.set_directory=\(directory)"
            }
            pp += "</string></value>"
            p.append(pp)
        case .AddTorrentRaw(let torrentData):
            p.append("<value><base64>\(torrentData)</base64></value>")
        case .ListMethods, .DlList,.ViewList,.BaseDirectory:
            break
        case .MethodSignature(let method):
            p.append("<value><string>\(method)</string></value>")
        case .MethodHelp(let method):
            p.append("<value><string>\(method)</string></value>")
        case Execute(let array):
            for item in array {
                p.append("<value><string>\(item)</string></value>")
            }
        case .ListDirectories(let dir):
            p.append("<value><string>find</string></value>")
            p.append("<value><string>\(dir)</string></value>")
            p.append("<value><string>-maxdepth</string></value>")
            p.append("<value><string>1</string></value>")
            p.append("<value><string>-mindepth</string></value>")
            p.append("<value><string>1</string></value>")
        case .MoveFile(let path, let newDir):
            p.append("<value><string>mv</string></value>")
            p.append("<value><string>\(path)</string></value>")
            p.append("<value><string>\(newDir)</string></value>")
        case .DeleteFiles(let path):
            p.append("<value><string>rm</string></value>")
            p.append("<value><string>-r</string></value>")
            p.append("<value><string>\(path)</string></value>")
        case LoadURL(let url):
            p.append("<value><string>\(url)</string></value>")
        case Filename(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Hash(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Date(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Size(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case SizeCompleted(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case SizeLeft(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case SizeUP(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Path(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Directory(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case SpeedDL(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case SpeedUP(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Leechers(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Seeders(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Ratio(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case State(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case Message(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .IsActive(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .IsOpen(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .Views(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .NumberOfFiles(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .NumberOfTrackers(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .Pause(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .Resume(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .Start(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .Stop(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .SetDirectory(let hash, let directory):
            p.append("<value><string>\(hash)</string></value>")
            p.append("<value><string>\(directory)</string></value>")
        case .Erase(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case DMultiCall(let view, let array):
            p.append("<value><string>\(view)</string></value>")
            for item in array {
                p.append("<value><string>\(item.methodName)=</string></value>")
            }
        case .FilesName(let hashF):
            p.append("<value><string>\(hashF)</string></value>")
        case .FilesSize(let hashF):
            p.append("<value><string>\(hashF)</string></value>")
        case FMultiCall(let hash, let array):
            p.append("<value><string>\(hash)</string></value>")
            p.append("<value><string></string></value>")
            for item in array {
                p.append("<value><string>\(item.methodName)=</string></value>")
            }
        case .TrackerURL(let hashT):
            p.append("<value><string>\(hashT)</string></value>")
        case .TrackerSeeders(let hashT):
            p.append("<value><string>\(hashT)</string></value>")
        case .TrackerLeechers(let hashT):
            p.append("<value><string>\(hashT)</string></value>")
        case .TMultiCall(let hash, let array):
            p.append("<value><string>\(hash)</string></value>")
            p.append("<value><string></string></value>")
            for item in array {
                p.append("<value><string>\(item.methodName)=</string></value>")
            }
        case .SystemMultiCall:
            break
        }
        return p
    }
    
    var param: String {
        var p = ""
        switch self {
        case .SystemMultiCall(let array):
            p += "<param><value><array><data>"
            for method in array {
                p += "<value><struct>"
                p += "<member><name>methodName</name><value><string>\(method.methodName)</string></value></member>"
                p += "<member><name>params</name><value><array><data>"
                for param in method.paramList {
                    p += param
                }
                p += "</data></array></value></member>"
                p += "</struct></value>"
            }
            p += "</data></array></value></param>"
        default:
            for param in self.paramList {
                p += "<param>\(param)</param>"
            }
        }
        return p
    }
    
    var body: String {
        var b = "<?xml version=\"1.0\"?><methodCall><methodName>\(self.methodName)</methodName><params>"
        b += self.param
        b += "</params></methodCall>"
        return b
    }
    
}

