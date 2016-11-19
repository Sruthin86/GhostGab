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

class FBLoadingViewController: UIViewController {
    
    var overlayView = UIView()
    
    
    
    
    override func viewDidLoad() {
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
                print("result")
                
                if(fbloginresult.isCancelled) {
                    //Show Cancel alert
                } else if(fbloginresult.grantedPermissions.contains("email")) {
                    var highResImagePicUrl : String?
                    if((FBSDKAccessToken.current()) != nil){
                        FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":500 , "width":500 , "redirect":false ]).start(completionHandler: { (connection, result, error) -> Void in
                            if (error == nil){
                                print(result)
                                let largeImageDict  =  result as! NSDictionary
                                print("largeImageDict")
                                print(largeImageDict)
                                let largeImgData = largeImageDict.object(forKey: "data")
                                print("largeImgData")
                                print(largeImgData)
                                highResImagePicUrl = (largeImgData as! NSDictionary).object(forKey:"url") as? String
                            }
                        })
                    }
                    
                    
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if let user = FIRAuth.auth()?.currentUser {
                            let databaseRef = FIRDatabase.database().reference()
                            let uModel =  UserModel(name: user.displayName, userName: "", email: user.email, photoUrl:user.photoURL?.absoluteString , phoneNumber:"" , isVerified: false, uid: user.uid  )
                            UserDefaults.standard.set(user.uid, forKey: fireBaseUid)
                            let postUserData : [String : AnyObject] = ["displayName": user.displayName! as AnyObject,"photo": (user.photoURL?.absoluteString)! as AnyObject, "highResPhoto": highResImagePicUrl! as AnyObject,  "email":user.email! as AnyObject, "userName":user.uid as AnyObject,  "phoneNumber": "" as AnyObject,"isVerified":false as AnyObject  ]
                            databaseRef.child("Users").child(user.uid).setValue(postUserData)
                            DispatchQueue.main.async (execute: {
                                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "userNameandPh") as! UserNameAndPhoneNoViewController
                                self.present(vc, animated:true, completion:nil)
                                
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
