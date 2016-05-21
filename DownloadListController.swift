//
//  DownloadListController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class DownloadListController: UITableViewController {
    
    var torrents = Torrents()
    var manager: Manager!
    let cellId = "TorrentCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TabBarManagerController
        self.manager = tabBar.manager

        let nib = UINib(nibName: cellId, bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: cellId)
        self.tableView.rowHeight = 78

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(DownloadListController.refresh(_:)), forControlEvents: .ValueChanged)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return torrents.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TorrentCell
        cell.configureForTorrent(torrents[indexPath.row])
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
