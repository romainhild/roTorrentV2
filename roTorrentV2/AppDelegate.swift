//
//  AppDelegate.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let color = UIColor(red: 0, green: 122.0/255, blue: 1.0, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : color ]
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        saveData()
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        saveData()
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let urlToUse: NSURL
        if let ext = url.pathExtension where ext == "bittorrent" {
            if let urlWithoutBittorrent = url.URLByDeletingPathExtension, newExt = urlWithoutBittorrent.pathExtension where newExt == "torrent" {
                urlToUse = urlWithoutBittorrent
            } else {
                print("type of file not correct")
                do {
                    try fileManager.removeItemAtURL(url)
                } catch {}
                return false
            }
        } else {
            urlToUse = url
        }
        if let path = urlToUse.path {
            if let data = NSFileManager.defaultManager().contentsAtPath(path) {
                let stringData = data.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                let tabBarController = window!.rootViewController as! TabBarManagerController
                let manager = tabBarController.manager
                let call = RTorrentCall.AddTorrentRaw(stringData)
                manager.call(call) { response in }
            }
        }
        do {
            try fileManager.removeItemAtURL(url)
        } catch {}
        return true
    }

    func saveData() {
        let tabBarController = window!.rootViewController as! TabBarManagerController
        tabBarController.save()
    }
}

