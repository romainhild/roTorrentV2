//
//  DetailTorrentController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 23/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class DetailTorrentController: UITableViewController {
    
    var manager: Manager!
    var torrent: Torrent!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var seedersLabel: UILabel!
    @IBOutlet weak var leechersLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var upLabel: UILabel!
    @IBOutlet weak var dlLabel: UILabel!
    @IBOutlet weak var directoryLabel: UILabel!
    @IBOutlet weak var filesLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var trackersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = torrent.name
        ratioLabel.text = String(torrent.ratio)
        sizeLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.size, countStyle: NSByteCountFormatterCountStyle.File)
        downloadLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.sizeCompleted, countStyle: NSByteCountFormatterCountStyle.File)
        uploadLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.sizeUP, countStyle: NSByteCountFormatterCountStyle.File)
        leftLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.sizeLeft, countStyle: NSByteCountFormatterCountStyle.File)
        dateLabel.text = ShortFormatterSingleton.sharedInstance.stringFromDate(torrent.date)
        hashLabel.text = torrent.hashT
        updateSeedersLeechersLabels()
        
        messageLabel.text = ""
        if let msg = torrent.message {
            stateLabel.text = "Error"
            messageLabel.text = msg
        } else if torrent.isActive == 0 {
            stateLabel.text = "Pause"
        } else if torrent.state == 0 {
            stateLabel.text = "Pause"
        } else {
            stateLabel.text = "Active"
        }
        dlLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.speedDL, countStyle: NSByteCountFormatterCountStyle.File)
        upLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.speedUP, countStyle: NSByteCountFormatterCountStyle.File)
        
        directoryLabel.text = torrent.directory
        pathLabel.text = torrent.path
        filesLabel.text = String(torrent.numberOfFiles)
        let fileCell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 3))
        let myBgView = UIView(frame: CGRectZero)
        myBgView.backgroundColor = UIColor.blackColor()
        fileCell.backgroundView = myBgView
        fileCell.accessoryType = .DisclosureIndicator
        
        trackersLabel.text = String(torrent.numberOfTrackers)
        let trackerCell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 4))
        let myBgView2 = UIView(frame: CGRectZero)
        myBgView2.backgroundColor = UIColor.blackColor()
        trackerCell.backgroundView = myBgView2
        trackerCell.accessoryType = .DisclosureIndicator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func edit(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Edit Torrent", message: torrent.name, preferredStyle: .ActionSheet)
        let pause = UIAlertAction(title: "Pause", style: .Default) { action in
            let call = RTorrentCall.Stop(self.torrent.hashT)
            self.manager.call(call) { response in }
        }
        actionSheet.addAction(pause)
        let start = UIAlertAction(title: "Start", style: .Default) { action in
            let call = RTorrentCall.Start(self.torrent.hashT)
            self.manager.call(call) { response in }
        }
        actionSheet.addAction(start)
        let erase = UIAlertAction(title: "Erase", style: .Destructive) { action in
            let alert = UIAlertController(title: "Really erase this torrent?", message: self.torrent.name, preferredStyle: .Alert)
            let yes = UIAlertAction(title: "Yes", style: .Default) { action in
                let call = RTorrentCall.Erase(self.torrent.hashT)
                self.manager.call(call) { response in }
            }
            alert.addAction(yes)
            let no = UIAlertAction(title: "No", style: .Cancel, handler: nil)
            alert.addAction(no)
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(erase)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionSheet.addAction(cancel)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func refresh(sender: AnyObject) {
        if let torrent = self.torrent {
            let call = manager.callToInitList(torrent.hashT)
            manager.call(call) { response in
                
            }
        }
    }
    
    func updateSeedersLeechersLabels() {
        if let allSeeders = torrent.allSeeders {
            seedersLabel.text = "\(torrent.seeders)(\(allSeeders))"
        } else {
            seedersLabel.text = String(torrent.seeders)
        }
        if let allLeechers = torrent.allLeechers {
            leechersLabel.text = "\(torrent.leechers)(\(allLeechers))"
        } else {
            leechersLabel.text = String(torrent.leechers)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 3 && indexPath.row == 2 {
            performSegueWithIdentifier("DirTracker", sender: true)
        } else if indexPath.section == 4 && indexPath.row == 0 {
            performSegueWithIdentifier("DirTracker", sender: false)
        }
        return nil
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

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! DirTrackerController
        controller.manager = self.manager
        controller.torrent = self.torrent
        controller.isDir = sender as! Bool
        controller.delegate = self
    }
}

extension DetailTorrentController: DirTrackerControllerDelegate {
    func trackersHaveBeenInitialized() {
        updateSeedersLeechersLabels()
    }
}
