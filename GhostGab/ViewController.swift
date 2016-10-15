//
//  ViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 10/1/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController  {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let  user = user {
                let uid = user.uid
                UserDefaults.standard.set(uid, forKey: fireBaseUid)
                let storyboard : UIStoryboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                let tabViewController :UIViewController =  storyboard.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                self.present(tabViewController, animated: true, completion: nil)
                
                
                
                // User is signed in.
            } else {
                // No user is signed in.
            }
        }
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
    
  
    
    
}


