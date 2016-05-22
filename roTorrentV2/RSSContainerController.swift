//
//  RSSContainerController.swift
//  roTorrentV2
//
//  Created by Romain Hild on 22/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class RSSContainerController: UIViewController {
    
    var navController: UINavigationController!
    var rssController: RSSController!
    var panelCollapsed = true {
        didSet {
            showShadowForCenterViewController(!panelCollapsed)
        }
    }
    var filterController: RSSFilterController?
    let centerPanelExpandedOffset: CGFloat = 100
    
    var recognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        rssController = UIStoryboard.rssViewController()
        rssController.delegate = self
        let tabBar = self.tabBarController as! TabBarManagerController
        rssController.manager = tabBar.manager
        
        navController = UINavigationController(rootViewController: rssController)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func filterViewController() -> RSSFilterController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RSSFilterID") as? RSSFilterController
    }
    class func rssViewController() -> RSSController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RSSID") as? RSSController
    }
    
    class func rssNavController() -> UINavigationController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RSSNavID") as? UINavigationController
    }
    
}

extension RSSContainerController: RSSControllerDelegate {
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
                rssController.view.addGestureRecognizer(recognizer)
                //                tabBarController!.tabBar.translucent = false
            //                centerViewController.extendedLayoutIncludesOpaqueBars = true
            default:
                break
            }
        } else {
            if panelCollapsed {
                rssController.view.addGestureRecognizer(recognizer)
                addFilterPanelController()
            } else {
                rssController.view.removeGestureRecognizer(recognizer)
                //                tabBarController!.tabBar.translucent = true
                //                centerViewController.extendedLayoutIncludesOpaqueBars = false
                rssController.tableView.reloadData()
            }
            animateFilterPanel(panelCollapsed)
        }
    }
    
    func addFilterPanelController() {
        if filterController == nil {
            filterController = UIStoryboard.filterViewController()
            let tabBar = self.tabBarController as! TabBarManagerController
            filterController?.manager = tabBar.manager
            
            addChildSidePanelController(filterController!)
        }
    }
    
    func addChildSidePanelController(filterController: RSSFilterController) {
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
            
//            self.filterController?.view.frame.origin.x = -targetPosition
            //            tabBar.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateFilterPanelAt(at: CGFloat) {
        let pos = min(CGRectGetWidth(rssController.view.frame) - centerPanelExpandedOffset, at)
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
