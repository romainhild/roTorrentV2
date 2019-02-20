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
        sizeLabel.text = ByteCountFormatter.string(fromByteCount: torrent.size, countStyle: ByteCountFormatter.CountStyle.file)
        downloadLabel.text = ByteCountFormatter.string(fromByteCount: torrent.sizeCompleted, countStyle: ByteCountFormatter.CountStyle.file)
        uploadLabel.text = ByteCountFormatter.string(fromByteCount: torrent.sizeUP, countStyle: ByteCountFormatter.CountStyle.file)
        leftLabel.text = ByteCountFormatter.string(fromByteCount: torrent.sizeLeft, countStyle: ByteCountFormatter.CountStyle.file)
        dateLabel.text = ShortFormatterSingleton.sharedInstance.stringFromDate(torrent.date)
        hashLabel.text = torrent.hashT
        
        updateSeedersLeechersLabels()
        updateStateLabels()
        
        dlLabel.text = ByteCountFormatter.string(fromByteCount: torrent.speedDL, countStyle: ByteCountFormatter.CountStyle.file)
        upLabel.text = ByteCountFormatter.string(fromByteCount: torrent.speedUP, countStyle: ByteCountFormatter.CountStyle.file)
        
        directoryLabel.text = torrent.directory
        pathLabel.text = torrent.path
        filesLabel.text = String(torrent.numberOfFiles)
        let fileCell = super.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 3))
        let myBgView = UIView(frame: CGRect.zero)
        myBgView.backgroundColor = UIColor.black
        fileCell.backgroundView = myBgView
        fileCell.accessoryType = .disclosureIndicator
        
        trackersLabel.text = String(torrent.numberOfTrackers)
        let trackerCell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 4))
        let myBgView2 = UIView(frame: CGRect.zero)
        myBgView2.backgroundColor = UIColor.black
        trackerCell.backgroundView = myBgView2
        trackerCell.accessoryType = .disclosureIndicator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func edit(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Edit Torrent", message: torrent.name, preferredStyle: .actionSheet)
        let setDir = UIAlertAction(title: "Set Directory", style: .default) { action in
            self.performSegue(withIdentifier: "ChooseDir", sender: self.torrent)
        }
        actionSheet.addAction(setDir)
        let pause = UIAlertAction(title: "Pause", style: .default) { action in
            let call = RTorrentCall.stop(self.torrent.hashT)
            self.manager.call(call) { response in
                DispatchQueue.main.async {
                    self.refreshState()
                }
            }
        }
        actionSheet.addAction(pause)
        let start = UIAlertAction(title: "Start", style: .default) { action in
            let call = RTorrentCall.start(self.torrent.hashT)
            self.manager.call(call) { response in
                DispatchQueue.main.async {
                    self.refreshState()
                }
            }
        }
        actionSheet.addAction(start)
        let erase = UIAlertAction(title: "Erase", style: .destructive) { action in
            let alert = UIAlertController(title: "Really erase this torrent?", message: self.torrent.name, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default) { action in
                let call = RTorrentCall.erase(self.torrent.hashT)
                self.manager.call(call) { response in }
            }
            alert.addAction(yes)
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(no)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(erase)
        let eraseAndDelete = UIAlertAction(title: "Erase and Delete", style: .destructive) { action in
            let alert = UIAlertController(title: "Really erase this torrent and all its files?", message: self.torrent.name, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default) { action in
                let call = self.manager.callToEraseAndDelete(self.torrent)
                self.manager.call(call) { response in }
            }
            alert.addAction(yes)
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(no)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(eraseAndDelete)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func refreshState() {
        if let torrent = self.torrent {
            let call = manager.callToRefreshState(torrent)
            manager.call(call) { response in
                switch response {
                case .success(let xmltype):
                    torrent.refreshState(xmltype)
                    DispatchQueue.main.async {
                        self.updateStateLabels()
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(ok)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func refreshDirAndPath() {
        if let torrent = self.torrent {
            let call = manager.callTorRefreshDirAndPath(torrent)
            manager.call(call) { response in
                switch response {
                case .success(let xmltype):
                    torrent.refreshDirAndPath(xmltype)
                    DispatchQueue.main.async {
                        self.directoryLabel.text = torrent.directory
                        self.pathLabel.text = torrent.path
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(ok)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
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
    
    func updateStateLabels() {
        messageLabel.text = ""
        if let msg = torrent.message {
            stateLabel.text = "Error"
            messageLabel.text = msg
        } else if torrent.state == 0 {
            stateLabel.text = "Pause"
        } else {
            stateLabel.text = "Active"
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 3 && indexPath.row == 2 {
            performSegue(withIdentifier: "DirTracker", sender: true)
        } else if indexPath.section == 4 && indexPath.row == 0 {
            performSegue(withIdentifier: "DirTracker", sender: false)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DirTracker" {
            let controller = segue.destination as! DirTrackerController
            controller.manager = self.manager
            controller.torrent = self.torrent
            controller.isDir = sender as! Bool
            controller.delegate = self
        } else if segue.identifier == "ChooseDir" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ThroughFolderController
            controller.delegate = self
            controller.torrent = sender as? Torrent
            controller.manager = self.manager
        }
    }
}

extension DetailTorrentController: DirTrackerControllerDelegate {
    func trackersHaveBeenInitialized() {
        updateSeedersLeechersLabels()
    }
}

extension DetailTorrentController: ThroughFolderDelegate {
    func controllerDidCancel(_ controller: ThroughFolderController) {
        
    }
    
    func controller(_ controller: ThroughFolderController, didChooseDirectory directory: String, forTorrent torrent: Torrent) {
        let call = manager.callToMoveTorrent(torrent, inNewDirectory: directory)
        manager.call(call) { response in
            self.refreshDirAndPath()
        }
    }
}
