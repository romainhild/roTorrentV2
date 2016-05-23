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
    @IBOutlet weak var trackersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Details"
        
        nameLabel.text = torrent.name
        ratioLabel.text = String(torrent.ratio)
        sizeLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.size, countStyle: NSByteCountFormatterCountStyle.File)
        downloadLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.sizeCompleted, countStyle: NSByteCountFormatterCountStyle.File)
        uploadLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.sizeUP, countStyle: NSByteCountFormatterCountStyle.File)
        leftLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.sizeLeft, countStyle: NSByteCountFormatterCountStyle.File)
        dateLabel.text = ShortFormatterSingleton.sharedInstance.stringFromDate(torrent.date)
        hashLabel.text = torrent.hashT
        seedersLabel.text = String(torrent.seeders)
        leechersLabel.text = String(torrent.leechers)
        
        messageLabel.text = ""
        if let msg = torrent.message {
            stateLabel.text = "Error"
            messageLabel.text = msg
        } else if torrent.isActive == 0 {
            stateLabel.text = "Stopped"
        } else if torrent.state == 0 {
            stateLabel.text = "Paused"
        } else {
            stateLabel.text = "Active"
        }
        dlLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.speedDL, countStyle: NSByteCountFormatterCountStyle.File)
        upLabel.text = NSByteCountFormatter.stringFromByteCount(torrent.speedUP, countStyle: NSByteCountFormatterCountStyle.File)
        
        directoryLabel.text = torrent.directory
        filesLabel.text = String(torrent.numberOfFiles)
        let fileCell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        let myBgView = UIView(frame: CGRectZero)
        myBgView.backgroundColor = UIColor.blackColor()
        fileCell.backgroundView = myBgView
        fileCell.accessoryType = .DisclosureIndicator
        
        trackersLabel.text = String(torrent.numberOfTrackers)
        let trackerCell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        let myBgView2 = UIView(frame: CGRectZero)
        myBgView2.backgroundColor = UIColor.blackColor()
        trackerCell.backgroundView = myBgView2
        trackerCell.accessoryType = .DisclosureIndicator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
//    }

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
