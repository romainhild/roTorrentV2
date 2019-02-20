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
        navController.navigationBar.barStyle = .black
        view.addSubview(navController.view)
        addChildViewController(navController)
        navController.didMove(toParentViewController: self)

        recognizer = UITapGestureRecognizer(target: self, action: #selector(RSSContainerController.handleTap(_:)))
        recognizer.numberOfTapsRequired = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(_ sender: AnyObject) {
        if (sender as! NSObject) == recognizer {
            let location = recognizer.location(in: self.view)
            if location.x > view.frame.width - centerPanelExpandedOffset {
                toggleFilterPanel(nil)
            }
        }
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func downloadsFilterViewController() -> DownloadFilterController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "DownloadsFilterID") as? DownloadFilterController
    }
    class func downloadsViewController() -> DownloadListController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "DownloadsID") as? DownloadListController
    }
    
    class func downloadsNavController() -> UINavigationController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "DownloadsNavID") as? UINavigationController
    }
}

extension DownloadContainerController: DownloadListControllerDelegate {
    func toggleFilterPanel(_ edgeRecognizer: UIScreenEdgePanGestureRecognizer?) {
        if let edgeRecognizer = edgeRecognizer {
            let position = edgeRecognizer.location(in: nil).x
            switch edgeRecognizer.state {
            case .began:
                addFilterPanelController()
            case .changed:
                animateFilterPanelAt(position)
            case .ended:
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

    func addChildSidePanelController(_ filterController: DownloadFilterController) {
        view.insertSubview(filterController.view, at: 0)
        
        addChildViewController(filterController)
        filterController.didMove(toParentViewController: self)
    }
    
    func animateFilterPanel(_ shouldExpand: Bool) {
        if shouldExpand {
            panelCollapsed = false
            animateCenterPanelXPosition(navController.view.frame.width - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { finished in
                self.panelCollapsed = true
                self.filterController!.view.removeFromSuperview()
                self.filterController = nil
                let tabBar = self.tabBarController as! TabBarManagerController
                tabBar.tabBar.isTranslucent = true
            }
        }
    }
    
    func animateCenterPanelXPosition(_ targetPosition: CGFloat, withDuration duration: TimeInterval = 0.5, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.navController.view.frame.origin.x = targetPosition
            let tabBar = self.tabBarController as! TabBarManagerController
            tabBar.tabBar.isTranslucent = false
            }, completion: completion)
    }
    
    func animateFilterPanelAt(_ at: CGFloat) {
        let pos = min(downloadController.view.frame.width - centerPanelExpandedOffset, at)
        animateCenterPanelXPosition(pos, withDuration: 0)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            navController.view.layer.shadowOpacity = 0.8
        } else {
            navController.view.layer.shadowOpacity = 0.0
        }
    }
}

