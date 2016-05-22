//
//  ThroughFolderController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 21/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class ThroughFolderController: UITableViewController {
    
    var delegate: ThroughFolderDelegate?
    var manager: Manager!
    var item: RSSItem!
    var folders = [String]()
    var currentDir: String? {
        didSet {
            if let currentDir = currentDir {
                let call = RTorrentCall.ListDirectories(currentDir)
                manager.call(call) { response in
                    switch response {
                    case .Success(let xmltype):
                        switch xmltype {
                        case .XMLRPCString(let listAsString):
                            self.folders = NSString(string: listAsString).componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                            for i in 0..<self.folders.count {
                                if self.folders[i].isEmpty {
                                    self.folders.removeAtIndex(i)
                                }
                            }
                            self.folders.sortInPlace { $0 < $1 }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if currentDir == nil {
            let call = RTorrentCall.BaseDirectory
            manager.call(call) { response in
                switch response {
                case .Success(let xmltype):
                    switch xmltype {
                    case .XMLRPCString(let dir):
                        self.currentDir = dir
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Do you want to choose this directory ?", message: currentDir, preferredStyle: .ActionSheet)
        let ok = UIAlertAction(title: "Yes", style: .Default) { action in
            let call = RTorrentCall.AddTorrent(self.item.link.absoluteString, self.currentDir!)
            self.manager.call(call) { response in }
            self.item.hasBeenAdded = true
            self.delegate?.controller(self, didAddItem: self.item)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheet.addAction(ok)
        let no = UIAlertAction(title: "No", style: .Default, handler: nil)
        actionSheet.addAction(no)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheet.addAction(cancel)
        presentViewController(actionSheet, animated: true, completion: nil)
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
        return folders.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DirCell", forIndexPath: indexPath)

        let dir = folders[indexPath.row]
        if let dirAsURL = NSURL(string: dir), path = dirAsURL.lastPathComponent {
            cell.textLabel?.text = path
        } else {
            cell.textLabel?.text = dir
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NextDir" {
            let cell = sender as! UITableViewCell
            let index = tableView.indexPathForCell(cell)
            let dir = folders[index!.row]
            let controller = segue.destinationViewController as! ThroughFolderController
            controller.manager = self.manager
            controller.item = self.item
            controller.currentDir = dir
            controller.delegate = self.delegate
        }
    }

}

protocol ThroughFolderDelegate {
    func controller(controller: ThroughFolderController, didAddItem item: RSSItem)
}
