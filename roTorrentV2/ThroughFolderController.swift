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
    var item: RSSItem?
    var url: String?
    var torrent: Torrent?

    var folders = [String]()
        
    var currentDir: String? {
        didSet {
            if let currentDir = currentDir {
                let call = RTorrentCall.listDirectories(currentDir)
                manager.call(call) { response in
                    switch response {
                    case .success(let xmltype):
                        switch xmltype {
                        case .xmlrpcString(let listAsString):
                            self.folders = NSString(string: listAsString).components(separatedBy: CharacterSet.newlines)
                            for i in 0..<self.folders.count {
                                if self.folders[i].isEmpty {
                                    self.folders.remove(at: i)
                                }
                            }
                            self.folders.sort { $0 < $1 }
                            DispatchQueue.main.async {
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
            let call = RTorrentCall.baseDirectory
            manager.call(call) { response in
                switch response {
                case .success(let xmltype):
                    switch xmltype {
                    case .xmlrpcString(let dir):
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
    
    @IBAction func done(_ sender: AnyObject) {
        if let currentDir = self.currentDir {
            let actionSheet = UIAlertController(title: "Do you want to choose this directory ?", message: currentDir, preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "Yes", style: .default) { action in
                if let item = self.item {
                    self.delegate?.controller?(self, didChooseDirectory: self.currentDir!, forItem: item)
                } else if let url = self.url {
                    self.delegate?.controller?(self, didChooseDirectory: self.currentDir!, forURL: url)
                } else if let torrent = self.torrent {
                    self.delegate?.controller?(self, didChooseDirectory: self.currentDir!, forTorrent: torrent)
                }
                self.dismiss(animated: true, completion: nil)
            }
            actionSheet.addAction(ok)
            let no = UIAlertAction(title: "No", style: .default, handler: nil)
            actionSheet.addAction(no)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
                self.dismiss(animated: true, completion: nil)
            }
            actionSheet.addAction(cancel)
            present(actionSheet, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirCell", for: indexPath)

        let dir = folders[indexPath.row]
        if let dirAsURL = URL(string: dir), let path = dirAsURL.lastPathComponent {
            cell.textLabel?.text = path
        } else {
            cell.textLabel?.text = dir
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextDir" {
            let cell = sender as! UITableViewCell
            let index = tableView.indexPath(for: cell)
            let dir = folders[index!.row]
            let controller = segue.destination as! ThroughFolderController
            controller.manager = self.manager
            if let item = self.item {
                controller.item = item
            }
            if let url = self.url {
                controller.url = url
            }
            if let torrent = self.torrent {
                controller.torrent = torrent
            }
            controller.currentDir = dir
            controller.delegate = self.delegate
        }
    }

}

@objc protocol ThroughFolderDelegate {
    func controllerDidCancel(_ controller: ThroughFolderController)
    @objc optional func controller(_ controller: ThroughFolderController, didChooseDirectory directory: String, forItem item: RSSItem)
    @objc optional func controller(_ controller: ThroughFolderController, didChooseDirectory directory: String, forURL url: String)
    @objc optional func controller(_ controller: ThroughFolderController, didChooseDirectory directory: String, forTorrent torrent: Torrent)
}
