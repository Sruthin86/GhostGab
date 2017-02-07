//
//  InitialViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 12/16/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import OneSignal

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var oneSignalId:String?
        let ref = FIRDatabase.database().reference()
        //OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [oneSignalId]])
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let  user = user {
                let uid = user.uid
                UserDefaults.standard.set(uid, forKey: fireBaseUid)
                UserDefaults.standard.set(user.displayName, forKey: displayName)
                
                ref.child("Users").child(uid).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    if(snapshot.exists()){
                        let userData = snapshot.value as! [String: AnyObject]
                        UserDefaults.standard.set(userData["isUsing"], forKey: "isUsing")
                         UserDefaults.standard.set(userData["displayName"], forKey: displayName)
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
                    
                    else {
                        //User does not exist.
                        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "mainScreen") as! ViewController
                        self.present(vc, animated:true, completion:nil)
                    }
                })
                
               
                
                
                // User is signed in.
            } else {
                // No user is signed in.
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "mainScreen") as! ViewController
                self.present(vc, animated:true, completion:nil)
            }
        }
        
        
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
