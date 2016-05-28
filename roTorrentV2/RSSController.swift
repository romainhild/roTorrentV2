//
//  RSSController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class RSSController: UITableViewController {
    
    var delegate: RSSControllerDelegate!
    
    var manager: Manager!
    
    var searchBar: UISearchBar!
    var recognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(RSSController.refresh(_:)), forControlEvents: .ValueChanged)
        
        let mainRect = UIScreen.mainScreen().bounds
        searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: mainRect.width-20,height: 56))
        searchBar.delegate = self
        searchBar.placeholder = "Search Item"
        searchBar.enablesReturnKeyAutomatically = false
        tableView.tableHeaderView = searchBar
        tableView.contentOffset = CGPointMake(0, searchBar.frame.size.height)
        
        recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(RSSController.toggleFilter(_:)))
        recognizer.edges = .Left
        view.addGestureRecognizer(recognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func edit(sender: AnyObject) {
        self.performSegueWithIdentifier("EditFeeds", sender: self)
    }
    
    @IBAction func toggleFilter(sender: AnyObject) {
        if (sender as! NSObject) != recognizer {
            delegate?.toggleFilterPanel(nil)
        } else {
            delegate?.toggleFilterPanel(recognizer)
        }
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
        if item.hasBeenAdded {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = manager.itemToDisplayAtIndexPath(indexPath, thatMatch: searchBar.text)
        let torrent = item.title
        let url = item.link
        let actionSheet = UIAlertController(title: "Add Torrent", message: torrent, preferredStyle: .ActionSheet)
        let add = UIAlertAction(title: "Add", style: .Default) { action in
            let call = RTorrentCall.AddTorrent(url.absoluteString, "")
            self.manager.call(call) { response in
                switch response {
                case .Success:
                    item.hasBeenAdded = true
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                default:
                    break
                }
            }
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
        if segue.identifier == "EditFeeds" {
            let navBar = segue.destinationViewController as! UINavigationController
            let editFeeds = navBar.topViewController as! EditFeedsController
            editFeeds.manager = self.manager
        } else if segue.identifier == "ThroughFolder" {
            let navBar = segue.destinationViewController as! UINavigationController
            let throughFolder = navBar.topViewController as! ThroughFolderController
            throughFolder.manager = self.manager
            throughFolder.item = sender as? RSSItem
            throughFolder.delegate = self
        }
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

extension RSSController: ThroughFolderDelegate {
    func controllerDidCancel(controller: ThroughFolderController) {
        
    }
    
    func controller(controller: ThroughFolderController, didChooseDirectory directory: String, forItem item: RSSItem) {
        let call = RTorrentCall.AddTorrent(item.link.absoluteString, directory)
        self.manager.call(call) { response in }
        item.hasBeenAdded = true
        self.tableView.reloadData()

    }
}

protocol RSSControllerDelegate {
    func toggleFilterPanel(edgeRecognizer: UIScreenEdgePanGestureRecognizer?)
    func addFilterPanelController()
    func animateFilterPanel(shouldExpand: Bool)
}
