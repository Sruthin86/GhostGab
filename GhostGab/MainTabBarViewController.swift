//
//  MainTabBarViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    var selectIndex: Int?
    let lightGreen:Color = Color.lightGreen
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.selectIndex != nil){
            self.selectedIndex = selectIndex!
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: lightGreen.getColor()], for:.normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:.selected)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
