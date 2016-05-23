//
//  DownloadListController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class DownloadListController: UITableViewController {
    
    var delegate: DownloadListControllerDelegate?
    var torrents = Torrents()
    var manager: Manager!
    let cellId = "TorrentCell"
    
    var searchBar: UISearchBar!
    var recognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tabBar = self.tabBarController as! TabBarManagerController
//        self.manager = tabBar.manager

        let nib = UINib(nibName: cellId, bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: cellId)
        self.tableView.rowHeight = 78

        let mainRect = UIScreen.mainScreen().bounds
        searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: mainRect.width-20,height: 56))
        searchBar.delegate = self
        searchBar.placeholder = "Search Torrent"
        searchBar.enablesReturnKeyAutomatically = false
        tableView.tableHeaderView = searchBar
        tableView.contentOffset = CGPointMake(0, searchBar.frame.size.height)

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(DownloadListController.refresh(_:)), forControlEvents: .ValueChanged)
        
        recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(DownloadListController.filter(_:)))
        recognizer.edges = .Left
        view.addGestureRecognizer(recognizer)

        refresh(self)
    }
    
    func refresh(sender: AnyObject) {
        self.refreshControl?.endRefreshing()
        let call = manager.callToInitList()
        manager.call(call) {response in
            switch response {
            case .Success(let xmltype):
                dispatch_async(dispatch_get_main_queue()) {
                    self.torrents.initWithXmlArray(xmltype)
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(ok)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func filter(sender: AnyObject) {
        if (sender as! NSObject) != recognizer {
            delegate?.toggleFilterPanel(nil)
        } else {
            delegate?.toggleFilterPanel(recognizer)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfTorrentToDispplay()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TorrentCell
        let torrent = torrentAtIndexPath(indexPath)
        cell.configureForTorrent(torrent)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DownloadListController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func numberOfTorrentToDispplay() -> Int {
        if let searchText = searchBar.text {
            return torrents.filter { $0.match(searchText) }.count
        } else {
            return torrents.count
        }
    }
    
    func torrentAtIndexPath(indexPath: NSIndexPath) -> Torrent {
        if let searchText = searchBar.text {
            return torrents.filter { $0.match(searchText) }[indexPath.row]
        } else {
            return torrents[indexPath.row]
        }
    }
}

protocol DownloadListControllerDelegate {
    func toggleFilterPanel(edgeRecognizer: UIScreenEdgePanGestureRecognizer?)
}
