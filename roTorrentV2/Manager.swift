//
//  Manager.swift
//  roTorrent
//
//  Created by Romain Hild on 18/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

enum Response<SuccessType, FailureType>
{
    case Success(SuccessType)
    case Failure(FailureType)
}

class Manager: NSObject, NSCoding {
    
    let urlComponents: NSURLComponents
    var url: NSURL? {
        return urlComponents.URL
    }
    let session = NSURLSession.sharedSession()
    var mutableRequest: NSMutableURLRequest?
    var dataTask: NSURLSessionDataTask?
    
    override init() {
        urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
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
        super.init()
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
    }
    
    func call(call: RTorrentCall, completionHandler: Response<XMLRPCType,NSError> -> Void) {
        if let task = dataTask {
            task.cancel()
            print("canceled")
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
            print("url : \(url)")
            mutableRequest = NSMutableURLRequest(URL: url)
            mutableRequest!.setValue("text/xml", forHTTPHeaderField: "Content-Type")
            mutableRequest!.setValue("roTorrent", forHTTPHeaderField: "User-Agent")
            mutableRequest!.setValue(String(length), forHTTPHeaderField: "Current-Length")
            mutableRequest!.HTTPBody = bodyData
            mutableRequest!.HTTPMethod = "POST"
        }
    }
    
    func callToInitList() -> RTorrentCall {
        let list = [RTorrentCall.Filename(""), RTorrentCall.Hash(""), RTorrentCall.Date(""), RTorrentCall.Ratio(""), RTorrentCall.Size(""), RTorrentCall.SizeCompleted(""), RTorrentCall.SizeLeft(""), RTorrentCall.SizeUP(""), RTorrentCall.Path(""), RTorrentCall.Directory(""), RTorrentCall.SpeedDL(""), RTorrentCall.SpeedUP(""), RTorrentCall.Leechers(""), RTorrentCall.Seeders(""), RTorrentCall.State(""), RTorrentCall.IsActive(""), RTorrentCall.Message(""), RTorrentCall.NumberOfFiles(""), RTorrentCall.NumberOfTrackers("")]
        return RTorrentCall.DMultiCall("main", list)
    }
}
