//
//  DirTrackerController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 24/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class DirTrackerController: UITableViewController {
    
    var delegate: DirTrackerControllerDelegate?
    var manager: Manager!
    var torrent: Torrent!
    var isDir: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        if isDir {
            self.navigationItem.title = "Files"
        } else {
            self.navigationItem.title = "Trackers"
        }
        if isDir && torrent.listOfFiles.count != torrent.numberOfFiles {
            let call = manager.callToInitFilesForTorrent(torrent)
            manager.call(call) { response in
                switch response {
                case .Success(let xmltype):
                    self.torrent.initFiles(xmltype)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                case .Failure(let error):
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "Failed to init files", message: error.localizedDescription, preferredStyle: .Alert)
                        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        alert.addAction(ok)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        } else if !isDir && torrent.listOfTrackers.count != torrent.numberOfTrackers {
            let call = manager.callToInitTrackersForTorrent(torrent)
            manager.call(call) { response in
                switch response {
                case .Success(let xmltype):
                    self.torrent.initTrackers(xmltype)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.trackersHaveBeenInitialized()
                        self.tableView.reloadData()
                    }
                case .Failure(let error):
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "Failed to init trackers", message: error.localizedDescription, preferredStyle: .Alert)
                        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        alert.addAction(ok)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDir {
            return torrent.listOfFiles.count
        } else {
            return torrent.listOfTrackers.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DirTrackerCell", forIndexPath: indexPath)

        let mainLabel = cell.viewWithTag(1) as! UILabel
        let detailLabel = cell.viewWithTag(2) as! UILabel
        if isDir {
            mainLabel.text = torrent.listOfFiles[indexPath.row]
            detailLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.listOfFilesSize[indexPath.row], countStyle: NSByteCountFormatterCountStyle.File)
        } else {
            mainLabel.text = torrent.listOfTrackers[indexPath.row]
            detailLabel.text = "S/L: \(torrent.listOfTrackersSeeders[indexPath.row])/\(torrent.listOfTrackersLeechers[indexPath.row])"
        }

        return cell
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

protocol DirTrackerControllerDelegate {
    func trackersHaveBeenInitialized()
}
