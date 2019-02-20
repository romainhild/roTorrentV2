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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let color = UIColor(red: 0, green: 122.0/255, blue: 1.0, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : color ]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        saveData()
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveData()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let fileManager = FileManager.default
        let urlToUse: URL
        if let ext = url.pathExtension, ext == "bittorrent" {
            if let urlWithoutBittorrent = url.deletingPathExtension(), let newExt = urlWithoutBittorrent.pathExtension, newExt == "torrent" {
                urlToUse = urlWithoutBittorrent
            } else {
                print("type of file not correct")
                do {
                    try fileManager.removeItem(at: url)
                } catch {}
                return false
            }
        } else {
            urlToUse = url
        }
        if let path = urlToUse.path {
            if let data = FileManager.default.contents(atPath: path) {
                let stringData = data.base64EncodedString(options: .lineLength64Characters)
                let tabBarController = window!.rootViewController as! TabBarManagerController
                let manager = tabBarController.manager
                let call = RTorrentCall.addTorrentRaw(stringData)
                manager.call(call) { response in }
            }
        }
        do {
            try fileManager.removeItem(at: url)
        } catch {}
        return true
    }

    func saveData() {
        let tabBarController = window!.rootViewController as! TabBarManagerController
        tabBarController.save()
    }
}

