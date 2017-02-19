//
//  twitterLoadingViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/5/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import OneSignal
import Fabric
import TwitterKit

class twitterLoadingViewController: UIViewController {
    
    var overlayView = UIView()
    var oneSignalId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OneSignal.idsAvailable({ (userId, pushToken) in
            self.oneSignalId = userId!
            
            if (pushToken != nil) {
                
            }
        })
        
        super.viewDidLoad()
        var spinner:loadingAnimation = loadingAnimation(overlayView: overlayView, senderView: self.view)
        spinner.showOverlay(alphaValue: 0)
        let myTimer : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(twitterLoadingViewController.LoginWithTwitter(timer:)), userInfo: nil, repeats: false)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func LoginWithTwitter(timer : Timer) {
        Twitter.sharedInstance().logIn {
            (session, error) -> Void in
            if (session != nil) {
                
                
                let client = TWTRAPIClient.withCurrentUser()
                let request = client.urlRequest(withMethod: "GET",
                                                url: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                                parameters: ["include_email": "true", "skip_status": "true"],
                                                error: nil)
                
                client.sendTwitterRequest(request) { (response, data, connectionError)  -> Void in
                    if connectionError != nil {
                        print("Error: \(connectionError)")
                    }
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: [])
                        let twitterDict = json as? [String: AnyObject]
                        var highResImagePicUrl:String = twitterDict!["profile_image_url_https"] as! String
                        
                        let credential = FIRTwitterAuthProvider.credential(withToken: (session?.authToken)!, secret: (session?.authTokenSecret)!)
                        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                            if let user = FIRAuth.auth()?.currentUser {
                                let databaseRef = FIRDatabase.database().reference()
                                
                                
                                databaseRef.child("Users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if(snapshot.exists()){
                                        let comparingData = snapshot.value as! [String: AnyObject]
                                        let verified = comparingData["isVerified"] as! Bool
                                        
                                        if((verified != nil)){
                                            
                                            if(!verified){
                                                let uModel =  UserModel(name: user.displayName, userName: "", email: "", photoUrl:user.photoURL?.absoluteString , phoneNumber:"" , isVerified: false, uid: user.uid  )
                                                UserDefaults.standard.set(user.uid, forKey: fireBaseUid)
                                                UserDefaults.standard.set(user.displayName, forKey: displayName)
                                                UserDefaults.standard.set("twitter", forKey: isUsing)
                                                let postUserData : [String : AnyObject] = ["displayName": user.displayName! as AnyObject,"photo": (user.photoURL?.absoluteString)! as AnyObject, "highResPhoto": highResImagePicUrl as AnyObject,  "email":"" as AnyObject, "userName":user.uid as AnyObject,  "phoneNumber": "" as AnyObject,"isVerified":false as AnyObject, "isUsing":"twitter" as AnyObject, "oneSignalId":self.oneSignalId as AnyObject, "cash":"200"as! AnyObject   ]
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
                                        let uModel =  UserModel(name: user.displayName, userName: "", email: "", photoUrl:user.photoURL?.absoluteString , phoneNumber:"" , isVerified: false, uid: user.uid  )
                                        UserDefaults.standard.set(user.uid, forKey: fireBaseUid)
                                        UserDefaults.standard.set(user.displayName, forKey: displayName)
                                        UserDefaults.standard.set("twitter", forKey: isUsing)
                                        let postUserData : [String : AnyObject] = ["displayName": user.displayName! as AnyObject,"photo": (user.photoURL?.absoluteString)! as AnyObject, "highResPhoto": highResImagePicUrl as AnyObject,  "email":"" as AnyObject, "userName":user.uid as AnyObject,  "phoneNumber": "" as AnyObject,"isVerified":false as AnyObject,"isUsing":"twitter" as AnyObject, "oneSignalId":self.oneSignalId as AnyObject, "cash":"200" as! AnyObject  ]
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
                        
                        
                    } catch let jsonError as NSError {
                        print("json error: \(jsonError.localizedDescription)")
                    
                    }
                    
                    
                    
                }
                
                
                
                
            } else {
                print("error")
                
            }
        }    }
    
}
