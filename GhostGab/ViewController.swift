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
        let ref = FIRDatabase.database().reference()
        //OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [oneSignalId]])
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let  user = user {
                let uid = user.uid
                UserDefaults.standard.set(uid, forKey: fireBaseUid)
                UserDefaults.standard.set(user.displayName, forKey: displayName)
                let storyboard : UIStoryboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                let tabViewController :UIViewController =  storyboard.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                ref.child("Users").child(uid).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    if(snapshot.exists()){
                        let userData = snapshot.value as! [String: AnyObject]
                        UserDefaults.standard.set(userData["isUsingFB"], forKey: "isUsingFb")
                        if((userData["isVerified"]) != nil){
                            var verified: Bool = userData["isVerified"] as! Bool
                            if(verified){
                                let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                                let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                                mainTabBarView.selectedIndex = 0
                                self.present(mainTabBarView, animated: true, completion: nil)
                            }
                            else {
                                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "userNameandPh") as! UserNameAndPhoneNoViewController
                                self.present(vc, animated:true, completion:nil)

                            }
                        }
                        
                        
                    }
                })
              
                
                
                
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
    
    @IBAction func twitterLogin(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TwitterLoginLoading") as! twitterLoadingViewController
        self.present(vc, animated:true, completion:nil)
        
    }
    
    
    
}
