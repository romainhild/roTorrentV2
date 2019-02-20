//
//  DownloadFilterController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 23/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class DownloadFilterController: UITableViewController {
    
    var manager: Manager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Sorting In"
        case 1:
            return "Sorting By"
        case 2:
            return "Filter By"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44+20
        } else {
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return SortingOrder.count
        case 1:
            return SortingBy.count
        case 2:
            return FilterBy.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let string: String, rowSelected: Int
        switch indexPath.section {
        case 0:
            string = SortingOrder.stringOf(indexPath.row)
            rowSelected = manager.sortDlIn.rawValue
        case 1:
            string = SortingBy.stringOf(indexPath.row)
            rowSelected = manager.sortDlBy.rawValue
        case 2:
            string = FilterBy.stringOf(indexPath.row)
            rowSelected = manager.filterDlBy.rawValue
        default:
            string = ""
            rowSelected = 0
        }
        
        let range = (string as NSString).range(of: string)
        let attributedString = NSMutableAttributedString(string: string)
        
        if indexPath.row == rowSelected {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 20), range: range)
            attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        } else {
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: range)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.textLabel?.attributedText = attributedString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
        case 0:
            manager.sortDlIn = SortingOrder(rawValue: indexPath.row)!
        case 1:
            manager.sortDlBy = SortingBy(rawValue: indexPath.row)!
        case 2:
            manager.filterDlBy = FilterBy(rawValue: indexPath.row)!
        default:
            break
        }
        tableView.reloadData()
        return nil
    }

}
