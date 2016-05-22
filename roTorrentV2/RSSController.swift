//
//  RSSController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class RSSController: UITableViewController {
    
    var manager: Manager!
    
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TabBarManagerController
        self.manager = tabBar.manager

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(RSSController.refresh(_:)), forControlEvents: .ValueChanged)
        
        let mainRect = UIScreen.mainScreen().bounds
        searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: mainRect.width-20,height: 56))
        searchBar.delegate = self
        searchBar.placeholder = "Search Item"
        searchBar.enablesReturnKeyAutomatically = false
        tableView.tableHeaderView = searchBar
        tableView.contentOffset = CGPointMake(0, searchBar.frame.size.height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func edit(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Edit RSS Feeds", message: nil, preferredStyle: .ActionSheet)
        let add = UIAlertAction(title: "Add", style: .Default) { action in
            self.performSegueWithIdentifier("AddRSS", sender: self)
        }
        actionSheet.addAction(add)
        let remove = UIAlertAction(title: "Remove...", style: .Default) { action in
        
        }
        actionSheet.addAction(remove)
        let removeAll = UIAlertAction(title: "Remove All", style: .Destructive) { action in
            self.manager.removeFeed(nil)
            self.tableView.reloadData()
        }
        actionSheet.addAction(removeAll)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func refresh(sender: AnyObject) {
        refreshControl?.endRefreshing()
        manager.updateFeeds()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOtItemsToDisplay(searchBar.text)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RSSCell", forIndexPath: indexPath)
        let item = manager.itemToDisplayAtIndexPath(indexPath, thatMatch: searchBar.text)
        cell.textLabel?.text = item.title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = manager.itemToDisplayAtIndexPath(indexPath, thatMatch: searchBar.text)
        let torrent = item.title
        let url = item.link
        let actionSheet = UIAlertController(title: "Add Torrent", message: torrent, preferredStyle: .ActionSheet)
        let add = UIAlertAction(title: "Add", style: .Default) { action in
            let call = RTorrentCall.AddTorrent(url.absoluteString, "")
            self.manager.call(call) { response in }
        }
        actionSheet.addAction(add)
        let addFolder = UIAlertAction(title: "Add in a directory...", style: .Default) { action in
            self.performSegueWithIdentifier("ThroughFolder", sender: item)
        }
        actionSheet.addAction(addFolder)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionSheet.addAction(cancel)
        presentViewController(actionSheet, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
   // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddRSS" {
            let navBar = segue.destinationViewController as! UINavigationController
            let addRss = navBar.topViewController as! AddRSSController
            addRss.delegate = self
        } else if segue.identifier == "ThroughFolder" {
            let navBar = segue.destinationViewController as! UINavigationController
            let throughFolder = navBar.topViewController as! ThroughFolderController
            throughFolder.manager = self.manager
            throughFolder.item = sender as? RSSItem
        }
    }

}

extension RSSController: AddRSSDelegate {
    func addFeed(feed: RSSFeed, sender: AnyObject) {
        self.manager.appendRSS(feed)
        self.tableView.reloadData()
    }
}

extension RSSController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}
