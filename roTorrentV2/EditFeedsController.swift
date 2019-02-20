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

    @IBAction func done(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.feeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath)
        let feed = manager.feeds[indexPath.row]
        cell.textLabel?.text = feed.title
        cell.detailTextLabel?.text = feed.link.absoluteString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let feed = self.manager.feeds[indexPath.row]
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            self.manager.removeFeed(feed)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        delete.backgroundColor = UIColor.red
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            self.performSegue(withIdentifier: "AddRss", sender: feed)
        }
        edit.backgroundColor = UIColor.orange
        let enable = UITableViewRowAction(style: .default, title: "Enable") { action, index in
            
        }
        enable.backgroundColor = UIColor.blue
        return [delete,edit]
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddRss" {
            let navBar = segue.destination as! UINavigationController
            let addRss = navBar.topViewController as! AddRSSController
            addRss.delegate = self
            if let feed = sender as? RSSFeed {
                addRss.feedToEdit = feed
            }
        }
    }
}

extension EditFeedsController: AddRSSDelegate {
    func addFeed(_ feed: RSSFeed, sender: AnyObject) {
        self.manager.appendRSS(feed)
        self.tableView.reloadData()
    }
    
    func editFeed(_ feed: RSSFeed, sender: AnyObject) {
        self.manager.updateFeeds()
        self.tableView.reloadData()
    }
}
