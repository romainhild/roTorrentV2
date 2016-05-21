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

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.enabled = false
        titleField.becomeFirstResponder()
        titleField.delegate = self
        linkField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done(sender: AnyObject) {
        if let url = NSURL(string: linkField.text!) {
            if let feed = RSSFeed(title: titleField.text!, link: url) {
                delegate?.addFeed(feed, sender: self)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Oops", message: "It seems there was a problem\nEither the network is down, or the URL is not valid\nPlease try again.", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "It seems there was a problem\nThe URL is not valid\nPlease try again.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string).isEmpty {
            doneButton.enabled = false
        } else {
            if textField == titleField {
                if !linkField.text!.isEmpty {
                    doneButton.enabled = true
                }
            } else {
                if !titleField.text!.isEmpty {
                    doneButton.enabled = true
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == titleField {
            linkField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

protocol AddRSSDelegate {
    func addFeed(feed: RSSFeed, sender: AnyObject)
}
