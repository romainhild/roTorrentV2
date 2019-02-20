//
//  SettingsController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    
    var manager: Manager!

    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var mountField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TabBarManagerController
        self.manager = tabBar.manager
        
        self.hostField.delegate = self
        self.userField.delegate = self
        self.passwordField.delegate = self
        self.mountField.delegate = self
        
        if let host = manager.urlComponents.host {
            hostField.text = host
        }
        if let user = manager.urlComponents.user {
            userField.text = user
        }
        if let password = manager.urlComponents.password {
            passwordField.text = password
        }
        if let mount = manager.urlComponents.path {
            mountField.text = mount
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SettingsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case hostField:
            userField.becomeFirstResponder()
        case userField:
            passwordField.becomeFirstResponder()
        case passwordField:
            mountField.becomeFirstResponder()
        case mountField:
            mountField.resignFirstResponder()
        default:
            break
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case hostField:
            manager.urlComponents.host = hostField.text
        case userField:
            manager.urlComponents.user = userField.text
        case passwordField:
            manager.urlComponents.password = passwordField.text
        case mountField:
            if let text = mountField.text, text.hasPrefix("/") {
                manager.urlComponents.path = mountField.text
            } else {
                manager.urlComponents.path = nil
                mountField.text = ""
            }
        default:
            break
        }
    }
}
