//
//  RSSFilterController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 22/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class RSSFilterController: UITableViewController {

    var manager: Manager!
    var indexSelected: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.feeds.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var indexOfFeed: Int?
        if let feed = manager.feedToDisplay, index = manager.feeds.indexOf(feed) {
            indexOfFeed = index + 1
        }

        let string: String
        if indexPath.row == 0 {
            string = "All"
        } else {
            string = manager.feeds[indexPath.row - 1].title
        }

        let range = (string as NSString).rangeOfString(string)
        let attributedString = NSMutableAttributedString(string: string)
        
        if let indexOfFeed = indexOfFeed where indexOfFeed == indexPath.row {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(20), range: range)
            attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: range)
        } else if indexOfFeed == nil && indexPath.row == 0 {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(20), range: range)
            attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: range)
        } else {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(16), range: range)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FilterCell", forIndexPath: indexPath)
        cell.textLabel?.attributedText = attributedString
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "RSS Feeds"
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44+20
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            manager.feedToDisplay = nil
        } else {
            manager.feedToDisplay = manager.feeds[indexPath.row-1]
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }

}
