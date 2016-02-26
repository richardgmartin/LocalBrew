//
//  tabBarViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/19/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class tabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.fromHexString("#FAFAFF", alpha: 1.0)
        self.tabBar.barTintColor = UIColor.fromHexString("#960200", alpha: 1.0)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        self.tabBar.translucent = false
        let tabItems = self.tabBar.items! as [UITabBarItem]
        let tabItemHome = tabItems[0]
        let tabItemProfile = tabItems[1]
        tabItemHome.title = "Home"
        tabItemProfile.title = "Profile"
        
        
        
        
    
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
