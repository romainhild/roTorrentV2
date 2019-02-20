//
//  RSSController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class RSSController: UITableViewController {
    
    var delegate: RSSControllerDelegate!
    
    var manager: Manager!
    
    var searchBar: UISearchBar!
    var recognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(RSSController.refresh(_:)), for: .valueChanged)
        
        let mainRect = UIScreen.main.bounds
        searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: mainRect.width-20,height: 56))
        searchBar.delegate = self
        searchBar.placeholder = "Search Item"
        searchBar.enablesReturnKeyAutomatically = false
        tableView.tableHeaderView = searchBar
        tableView.contentOffset = CGPoint(x: 0, y: searchBar.frame.size.height)
        
        recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(RSSController.toggleFilter(_:)))
        recognizer.edges = .left
        view.addGestureRecognizer(recognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func edit(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "EditFeeds", sender: self)
    }
    
    @IBAction func toggleFilter(_ sender: AnyObject) {
        if (sender as! NSObject) != recognizer {
            delegate?.toggleFilterPanel(nil)
        } else {
            delegate?.toggleFilterPanel(recognizer)
        }
    }
    
    func refresh(_ sender: AnyObject) {
        refreshControl?.endRefreshing()
        manager.updateFeeds()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOtItemsToDisplay(searchBar.text)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RSSCell", for: indexPath)
        let item = manager.itemToDisplayAtIndexPath(indexPath, thatMatch: searchBar.text)
        cell.textLabel?.text = item.title
        if item.hasBeenAdded {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = manager.itemToDisplayAtIndexPath(indexPath, thatMatch: searchBar.text)
        let torrent = item.title
        let url = item.link
        let actionSheet = UIAlertController(title: "Add Torrent", message: torrent, preferredStyle: .actionSheet)
        let add = UIAlertAction(title: "Add", style: .default) { action in
            let call = RTorrentCall.addTorrent(url.absoluteString, "")
            self.manager.call(call) { response in
                switch response {
                case .success:
                    item.hasBeenAdded = true
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                default:
                    break
                }
            }
        }
        actionSheet.addAction(add)
        let addFolder = UIAlertAction(title: "Add in a directory...", style: .default) { action in
            self.performSegue(withIdentifier: "ThroughFolder", sender: item)
        }
        actionSheet.addAction(addFolder)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditFeeds" {
            let navBar = segue.destination as! UINavigationController
            let editFeeds = navBar.topViewController as! EditFeedsController
            editFeeds.manager = self.manager
        } else if segue.identifier == "ThroughFolder" {
            let navBar = segue.destination as! UINavigationController
            let throughFolder = navBar.topViewController as! ThroughFolderController
            throughFolder.manager = self.manager
            throughFolder.item = sender as? RSSItem
            throughFolder.delegate = self
        }
    }

}

extension RSSController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension RSSController: ThroughFolderDelegate {
    func controllerDidCancel(_ controller: ThroughFolderController) {
        
    }
    
    func controller(_ controller: ThroughFolderController, didChooseDirectory directory: String, forItem item: RSSItem) {
        let call = RTorrentCall.addTorrent(item.link.absoluteString, directory)
        self.manager.call(call) { response in }
        item.hasBeenAdded = true
        self.tableView.reloadData()

    }
}

protocol RSSControllerDelegate {
    func toggleFilterPanel(_ edgeRecognizer: UIScreenEdgePanGestureRecognizer?)
    func addFilterPanelController()
    func animateFilterPanel(_ shouldExpand: Bool)
}
