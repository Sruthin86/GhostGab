//
//  LockedViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/13/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import MessageUI
import Fabric
import TwitterKit

class LockedViewController: UIViewController, MFMailComposeViewControllerDelegate  {

    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    var helperClass : HelperFunctions = HelperFunctions()
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteAllPosts()
        helperClass.removeAllFriends(_rpreportedUserId: self.currentUserId)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteAllPosts(){
        
        self.ref.child("Users").child(self.currentUserId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let reportedUserData = snapshot.value as! NSDictionary
                
                if(reportedUserData["posts"] != nil){
                    var posts = reportedUserData["posts"] as! NSDictionary
                    print(posts)
                    for   post in posts {
                      
                        self.helperClass.deletePost(postId: post.key as! String)
                    }
                }
            }
        })
    }

    @IBAction func contact_us(_ sender: Any) {
        self.sendEmail()
    }
    
    
    @IBAction func logout(_ sender: AnyObject) {
        
        ref.child("Users").child(self.currentUserId as! String).child("isUsing").observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            if(snapshot.exists()){
                let  isUsingVal  = snapshot.value as! String
                if(isUsingVal  == "facebook"){
                    try! FIRAuth.auth()!.signOut()
                    FBSDKAccessToken.setCurrent(nil)
                }
                else if(isUsingVal  == "twitter")  {
                    let firebaseAuth = FIRAuth.auth()
                    do {
                        try firebaseAuth?.signOut()
                        let store = Twitter.sharedInstance().sessionStore
                        store.logOutUserID((store.session()?.userID)!)
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                    
                }
                else if ((isUsingVal  == "email")){
                    let firebaseAuth = FIRAuth.auth()
                    do {
                        try firebaseAuth?.signOut()
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainScreenViewController = storyboard.instantiateViewController(withIdentifier: "mainScreen") as! ViewController
                self.present(mainScreenViewController, animated: true, completion: nil)
                
                
            }
        })
        
        
        
        
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["Ghostgabsupport@codeboarders.com"])
            mail.setSubject("userid:"+self.currentUserId)
            mail.setMessageBody("<p>Please send us your concerns !</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
