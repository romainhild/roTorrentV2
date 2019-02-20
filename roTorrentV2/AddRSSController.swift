//
//  AddRSSController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class AddRSSController: UITableViewController, UITextFieldDelegate {
    
    var delegate: AddRSSDelegate!
    var feedToEdit: RSSFeed?

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        titleField.becomeFirstResponder()
        titleField.delegate = self
        linkField.delegate = self
        
        if let feed = feedToEdit {
            doneButton.isEnabled = true
            titleField.text = feed.title
            linkField.text = feed.link.absoluteString
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done(_ sender: AnyObject) {
        if let url = URL(string: linkField.text!) {
            if let feed = feedToEdit {
                feed.title = titleField.text!
                feed.link = url
                delegate?.editFeed(feed, sender: self)
                self.dismiss(animated: true, completion: nil)
            }
            if let feed = RSSFeed(title: titleField.text!, link: url) {
                delegate?.addFeed(feed, sender: self)
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Oops", message: "It seems there was a problem\nEither the network is down, or the URL is not valid\nPlease try again.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "It seems there was a problem\nThe URL is not valid\nPlease try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text! as NSString).replacingCharacters(in: range, with: string).isEmpty {
            doneButton.isEnabled = false
        } else {
            if textField == titleField {
                if !linkField.text!.isEmpty {
                    doneButton.isEnabled = true
                }
            } else {
                if !titleField.text!.isEmpty {
                    doneButton.isEnabled = true
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            linkField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

protocol AddRSSDelegate {
    func addFeed(_ feed: RSSFeed, sender: AnyObject)
    func editFeed(_ feed: RSSFeed, sender: AnyObject)
}
