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
    case ListMethods
    case DlList
    case ViewList
    case BaseDirectory
    case Execute([String])
    case ListDirectories(String)
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
    case Erase(String)
    case DMultiCall(String,[RTorrentCall])
    case FilesName(String)
    case FilesSize(String)
    case FMultiCall(String,[RTorrentCall])
    case TrackerURL(String)
    case TrackerSeeders(String)
    case TrackerLeechers(String)
    case TMultiCall(String,[RTorrentCall])
    
    var methodName: String {
        switch self {
        case .AddTorrent:
            return "schedule"
        case .ListMethods:
            return "system.listMethods"
        case DlList:
            return "download_list"
        case ViewList:
            return "view_list"
        case BaseDirectory:
            return "get_directory"
        case Execute:
            return "execute_capture"
        case .ListDirectories:
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
        }
    }
    
    var param: String? {
        var p = ""
        switch self {
        case AddTorrent(let torrent, let directory):
            p += "<param><value><string>add_torrent</string></value></param>"
            p += "<param><value><string>0</string></value></param>"
            p += "<param><value><string>0</string></value></param>"
            p += "<param><value><string>load_start=\(torrent)"
            if !directory.isEmpty {
                p += ",d.set_directory=\(directory)"
            }
            p += "</string></value></param>"
            return p
        case .ListMethods, .DlList,.ViewList,.BaseDirectory:
            return nil
        case Execute(let array):
            for item in array {
                p += "<param><value><string>\(item)</string></value></param>"
            }
            return p
        case .ListDirectories(let dir):
            p += "<param><value><string>find</string></value></param>"
            p += "<param><value><string>\(dir)</string></value></param>"
            p += "<param><value><string>-maxdepth</string></value></param>"
            p += "<param><value><string>1</string></value></param>"
            p += "<param><value><string>-mindepth</string></value></param>"
            p += "<param><value><string>1</string></value></param>"
            return p
        case LoadURL(let url):
            return "<param><value><string>\(url)</string></value></param>"
        case Filename(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Hash(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Date(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Size(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case SizeCompleted(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case SizeLeft(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case SizeUP(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Path(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Directory(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case SpeedDL(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case SpeedUP(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Leechers(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Seeders(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Ratio(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case State(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case Message(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .IsActive(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .IsOpen(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .Views(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .NumberOfFiles(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .NumberOfTrackers(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .Pause(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .Resume(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .Start(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .Stop(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case .Erase(let hash):
            return "<param><value><string>\(hash)</string></value></param>"
        case DMultiCall(let view, let array):
            p += "<param><value><string>\(view)</string></value></param>"
            for item in array {
                p += "<param><value><string>\(item.methodName)=</string></value></param>"
            }
            return p
        case .FilesName(let hashF):
            return "<param><value><string>\(hashF)</string></value></param>"
        case .FilesSize(let hashF):
            return "<param><value><string>\(hashF)</string></value></param>"
        case FMultiCall(let hash, let array):
            p += "<param><value><string>\(hash)</string></value></param><param><value><string></string></value></param>"
            for item in array {
                p += "<param><value><string>\(item.methodName)=</string></value></param>"
            }
            return p
        case .TrackerURL(let hashT):
            return "<param><value><string>\(hashT)</string></value></param>"
        case .TrackerSeeders(let hashT):
            return "<param><value><string>\(hashT)</string></value></param>"
        case .TrackerLeechers(let hashT):
            return "<param><value><string>\(hashT)</string></value></param>"
        case .TMultiCall(let hash, let array):
            p += "<param><value><string>\(hash)</string></value></param>"
            p += "<param><value><string></string></value></param>"
            for item in array {
                p += "<param><value><string>\(item.methodName)=</string></value></param>"
            }
            return p
        }
    }
    
    var body: String {
        var b = "<?xml version=\"1.0\"?><methodCall><methodName>\(self.methodName)</methodName><params>"
        if let param = self.param {
            b += param
        }
        b += "</params></methodCall>"
        //        print(b)
        //        print("\n")
        return b
    }
    
}

