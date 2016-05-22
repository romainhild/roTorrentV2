//
//  RemoveFeedController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 22/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class EditFeedsController: UITableViewController {
    
    var manager: Manager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.feeds.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath)
        let feed = manager.feeds[indexPath.row]
        cell.textLabel?.text = feed.title
        cell.detailTextLabel?.text = feed.link.absoluteString
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let feed = self.manager.feeds[indexPath.row]
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
            self.manager.removeFeed(feed)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        delete.backgroundColor = UIColor.redColor()
        let edit = UITableViewRowAction(style: .Default, title: "Edit") { action, index in
            self.performSegueWithIdentifier("AddRSS", sender: feed)
        }
        edit.backgroundColor = UIColor.orangeColor()
        let enable = UITableViewRowAction(style: .Default, title: "Enable") { action, index in
            
        }
        enable.backgroundColor = UIColor.blueColor()
        return [delete,edit]
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddRSS" {
            let navBar = segue.destinationViewController as! UINavigationController
            let addRss = navBar.topViewController as! AddRSSController
            addRss.delegate = self
            if let feed = sender as? RSSFeed {
                addRss.feedToEdit = feed
            }
        }
    }
}

extension EditFeedsController: AddRSSDelegate {
    func addFeed(feed: RSSFeed, sender: AnyObject) {
        self.manager.appendRSS(feed)
        self.tableView.reloadData()
    }
    
    func editFeed(feed: RSSFeed, sender: AnyObject) {
        self.manager.updateFeeds()
        self.tableView.reloadData()
    }
}