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
    var indexSelected: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.feeds.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var indexOfFeed: Int?
        if let feed = manager.feedToDisplay, let index = manager.feeds.index(of: feed) {
            indexOfFeed = index + 1
        }

        let string: String
        if indexPath.row == 0 {
            string = "All"
        } else {
            string = manager.feeds[indexPath.row - 1].title
        }

        let range = (string as NSString).range(of: string)
        let attributedString = NSMutableAttributedString(string: string)
        
        if let indexOfFeed = indexOfFeed, indexOfFeed == indexPath.row {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 20), range: range)
            attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        } else if indexOfFeed == nil && indexPath.row == 0 {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 20), range: range)
            attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        } else {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: range)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.textLabel?.attributedText = attributedString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "RSS Feeds"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44+20
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            manager.feedToDisplay = nil
        } else {
            manager.feedToDisplay = manager.feeds[indexPath.row-1]
        }
        tableView.reloadData()
        return nil
    }

}
