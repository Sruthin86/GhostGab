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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
   
    @IBOutlet weak var tableView: UITableView!
   
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let ref = FIRDatabase.database().reference()
    
    var settingsList :[String] = ["Edit Profile" ,"Ghost Guessing", "Muted Users", "Blocked Users","Contact Us", "Privacy Policy","Terms Of Service"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let logo = UIImage(named: "Logo.png")
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 39))
        imageView.contentMode = .scaleAspectFit
        imageView = UIImageView(image:logo)
        self.navigationController?.navigationBar.topItem?.titleView = imageView
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = tableView.dequeueReusableCell(withIdentifier: "settings_cell", for: indexPath) as! SettingsTableViewCell
        settingsCell.settings_cell_label.text = self.settingsList[indexPath.row]
        
        return settingsCell
    }
   
    
    
    @IBAction func logout(_ sender: AnyObject) {
        
        ref.child("Users").child(uid as! String).child("isUsing").observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedInt : Int = indexPath.row
        //var settingsList :[String] = ["The Game","Privacy Policy","Terms Of Service","Contact Us","Edit Profile" ,"Muted Users", "Blocked Users"]
        if(settingsList[selectedInt] == "Ghost Guessing" ){
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let theGameView  = storybaord.instantiateViewController(withIdentifier: "game") as! HelpViewController
            //trasition from right
            self.navigationController?.pushViewController(theGameView, animated: true)
        }
        else if(settingsList[selectedInt] == "Privacy Policy" ){
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let privacyView  = storybaord.instantiateViewController(withIdentifier: "privacy") as! PrivacyPolocyViewController
            //trasition from right
            self.navigationController?.pushViewController(privacyView, animated: true)
            
            
          
            
        }
        else if(settingsList[selectedInt] == "Terms Of Service" ){
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let termsView  = storybaord.instantiateViewController(withIdentifier: "terms") as! TermsAndServicesViewController
            //trasition from right
            self.navigationController?.pushViewController(termsView, animated: true)
            
        }
        else if(settingsList[selectedInt] == "Contact Us" ){
            sendEmail()
        }
        else if(settingsList[selectedInt] == "Edit Profile" ){
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let editView  = storybaord.instantiateViewController(withIdentifier: "edit") as! EditViewController
            //trasition from right
            self.navigationController?.pushViewController(editView, animated: true)
            
        }
        else if(settingsList[selectedInt] == "Muted Users" ){
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let unMuteView  = storybaord.instantiateViewController(withIdentifier: "unmute") as! UnMuteViewController
            //trasition from right
            self.navigationController?.pushViewController(unMuteView, animated: true)
        }
        else if(settingsList[selectedInt] == "Blocked Users" ){
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let unBlockView  = storybaord.instantiateViewController(withIdentifier: "unblock") as! UnBlockViewController
            //trasition from right
            self.navigationController?.pushViewController(unBlockView, animated: true)
        }
    }
    
    
    func sendEmail() {
        var userId : String = self.uid as! String
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["Ghostgabsupport@codeboarders.com"])
            mail.setSubject("userid:" + userId)
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
