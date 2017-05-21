//
//  CommentsTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/18/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import SCLAlertView

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentImage: UIImageView!
    
    @IBOutlet weak var commentName: UILabel!
    
    @IBOutlet weak var commentText: UILabel!
    
    @IBOutlet weak var commentDate: UILabel!
    
    
    @IBOutlet weak var commentFlagCount: UILabel!
    
    @IBOutlet weak var deletButton: UIButton!
    
    @IBOutlet weak var profileViewImage: UIImageView!
    
    @IBOutlet weak var postName: UILabel!
    
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
    
   @IBOutlet weak var replyText: UILabel!

    
    let ref = FIRDatabase.database().reference()
    
    var postId: String?
    
    var commentId: String?
    
    var origianlPostUserId: String?
    
    var helperClass : HelperFunctions = HelperFunctions()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let verylightGrey : Color = Color.verylightGrey
    
    let red : Color = Color.red
    
    let grey :Color = Color.grey
    
    let green : Color = Color.green

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setImage(commentType: Int, commentImageUrl: String){
        let fileUrl = NSURL(string: commentImageUrl)
        if(commentType == 1){
            Alamofire.request(commentImageUrl).responseData { response in
                if let alamofire_image = response.result.value {
                    
                    self.commentImage.image = UIImage(data: alamofire_image as Data)
                    
                }
            }
        }
        else {
             self.commentImage.image = UIImage(named:  "Logo")
        }
        self.commentImage.layer.cornerRadius  = self.commentImage.frame.width/2
        self.commentImage.clipsToBounds = true;
        let costomization:UICostomization =  UICostomization(color: self.green.getColor(), width:1)
        costomization.addRoundedBorder(object: self.commentImage)
    }
    
    func addHapticMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    func addHapticHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func animateButton(animationObject: UIButton) {
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
                    self.helperClass.updateCommentFlag(postId: self.postId!, uid: self.uid as! String, commentId: self.commentId!)
                })
            })
        })
    }
    
    func setCommentFlagCount(postId: String, commentId: String) {
        
        self.ref.child("Posts").child(postId).child("Comments").child(commentId).observe( FIRDataEventType.value, with:{ (snapshot) in
            if(snapshot.exists()){
                let commentsData = snapshot.value as! NSDictionary
                let flagCount: Int =  commentsData["commentFlags"]! as! Int
                self.commentFlagCount.text = String(flagCount)
                self.commentFlagCount.textColor = self.grey.getColor()
                if(commentsData["commentFlagUsers"] != nil){
                    let commentFlaggedUsers = commentsData["commentFlagUsers"] as! NSDictionary
                    if(commentFlaggedUsers[self.uid] != nil){
                        self.commentFlagCount.textColor = self.red.getColor()
                    }
                    
                }
                
                
            }
        })
        
    }
    
    @IBAction func setCommentFalg_btn(_ sender: Any) {
        addHapticHeavy()
        self.animateButton(animationObject: self.flagButton)
        
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Yes", target:self, selector:Selector("deletecommentConformation"))
        alertView.addButton("No") {
            
            print("Second button tapped")
        }
        alertView.showSuccess("Are you sure!!", subTitle: "Do you want to delete this comment" , circleIconImage:errorAletViewImage)
        
    }
    
    func deletecommentConformation(){
        helperClass.deleteComment(postId: self.postId!, commentId: self.commentId!)
    }
    
    func setFlagCount(postId: String) {
        
        self.ref.child("Posts").child(postId).child("flags").observe(FIRDataEventType.value, with:{ (snapshot) in
            if(snapshot.exists()){
                let flagsData = snapshot.value as! [String : Int]
                var flagCount: Int =  flagsData["flagCount"]!
                self.flagCount.text = String(flagCount)
                self.flagCount.textColor = self.grey.getColor()
                
                
                self.ref.child("Users").child(self.uid as! String).child("Flag").child(self.postId!).child("userFlag").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    
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
    
    func setRepliesText(postId: String) {
        self.ref.child("Posts").child(postId).child("Comments").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let commentVal = snapshot.value as! NSDictionary
                if(commentVal.count > 1){
                    self.replyText.text = String(commentVal.count) + " Replies"
                }
                else {
                    self.replyText.text = String(commentVal.count) + " Reply"
                }
            }
            else {
                self.replyText.text = ""
            }
        })
    }
    
    
    func setReactionCount(postId: String) {
        self.ref.child("Posts").child(postId).child("reactionsData").observe(FIRDataEventType.value, with: { (snapshot) in
            
            if(snapshot.exists()){
                let reactionsData = snapshot.value as! [String : Int]
                self.ref.child("Users").child(self.uid as! String).child("Reactions").child(self.postId!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
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
    
    @IBAction func ReactionButton_1(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction1, reaction:1)
    }
   
    @IBAction func ReactionButton_2(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction2, reaction:2)
    }
    
    
    @IBAction func ReactionButton_3(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction3, reaction:3)
    }
   
    @IBAction func ReactionButton_4(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction4, reaction:4)
    }
    @IBAction func ReactionButton_5(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction5, reaction:5)
    }
    
    @IBAction func ReactionButton_6(_ sender: Any) {
        addHapticMedium()
        animateButton(animationObject: self.reaction6, reaction:6)
    }
    
  
    
  
    
    @IBAction func flag_button(_ sender: Any) {
        addHapticHeavy()
        animateButton(animationObject: self.flagButton, reaction:7)
        helperClass.updatePostFlag(postId: self.postId!, uid: self.uid as! String)
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
        
        self.ref.child("Posts").child(self.postId!).child("ReactedUsers").child(self.uid! as! String).setValue(self.uid! as! String)
        self.ref.child("Users").child(self.uid! as! String).child("Reactions").child(self.postId!).observeSingleEvent(of: FIRDataEventType.value, with :  { (snapshot) in
            if(snapshot.exists()){
                let rData =  snapshot.value as! [String : AnyObject]
                let existingReaction = rData["userReaction"]
                
                self.helperClass.updateReactions(postId: self.postId!, uid: self.uid! as! String, Reaction: existingReaction as! Int, newReaction: reaction)
                
            }
            else {
                self.helperClass.updateReactions(postId: self.postId!, uid: self.uid! as! String, Reaction: 0, newReaction: reaction)
            }
            
            
            
        })
        
        
        
    }

    func getThisUserData() {
        self.ref.child("Users").child(self.origianlPostUserId!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            let userDetails = snapshot.value as! [String: AnyObject]
            self.postName.text =  userDetails["displayName"] as? String;
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            
            Alamofire.request(userDetails["highResPhoto"] as! String).responseData { response in
                if let alamofire_image = response.result.value {
                    let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
                    self.profileViewImage.image = UIImage(data: profilePicUrl! as Data)
                   
                }
            }
            
            self.profileViewImage.layer.cornerRadius  = self.profileViewImage.frame.width/2
            self.profileViewImage.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 1 )
            customization.addBorder(object: self.profileViewImage)
            
            
        })
        
    }
    
    func setUpGhost() {
        self.postName.text = ""
        self.profileViewImage.image  = UIImage(named:  "Logo")
        self.profileViewImage.layer.cornerRadius  = self.profileViewImage.frame.width/2
        self.profileViewImage.clipsToBounds = true;
        let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 1 )
        customization.addBorder(object: self.profileViewImage)
        
        
    }
    
    func setUpGuess() {
        self.postName.text = "Guess me"
        self.profileViewImage.image  = UIImage(named:  "CrystalBall")
        self.profileViewImage.layer.cornerRadius  = self.profileViewImage.frame.width/2
        self.profileViewImage.clipsToBounds = true;
        let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 1 )
        customization.addBorder(object: self.profileViewImage)
        
        
    }
    
    
    func setUpUserForFriends()   {
        
        
        if(self.origianlPostUserId! == self.uid as! String){
            self.getThisUserData()
           
        }
        else {
            
            self.ref.child("Users").child(self.uid as! String).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if(snapshot.exists()){
                    let userData = snapshot.value as! NSDictionary
                    
                    if(userData["Friends"] != nil){
                        let userFriends = userData["Friends"] as! NSDictionary
                        if(userFriends[self.origianlPostUserId!] != nil){
                            self.getThisUserData()
                            
                        }
                        
                        else {
                            self.setUpGhost()
                            
                        }
                    }
                    else {
                        self.setUpGhost()
                        
                    }
                }
            })
            
        }
    }

    
}
