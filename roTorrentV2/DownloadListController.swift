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
    var manager: Manager!
    let cellId = "TorrentCell"
    
    var searchBar: UISearchBar!
    var recognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: cellId, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellId)
        self.tableView.rowHeight = 78

        let mainRect = UIScreen.main.bounds
        searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: mainRect.width-20,height: 56))
        searchBar.delegate = self
        searchBar.placeholder = "Search Torrent"
        searchBar.enablesReturnKeyAutomatically = false
        tableView.tableHeaderView = searchBar
        tableView.contentOffset = CGPoint(x: 0, y: searchBar.frame.size.height)

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(DownloadListController.refresh(_:)), for: .valueChanged)
        
        recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(DownloadListController.filter(_:)))
        recognizer.edges = .left
        view.addGestureRecognizer(recognizer)

        refresh(self)
    }
    
    func refresh(_ sender: AnyObject) {
        let call = manager.callToInitList()
        manager.call(call) {response in
            switch response {
            case .success(let xmltype):
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.manager.torrents.initWithXmlArray(xmltype)
                    self.manager.updateTorrentsToDiplay()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(ok)
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func filter(_ sender: AnyObject) {
        if (sender as! NSObject) != recognizer {
            delegate?.toggleFilterPanel(nil)
        } else {
            delegate?.toggleFilterPanel(recognizer)
        }
    }
    
    @IBAction func addTorrent(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Add Torrent via URL", message: "And choose a directory", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "URL"
        }
        let baseDir = UIAlertAction(title: "Base Directory", style: .default) { action in
            let call = RTorrentCall.addTorrent(alert.textFields![0].text!, "")
            self.manager.call(call, completionHandler: self.responseToAddTorrent)
        }
        alert.addAction(baseDir)
        let otherDir = UIAlertAction(title: "Other Directory...", style: .default) { action in
            self.performSegue(withIdentifier: "ThroughFolder", sender: alert.textFields![0].text)
        }
        alert.addAction(otherDir)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
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
        return manager.numberOfTorrentToDispplay(searchBar.text)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TorrentCell
        let torrent = manager.torrentAtIndexPath(indexPath, searchText: searchBar.text)
        cell.configureForTorrent(torrent)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let torrent = manager.torrentAtIndexPath(indexPath, searchText: searchBar.text)
        performSegue(withIdentifier: "DetailTorrent", sender: torrent)
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
        if segue.identifier == "DetailTorrent" {
            let controller = segue.destination as! DetailTorrentController
            controller.manager = self.manager
            let torrent = sender as! Torrent
            controller.torrent = torrent
        } else if segue.identifier == "ThroughFolder" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ThroughFolderController
            controller.manager = self.manager
            controller.delegate = self
            controller.url = sender as? String
        }
    }

    func responseToAddTorrent(_ response: Response<XMLRPCType,NSError>) {
        switch response {
        case .success:
            DispatchQueue.main.async {
                self.refresh(self)
            }
        case .failure(let error):
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(ok)
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension DownloadListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension DownloadListController: ThroughFolderDelegate {
    func controllerDidCancel(_ controller: ThroughFolderController) {
        
    }
    
    func controller(_ controller: ThroughFolderController, didChooseDirectory directory: String, forURL url: String) {
        let call = RTorrentCall.addTorrent(url, directory)
        self.manager.call(call, completionHandler: responseToAddTorrent)
    }
}

protocol DownloadListControllerDelegate {
    func toggleFilterPanel(_ edgeRecognizer: UIScreenEdgePanGestureRecognizer?)
}
