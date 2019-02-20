//
//  rTorrentCall.swift
//  roTorrent
//
//  Created by Romain Hild on 19/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

enum RTorrentCall {
    
    case addTorrent(String, String)
    case addTorrentRaw(String)
    case listMethods
    case methodSignature(String)
    case methodHelp(String)
    case dlList
    case viewList
    case baseDirectory
    case execute([String])
    case listDirectories(String)
    case moveFile(String, String)
    case deleteFiles(String)
    case loadURL(String)
    case filename(String)
    case hash(String)
    case date(String)
    case size(String)
    case sizeCompleted(String)
    case sizeLeft(String)
    case sizeUP(String)
    case path(String)
    case directory(String)
    case speedDL(String)
    case speedUP(String)
    case leechers(String)
    case seeders(String)
    case ratio(String)
    case state(String)
    case message(String)
    case isActive(String)
    case isOpen(String)
    case views(String)
    case numberOfFiles(String)
    case numberOfTrackers(String)
    case pause(String)
    case resume(String)
    case start(String)
    case stop(String)
    case setDirectory(String, String)
    case erase(String)
    case dMultiCall(String,[RTorrentCall])
    case filesName(String)
    case filesSize(String)
    case fMultiCall(String,[RTorrentCall])
    case trackerURL(String)
    case trackerSeeders(String)
    case trackerLeechers(String)
    case tMultiCall(String,[RTorrentCall])
    case systemMultiCall([RTorrentCall])
    
    var methodName: String {
        switch self {
        case .addTorrent:
            return "schedule"
        case .addTorrentRaw:
            return "load_raw_start"
        case .listMethods:
            return "system.listMethods"
        case .methodSignature:
            return "system.methodSignature"
        case .methodHelp:
            return "system.methodHelp"
        case .dlList:
            return "download_list"
        case .viewList:
            return "view_list"
        case .baseDirectory:
            return "get_directory"
        case .execute, .listDirectories, .moveFile, .deleteFiles:
            return "execute_capture"
        case .loadURL:
            return "load_start"
        case .filename:
            return "d.get_base_filename"
        case .hash:
            return "d.get_hash"
        case .date:
            return "d.timestamp.started"
        case .size:
            return "d.get_size_bytes"
        case .sizeCompleted:
            return "d.get_completed_bytes"
        case .sizeLeft:
            return "d.get_left_bytes"
        case .sizeUP:
            return "d.get_up_total"
        case .path:
            return "d.get_base_path"
        case .directory:
            return "d.get_directory_base"
        case .speedDL:
            return "d.get_down_rate"
        case .speedUP:
            return "d.get_up_rate"
        case .leechers:
            return "d.get_peers_accounted"
        case .seeders:
            return "d.get_peers_complete"
        case .ratio:
            return "d.get_ratio"
        case .state:
            return "d.get_state"
        case .message:
            return "d.get_message"
        case .isActive:
            return "d.is_active"
        case .isOpen:
            return "d.is_open"
        case .views:
            return "d.views"
        case .numberOfFiles:
            return "d.get_size_files"
        case .numberOfTrackers:
            return "d.get_tracker_size"
        case .pause:
            return "d.pause"
        case .resume:
            return "d.resume"
        case .start:
            return "d.start"
        case .stop:
            return "d.stop"
        case .setDirectory:
            return "d.set_directory"
        case .erase:
            return "d.erase"
        case .dMultiCall:
            return "d.multicall"
        case .filesName:
            return "f.path"
        case .filesSize:
            return "f.get_size_bytes"
        case .fMultiCall:
            return "f.multicall"
        case .trackerURL:
            return "t.get_url"
        case .trackerSeeders:
            return "t.get_scrape_complete"
        case .trackerLeechers:
            return "t.get_scrape_incomplete"
        case .tMultiCall:
            return "t.multicall"
        case .systemMultiCall:
            return "system.multicall"
        }
    }
    
    var paramList: [String] {
        var p = [String]()
        switch self {
        case .addTorrent(let torrent, let directory):
            p.append("<value><string>add_torrent</string></value>")
            p.append("<value><string>0</string></value>")
            p.append("<value><string>0</string></value>")
            var pp = "<value><string>load_start=\(torrent)"
            if !directory.isEmpty {
                pp += ",d.set_directory=\(directory)"
            }
            pp += "</string></value>"
            p.append(pp)
        case .addTorrentRaw(let torrentData):
            p.append("<value><base64>\(torrentData)</base64></value>")
        case .listMethods, .dlList,.viewList,.baseDirectory:
            break
        case .methodSignature(let method):
            p.append("<value><string>\(method)</string></value>")
        case .methodHelp(let method):
            p.append("<value><string>\(method)</string></value>")
        case .execute(let array):
            for item in array {
                p.append("<value><string>\(item)</string></value>")
            }
        case .listDirectories(let dir):
            p.append("<value><string>find</string></value>")
            p.append("<value><string>\(dir)</string></value>")
            p.append("<value><string>-maxdepth</string></value>")
            p.append("<value><string>1</string></value>")
            p.append("<value><string>-mindepth</string></value>")
            p.append("<value><string>1</string></value>")
        case .moveFile(let path, let newDir):
            p.append("<value><string>mv</string></value>")
            p.append("<value><string>\(path)</string></value>")
            p.append("<value><string>\(newDir)</string></value>")
        case .deleteFiles(let path):
            p.append("<value><string>rm</string></value>")
            p.append("<value><string>-r</string></value>")
            p.append("<value><string>\(path)</string></value>")
        case .loadURL(let url):
            p.append("<value><string>\(url)</string></value>")
        case .filename(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .hash(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .date(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .size(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .sizeCompleted(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .sizeLeft(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .sizeUP(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .path(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .directory(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .speedDL(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .speedUP(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .leechers(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .seeders(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .ratio(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .state(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .message(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .isActive(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .isOpen(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .views(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .numberOfFiles(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .numberOfTrackers(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .pause(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .resume(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .start(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .stop(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .setDirectory(let hash, let directory):
            p.append("<value><string>\(hash)</string></value>")
            p.append("<value><string>\(directory)</string></value>")
        case .erase(let hash):
            p.append("<value><string>\(hash)</string></value>")
        case .dMultiCall(let view, let array):
            p.append("<value><string>\(view)</string></value>")
            for item in array {
                p.append("<value><string>\(item.methodName)=</string></value>")
            }
        case .filesName(let hashF):
            p.append("<value><string>\(hashF)</string></value>")
        case .filesSize(let hashF):
            p.append("<value><string>\(hashF)</string></value>")
        case .fMultiCall(let hash, let array):
            p.append("<value><string>\(hash)</string></value>")
            p.append("<value><string></string></value>")
            for item in array {
                p.append("<value><string>\(item.methodName)=</string></value>")
            }
        case .trackerURL(let hashT):
            p.append("<value><string>\(hashT)</string></value>")
        case .trackerSeeders(let hashT):
            p.append("<value><string>\(hashT)</string></value>")
        case .trackerLeechers(let hashT):
            p.append("<value><string>\(hashT)</string></value>")
        case .tMultiCall(let hash, let array):
            p.append("<value><string>\(hash)</string></value>")
            p.append("<value><string></string></value>")
            for item in array {
                p.append("<value><string>\(item.methodName)=</string></value>")
            }
        case .systemMultiCall:
            break
        }
        return p
    }
    
    var param: String {
        var p = ""
        switch self {
        case .systemMultiCall(let array):
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

