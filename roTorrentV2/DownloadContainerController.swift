//
//  DownloadContainerController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 23/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class DownloadContainerController: UIViewController {
    
    var downloadController: DownloadListController!
    var navController: UINavigationController!
    var panelCollapsed = true {
        didSet {
            showShadowForCenterViewController(!panelCollapsed)
        }
    }
    var filterController: DownloadFilterController?
    let centerPanelExpandedOffset: CGFloat = 100
    var recognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        downloadController = UIStoryboard.downloadsViewController()
        downloadController.delegate = self
        let tabBar = self.tabBarController as! TabBarManagerController
        downloadController.manager = tabBar.manager
        
        navController = UINavigationController(rootViewController: downloadController)
        navController.navigationBar.barStyle = .Black
        view.addSubview(navController.view)
        addChildViewController(navController)
        navController.didMoveToParentViewController(self)

        recognizer = UITapGestureRecognizer(target: self, action: #selector(RSSContainerController.handleTap(_:)))
        recognizer.numberOfTapsRequired = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(sender: AnyObject) {
        if (sender as! NSObject) == recognizer {
            let location = recognizer.locationInView(self.view)
            if location.x > CGRectGetWidth(view.frame) - centerPanelExpandedOffset {
                toggleFilterPanel(nil)
            }
        }
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func downloadsFilterViewController() -> DownloadFilterController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DownloadsFilterID") as? DownloadFilterController
    }
    class func downloadsViewController() -> DownloadListController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DownloadsID") as? DownloadListController
    }
    
    class func downloadsNavController() -> UINavigationController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DownloadsNavID") as? UINavigationController
    }
}

extension DownloadContainerController: DownloadListControllerDelegate {
    func toggleFilterPanel(edgeRecognizer: UIScreenEdgePanGestureRecognizer?) {
        if let edgeRecognizer = edgeRecognizer {
            let position = edgeRecognizer.locationInView(nil).x
            switch edgeRecognizer.state {
            case .Began:
                addFilterPanelController()
            case .Changed:
                animateFilterPanelAt(position)
            case .Ended:
                animateFilterPanel(position > 100)
                downloadController.view.addGestureRecognizer(recognizer)
            default:
                break
            }
        } else {
            if panelCollapsed {
                downloadController.view.addGestureRecognizer(recognizer)
                addFilterPanelController()
            } else {
                downloadController.view.removeGestureRecognizer(recognizer)
                downloadController.tableView.reloadData()
            }
            
            animateFilterPanel(panelCollapsed)
        }
    }
    
    func addFilterPanelController() {
        if filterController == nil {
            filterController = UIStoryboard.downloadsFilterViewController()
            let tabBar = self.tabBarController as! TabBarManagerController
            filterController?.manager = tabBar.manager
            
            addChildSidePanelController(filterController!)
        }
    }

    func addChildSidePanelController(filterController: DownloadFilterController) {
        view.insertSubview(filterController.view, atIndex: 0)
        
        addChildViewController(filterController)
        filterController.didMoveToParentViewController(self)
    }
    
    func animateFilterPanel(shouldExpand: Bool) {
        if shouldExpand {
            panelCollapsed = false
            animateCenterPanelXPosition(CGRectGetWidth(navController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { finished in
                self.panelCollapsed = true
                self.filterController!.view.removeFromSuperview()
                self.filterController = nil
                let tabBar = self.tabBarController as! TabBarManagerController
                tabBar.tabBar.translucent = true
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, withDuration duration: NSTimeInterval = 0.5, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.navController.view.frame.origin.x = targetPosition
            let tabBar = self.tabBarController as! TabBarManagerController
            tabBar.tabBar.translucent = false
            }, completion: completion)
    }
    
    func animateFilterPanelAt(at: CGFloat) {
        let pos = min(CGRectGetWidth(downloadController.view.frame) - centerPanelExpandedOffset, at)
        animateCenterPanelXPosition(pos, withDuration: 0)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            navController.view.layer.shadowOpacity = 0.8
        } else {
            navController.view.layer.shadowOpacity = 0.0
        }
    }
}

