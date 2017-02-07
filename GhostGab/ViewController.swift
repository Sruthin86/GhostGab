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

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func FbLoginPressed(_ sender: AnyObject) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FBLoginLoading") as! FBLoadingViewController
        self.present(vc, animated:true, completion:nil)
    }
    
    @IBAction func twitterLogin(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TwitterLoginLoading") as! twitterLoadingViewController
        self.present(vc, animated:true, completion:nil)
        
    }
    
    @IBAction func emailLogin(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "email_screen") as! EmailSignupViewController
        self.present(vc, animated:true, completion:nil)
        
    }
    
    
}
