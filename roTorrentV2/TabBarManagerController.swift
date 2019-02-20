//
//  TabBarManagerController.swift
//  roTorrent
//
//  Created by Romain Hild on 19/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class TabBarManagerController: UITabBarController {
    
    var manager: Manager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadManager()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func save() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(manager, forKey: "manager")
        archiver.finishEncoding()
        data.write(toFile: prefPath(), atomically: true)
    }
    
    func loadManager() {
        let path = prefPath()
        if FileManager.default.fileExists(atPath: path) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                manager = unarchiver.decodeObject(forKey: "manager") as! Manager
                unarchiver.finishDecoding()
            }
        } else {
            manager = Manager()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
