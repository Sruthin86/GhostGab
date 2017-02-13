//
//  FBLoadingViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBAudienceNetwork
import Firebase
import FirebaseAuth
import FirebaseDatabase
import OneSignal


class FBLoadingViewController: UIViewController {
    
    var overlayView = UIView()
    var oneSignalId:String?
    
    
    
    override func viewDidLoad() {
        

        OneSignal.idsAvailable({ (userId, pushToken) in
            self.oneSignalId = userId!
            
            if (pushToken != nil) {
                
            }
        })
        
        super.viewDidLoad()
        var spinner:loadingAnimation = loadingAnimation(overlayView: overlayView, senderView: self.view)
        spinner.showOverlay(alphaValue: 0)
       let myTimer : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(FBLoadingViewController.LoginWithFacebook(timer:)), userInfo: nil, repeats: false)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func LoginWithFacebook(timer : Timer) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        //fbLoginManager.loginBehavior = FBSDKLoginBehavior.Browser
        
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self, handler: {
            (facebookResult, facebookError) -> Void in
            
            if (facebookError == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = facebookResult!
                if(fbloginresult.isCancelled) {
                    //Show Cancel alert
                } else if(fbloginresult.grantedPermissions.contains("email")) {
                    var highResImagePicUrl : String?
                    if((FBSDKAccessToken.current()) != nil){
                        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "picture"]).start(completionHandler: { (connection, result, error) -> Void in
                            if (error == nil){
                                
                               
                                let largeImageDict  =  result as! NSDictionary
                                let largeImgDataID = largeImageDict["id"] as! String
                                highResImagePicUrl = "https://graph.facebook.com/" + largeImgDataID + "/picture?type=large"
                                
                                
                                
                            }
                        })
                    }
                    
                    
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if let user = FIRAuth.auth()?.currentUser {
                            let databaseRef = FIRDatabase.database().reference()
                            
                            databaseRef.child("Users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                                if(snapshot.exists()){
                                    let comparingData = snapshot.value as! [String: AnyObject]
                                    let verified = comparingData["isVerified"] as! Bool
                                    
                                    if((verified != nil)){
                                        
                                        if(!verified){
                                            let uModel =  UserModel(name: user.displayName, userName: "", email: user.email, photoUrl:user.photoURL?.absoluteString , phoneNumber:"" , isVerified: false, uid: user.uid  )
                                            UserDefaults.standard.set(user.uid, forKey: fireBaseUid)
                                            UserDefaults.standard.set(user.displayName, forKey: displayName)
                                            UserDefaults.standard.set("facebook", forKey: isUsing)
                                            let postUserData : [String : AnyObject] = ["displayName": user.displayName! as AnyObject,"photo": (user.photoURL?.absoluteString)! as AnyObject, "highResPhoto": highResImagePicUrl! as AnyObject,  "email":user.email! as AnyObject, "userName":user.uid as AnyObject,  "phoneNumber": "" as AnyObject,"isVerified":false as AnyObject, "isUsing":"facebook" as AnyObject, "oneSignalId":self.oneSignalId as AnyObject, "cash":"200"as AnyObject   ]
                                            databaseRef.child("Users").child(user.uid).setValue(postUserData)
                                            DispatchQueue.main.async (execute: {
                                                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                let vc = storyboard.instantiateViewController(withIdentifier: "userNameandPh") as! UserNameAndPhoneNoViewController
                                                self.present(vc, animated:true, completion:nil)
                                                
                                            })
                                        }
                                        else {
                                            
                                            if(comparingData["reportedCount"] != nil){
                                                var rportedCount = comparingData["reportedCount"] as! Int
                                                if(rportedCount >= 5){
                                                    let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                    let lockedView  = storybaord.instantiateViewController(withIdentifier: "locked_view") as! LockedViewController
                                                    self.present(lockedView, animated: true, completion: nil)
                                                }
                                            }
                                            
                                            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                                            let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                                            mainTabBarView.selectedIndex = 0
                                            self.present(mainTabBarView, animated: true, completion: nil)
                                        }
                                    }
                                    else {
                                        
                                    }
                                    
                                }
                                else {
                                    let uModel =  UserModel(name: user.displayName, userName: "", email: user.email, photoUrl:user.photoURL?.absoluteString , phoneNumber:"" , isVerified: false, uid: user.uid  )
                                    UserDefaults.standard.set(user.uid, forKey: fireBaseUid)
                                    UserDefaults.standard.set(user.displayName, forKey: displayName)
                                    UserDefaults.standard.set("facebook", forKey: isUsing)
                                    let postUserData : [String : AnyObject] = ["displayName": user.displayName! as AnyObject,"photo": (user.photoURL?.absoluteString)! as AnyObject, "highResPhoto": highResImagePicUrl! as AnyObject,  "email":user.email! as AnyObject, "userName":user.uid as AnyObject,  "phoneNumber": "" as AnyObject,"isVerified":false as AnyObject, "isUsing":"facebook" as AnyObject, "oneSignalId":self.oneSignalId as AnyObject, "cash":"200" as! AnyObject  ]
                                    databaseRef.child("Users").child(user.uid).setValue(postUserData)
                                    DispatchQueue.main.async (execute: {
                                        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = storyboard.instantiateViewController(withIdentifier: "userNameandPh") as! UserNameAndPhoneNoViewController
                                        self.present(vc, animated:true, completion:nil)
                                        
                                    })
                                }
                            })
                            
                            
                            
                        }
                        
                    }
                }
            }
                
            else {
                print(facebookError)
                
                
            }
        })
        
    }
    
    
    
    
    
    
}
