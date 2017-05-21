//
//  ProfileViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FBSDKShareKit
import Alamofire
import MessageUI



class ProfileViewController: UIViewController, MFMessageComposeViewControllerDelegate  {
    
 
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var cashCount: UILabel!
    

    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    let ref = FIRDatabase.database().reference()

    
    let helperClass : HelperFunctions = HelperFunctions()

    let green : Color = Color.green
    
    let white : Color = Color.white
    

    
    var overlayView = UIView()
    
    var postIdToPass:String!
    
    var spinner:loadingAnimation?
    
    override func viewDidLoad() {
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.spinner?.showOverlayNew(alphaValue: 1)
        
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let logo = UIImage(named: "Logo.png")
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 39))
        imageView.contentMode = .scaleAspectFit
        imageView = UIImageView(image:logo)
        self.navigationController?.navigationBar.topItem?.titleView = imageView
        
        self.getUserDetails()
       
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func getUserDetails() {
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(self.uid as! String).observe(FIRDataEventType.value, with: { (snapshot) in
            
            let userDetails = snapshot.value as! [String: AnyObject]
            self.fullName.text =  userDetails["displayName"] as? String;
            self.cashCount.text = userDetails["cash"] as? String;
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
        
            Alamofire.request(userDetails["highResPhoto"] as! String).responseData { response in
                if let alamofire_image = response.result.value {
                    let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
                    self.profileImage.image = UIImage(data: profilePicUrl! as Data)
                    self.spinner?.hideOverlayViewNew()
                }
            }
            
            
            self.profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
            self.profileImage.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.white.getColor(), width: 5 )
            customization.addBorder(object: self.profileImage)
            
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
   
    @IBAction func shareToFacebook(_ sender: Any) {
        //shareScoreToFB()
    }
    
    
    func shareScoreToFB(){
//        let shareString =  "My ghost gab score is " + self.cashCount.text! + " I challenge you to beat me "
//        var content = FBSDKShareLinkContent()
//        content.contentURL = NSURL(string: "https://www.ghostgab.com")! as URL!
//        content.quote = shareString
//        var dialog = FBSDKShareDialog()
//        dialog.fromViewController = self
//        dialog.shareContent = content
//        dialog.mode = .automatic
//        dialog.show()
    }
    
    @IBAction func viewYourPosts(_ sender: Any) {
        
        let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
        let friendPublicPostView  = storybaord.instantiateViewController(withIdentifier: "friend_public_post") as! FriendPublicPostsViewController
        friendPublicPostView.friendUdid = self.uid as! String
        //trasition from right
       self.navigationController?.pushViewController(friendPublicPostView, animated: true)
        
        
    }
    
    @IBAction func navToRequests(_ sender: Any) {
        // Function used to send text message . Not navgation to request
        if MFMessageComposeViewController.canSendText(){
            let message = MFMessageComposeViewController()
            message.messageComposeDelegate = self
            message.body = "Gab with using at \n GhostGab. by Codeboaders https://appsto.re/us/QJxIhb.i"
           present(message, animated: true)
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
    
    
    
    @IBAction func navToSettings(_ sender: Any) {
        
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let settingsView  = storybaord.instantiateViewController(withIdentifier: "settings_view") as! SettingsViewController
        
        //trasition from right
        self.navigationController?.pushViewController(settingsView, animated: true)
    }
}
