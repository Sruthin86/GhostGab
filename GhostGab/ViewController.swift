//
//  ViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import OneSignal

class ViewController: UIViewController  {
    
    
    
    override func viewDidLoad() {
        var oneSignalId:String?
        super.viewDidLoad()
        
      // self.view.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func FbLoginPressed(_ sender: AnyObject) {
        
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "eula_aggrement") as! EULAViewController
        vc.logInType = "facebook"
        self.present(vc, animated:true, completion:nil)
       
        
    }
    
    @IBAction func twitterLogin(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "eula_aggrement") as! EULAViewController
        vc.logInType = "twitter"
        self.present(vc, animated:true, completion:nil)
        
        
        
    }
    
    @IBAction func emailLogin(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "eula_aggrement") as! EULAViewController
        vc.logInType = "email"
        self.present(vc, animated:true, completion:nil)
        
        
    }
    
    
}
