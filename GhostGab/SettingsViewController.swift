//
//  SettingsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import MessageUI
import Fabric
import TwitterKit

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let isUsingFbFlag: Bool = (UserDefaults.standard.object(forKey: "isUsingFb") != nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logout(_ sender: AnyObject) {
        
        if(isUsingFbFlag){
            try! FIRAuth.auth()!.signOut()
            FBSDKAccessToken.setCurrent(nil)
        }
        else {
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                let store = Twitter.sharedInstance().sessionStore
                store.logOutUserID((store.session()?.userID)!)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainScreenViewController = storyboard.instantiateViewController(withIdentifier: "mainScreen") as! ViewController
        self.present(mainScreenViewController, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func contact_us(_ sender: Any) {
        
        sendEmail()
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["Ghostgabsupport@codeboarders.com"])
            mail.setMessageBody("<p>Please send ys your concerns !</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
}
