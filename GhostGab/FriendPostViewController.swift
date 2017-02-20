//
//  FriendPostViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 12/18/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import SCLAlertView
import Alamofire

class FriendPostViewController: UIViewController {
    
    
    @IBOutlet weak var displayName: UILabel!
    
    @IBOutlet weak var csahLabel: UILabel!
    
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var flagCount: UILabel!
    
    @IBOutlet weak var reactionLabel1: UILabel!
    
    @IBOutlet weak var reactionLabel2: UILabel!
    
    @IBOutlet weak var reactionLabel3: UILabel!
    
    @IBOutlet weak var reactionLabel4: UILabel!
    
    @IBOutlet weak var reactionLabel5: UILabel!
    
    @IBOutlet weak var reactionLabel6: UILabel!
    
    @IBOutlet weak var reaction1: UIButton!
    
    @IBOutlet weak var reaction2: UIButton!
    
    @IBOutlet weak var reaction3: UIButton!
    
    @IBOutlet weak var reaction4: UIButton!
    
    @IBOutlet weak var reaction5: UIButton!
    
    @IBOutlet weak var reaction6: UIButton!
    
    @IBOutlet weak var flagButton: UIButton!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var reactionsView: UIView!
    
    @IBOutlet weak var feedView: UIView!
    
    let green : Color = Color.green
    
    let red : Color = Color.red
    
    let grey :Color = Color.grey
    
    let verylightGrey : Color = Color.verylightGrey
    
    let ref = FIRDatabase.database().reference()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    var helperClass : HelperFunctions = HelperFunctions()
    
    var friendPostArray = [String:AnyObject]()
    
    var postId: String = ""
    
    var origianlPostUserId: String = ""
    
    var width:CGFloat = 1

    @IBOutlet weak var warning_btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let customization: UICostomization = UICostomization (color: verylightGrey.getColor(), width:width)
        //customization.addBorder(object: self.reactionsView)
        customization.addBorder(object: self.feedView)
        self.postLabel.text = friendPostArray["post"] as! String?
        self.origianlPostUserId = (friendPostArray["useruid"]  as! String?)!
        if(origianlPostUserId == self.uid as! String){
            self.warning_btn.isHidden = true
        }
        self.dateLabel.text = helperClass.getDifferenceInDates(postDate: (friendPostArray["date"]as? String)!)
        self.getUserData()
        self.setFlagCount(postId: self.postId)
        self.setReactionCount(postId: self.postId)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(FriendPostViewController.sendToUserDetailsPage))
        profileImage.addGestureRecognizer(tap)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getUserData() {
        self.ref.child("Users").child(self.origianlPostUserId as! String).observe(FIRDataEventType.value, with: { (snapshot) in
            
            let userDetails = snapshot.value as! [String: AnyObject]
            self.displayName.text =  userDetails["displayName"] as? String;
            self.csahLabel.text = userDetails["cash"] as? String;
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            
            Alamofire.request(userDetails["highResPhoto"] as! String).responseData { response in
                if let alamofire_image = response.result.value {
                    let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
                    self.profileImage.image = UIImage(data: profilePicUrl! as Data)
                    
                }
            }
            
            self.profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
            self.profileImage.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 5 )
            customization.addBorder(object: self.profileImage)
           
            
        })
        
    }

    @IBAction func backButton(_ sender: Any) {
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 0
        //trasition from left
        let transition = CATransition()
        transition.duration = 0.28
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
        self.present(mainTabBarView, animated: false, completion: nil)
    }
    
    @IBAction func ReactionButton1(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction1, reaction:1)
    }
    @IBAction func ReactionButton2(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction2, reaction:2)
    }
    
    @IBAction func ReactionButton3(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction3, reaction:3)
    }
    
    @IBAction func ReactionButton4(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction4, reaction:4)
    }
    
    @IBAction func ReactionButton5(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction5, reaction:5)
    }
    
    @IBAction func ReactionButton6(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction6, reaction:6)
    }
    
    @IBAction func Flag(_ sender: Any) {
        addHapticHeavy()
        animateButton(animationObject: self.flagButton, reaction:7)
        helperClass.updatePostFlag(postId: self.postId, uid: self.uid as! String)
    }
    
    func addHapticMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    func addHapticHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func animateButton(animationObject: UIButton, reaction:Int) {
        UIView.animate(withDuration: 0.3, delay:0.1, options:[], animations: {
            animationObject.transform = CGAffineTransform(scaleX: 2, y: 2)
        }, completion: {_ in
            
            UIView.animate(withDuration: 0.3, delay:0.1, options:[], animations: {
                animationObject.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                animationObject.transform = animationObject.transform.rotated(by: CGFloat(M_PI))
                animationObject.alpha = 0.5
            }, completion: {_ in
                UIView.animate(withDuration: 0.4, delay:0.0, options:[], animations: {
                    animationObject.transform = CGAffineTransform(scaleX: 1, y: 1)
                    animationObject.alpha = 1
                }, completion: {_ in
                    if(reaction != 7){
                        self.myReaction(reaction: reaction)
                    }
                })
            })
        })
    }
    
    func myReaction (reaction: Int) {
        
        self.ref.child("Posts").child(self.postId).child("ReactedUsers").child(self.uid! as! String).setValue(self.uid! as! String)
        self.ref.child("Users").child(self.uid! as! String).child("Reactions").child(self.postId).observeSingleEvent(of: FIRDataEventType.value, with :  { (snapshot) in
            if(snapshot.exists()){
                let rData =  snapshot.value as! [String : AnyObject]
                let existingReaction = rData["userReaction"]
                
                self.helperClass.updateReactions(postId: self.postId, uid: self.uid! as! String, Reaction: existingReaction as! Int, newReaction: reaction)
                
            }
            else {
                self.helperClass.updateReactions(postId: self.postId, uid: self.uid! as! String, Reaction: 0, newReaction: reaction)
            }
            
            
            
        })
        
        
        
    }
    
    
    
    func setReactionCount(postId: String) {
        self.ref.child("Posts").child(postId).child("reactionsData").observe(FIRDataEventType.value, with: { (snapshot) in
            
            if(snapshot.exists()){
                let reactionsData = snapshot.value as! [String : Int]
                self.ref.child("Users").child(self.uid as! String).child("Reactions").child(self.postId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    self.reactionLabel1.text = String(reactionsData["Reaction1"]!)
                    self.reactionLabel1.textColor = self.grey.getColor()
                    self.reactionLabel2.text = String(reactionsData["Reaction2"]!)
                    self.reactionLabel2.textColor = self.grey.getColor()
                    self.reactionLabel3.text = String(reactionsData["Reaction3"]!)
                    self.reactionLabel3.textColor = self.grey.getColor()
                    self.reactionLabel4.text = String(reactionsData["Reaction4"]!)
                    self.reactionLabel4.textColor = self.grey.getColor()
                    self.reactionLabel5.text = String(reactionsData["Reaction5"]!)
                    self.reactionLabel5.textColor = self.grey.getColor()
                    self.reactionLabel6.text = String(reactionsData["Reaction6"]!)
                    self.reactionLabel6.textColor = self.grey.getColor()
                    
                    guard(!snapshot.exists()) else {
                        let rData = snapshot.value as! [String:Int]
                        let userReaction: Int = rData["userReaction"]!
                        
                        
                        switch userReaction{
                        case 1 :
                            self.reactionLabel1.textColor = self.green.getColor()
                            break
                        case 2 :
                            self.reactionLabel2.textColor = self.green.getColor()
                            break
                        case 3 :
                            self.reactionLabel3.textColor = self.green.getColor()
                            break
                        case 4 :
                            self.reactionLabel4.textColor = self.green.getColor()
                            break
                        case 5 :
                            self.reactionLabel5.textColor = self.green.getColor()
                            break
                        case 6 :
                            self.reactionLabel6.textColor = self.green.getColor()
                            break
                        default:
                            break
                            
                        }
                        return
                    }
                    
                })
                
            }
            
            
        })
        
        
    }
    
    func setFlagCount(postId: String) {
        
        self.ref.child("Posts").child(postId).child("flags").observe(FIRDataEventType.value, with:{ (snapshot) in
            if(snapshot.exists()){
                let flagsData = snapshot.value as! [String : Int]
                var flagCount: Int =  flagsData["flagCount"]!
                self.flagCount.text = String(flagCount)
                self.flagCount.textColor = self.grey.getColor()
                
                
                self.ref.child("Users").child(self.uid as! String).child("Flag").child(self.postId).child("userFlag").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    
                    if(snapshot.exists()){
                        let val =  snapshot.value as!Int
                        if (val == 1){
                            self.flagCount.textColor = self.red.getColor()
                        }
                    }
                })
            }
        })
        
    }
    
    @IBAction func warningButton(_ sender: Any) {
        
        let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Inappropriate Gab", target:self, selector:#selector(FriendPostViewController.reportGab))
        alertView.addButton("Offensive Gab", target:self, selector:#selector(FriendPostViewController.reportGab))
        alertView.addButton("Gab is targetting someone", target:self, selector:#selector(FriendPostViewController.reportGab))
        alertView.addButton("Other", target:self, selector:#selector(FriendPostViewController.reportGab))
        alertView.addButton("Report this user", target:self, selector:#selector(FriendPostViewController.reportUser))
        alertView.addButton("Mute this user", target:self, selector:#selector(FriendPostViewController.muteUser))
        alertView.addButton("Block this user", target:self, selector:#selector(FriendPostViewController.blockUsers))
        alertView.addButton("Cancel") {
            
            print("Second button tapped")
        }
        alertView.showSuccess("Report this Gab", subTitle: "" , circleIconImage:errorAletViewImage)
    }
    
    
    func reportUser(){
        helperClass.reportUser(_postId: self.postId)
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            
            print("Second button tapped")
        }
        alertView.showInfo("Thank you", subTitle: "This user has been reported. We are immediately looking at your concerns" , circleIconImage:checkAletViewImage)
        
    }
    
    func reportGab(){
        helperClass.reportPosts(postId: self.postId, userUid: self.uid as! String)
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
            mainTabBarView.selectedIndex = 0
            //trasition from left
            let transition = CATransition()
            transition.duration = 0.28
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
            self.present(mainTabBarView, animated: false, completion: nil)
           
        }
         alertView.showInfo("Thank you", subTitle: "We are immediately looking at your concerns" , circleIconImage:checkAletViewImage)
    }
    
    func muteUser(){
        helperClass.muteUser(_postId: self.postId, userUid: self.uid as! String)
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            
        }
        alertView.showInfo("Thank you", subTitle: "This user has been muted . You will not see this user's gabs on your time line. You can unmute them in your settings" , circleIconImage:checkAletViewImage)

    }
    
    
    func blockUsers(){
        helperClass.blockUser(_postId: self.postId, userUid: self.uid as! String)
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            
        }
        alertView.showInfo("Thank you", subTitle: "This user has been blocked . You can unblock them in your settings" , circleIconImage:checkAletViewImage)
        
    }

    func sendToUserDetailsPage(){
        let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
        let friendDetailsView  = storybaord.instantiateViewController(withIdentifier: "friend_details") as! FriendDetailsViewController
        friendDetailsView.friendUdid = origianlPostUserId
        //trasition from right
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransitionPush)
        self.present(friendDetailsView, animated: false, completion: nil)
    }
}
