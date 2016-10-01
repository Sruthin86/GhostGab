//
//  SettingsViewController.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/7/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logoutfortesting(sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainScreenViewController = storyboard.instantiateViewControllerWithIdentifier("mainScreen") as! ViewController
        self.presentViewController(mainScreenViewController, animated: true, completion: nil)
    }

}
