//
//  PostCellTableViewCell.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/15/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class PostCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var FeedView: UIView!
    @IBOutlet weak var reactButton: UIButton!
    @IBOutlet weak var reactionsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ReactionsContent: UIView!
    @IBOutlet weak var ReactionsView: UIView!
    
    var cellSelected: Bool = false
    var width:CGFloat = 0.4
    
    @IBOutlet weak var reaction1: UIButton!
    
    @IBOutlet weak var reaction2: UIButton!
    
    @IBOutlet weak var reaction3: UIButton!
    
    @IBOutlet weak var reaction4: UIButton!
    
    @IBOutlet weak var reaction5: UIButton!
    
    @IBOutlet weak var reaction6: UIButton!
    
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var cellImage: UIImageView!
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var reaction1Label: UILabel!
    
    @IBOutlet weak var reaction2Label: UILabel!
    
    @IBOutlet weak var reaction3Label: UILabel!
    
    @IBOutlet weak var reaction4Label: UILabel!
    
    @IBOutlet weak var reaction5Label: UILabel!
    
    @IBOutlet weak var reaction6Label: UILabel!
    
    @IBOutlet weak var dateString: UILabel!
    
    @IBOutlet weak var flagLabel: UILabel!
    
    var postId: String?
    
    var helperClass : HelperFunctions = HelperFunctions()
    
    let uid = NSUserDefaults.standardUserDefaults().objectForKey(fireBaseUid)
    
    let verylightGrey : Color = Color.verylightGrey
    
    let red : Color = Color.red
    
    let grey :Color = Color.grey
    
    let green : Color = Color.green
    //@IBOutlet weak var reaction1: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let customization: UICostomization = UICostomization (color: verylightGrey.getColor(), width:width)
        customization.addBackground(self)
        customization.addBorder(ReactionsView)
        customization.addBorder(FeedView)
        super.awakeFromNib()
        reactionsViewHeight.constant = 0
        self.ReactionsContent.hidden = true
        self.ReactionsView.hidden = true
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func openReactionsView(){
        
        reactionsViewHeight.constant = 76
        self.ReactionsContent.hidden = false
        self.ReactionsView.hidden = false
        
    }
    func closeReactionsView(){
        reactionsViewHeight.constant = 0
        self.ReactionsContent.hidden = true
        self.ReactionsView.hidden = true
        
    }
    
    @IBAction func ReactionButton(sender: AnyObject) {
        
        
        animateButton(self.reaction1, reaction:1)
        
        
        
    }
    
    
    @IBAction func Reaction2Button(sender: AnyObject) {
        
        animateButton(self.reaction2,reaction:2)
        
        
        
    }
    
    @IBAction func Reaction3Button(sender: AnyObject) {
        
        animateButton(self.reaction3,reaction:3)
        
        
        
    }
    
    
    @IBAction func Reaction4Button(sender: AnyObject) {
        
        animateButton(self.reaction4, reaction:4)
        
        
        
    }
    
    
    @IBAction func Reaction5Button(sender: AnyObject) {
        
        
        animateButton(self.reaction5, reaction:5)
        
        
    }
    
    @IBAction func Reaction6Button(sender: AnyObject) {
        
        
        animateButton(self.reaction6, reaction:6)
        
        
    }
    
    
    @IBAction func FlagButton(sender: AnyObject) {
        helperClass.updatePostFlag(self.postId!, uid: self.uid as! String)
        
    }
    
    func animateButton(animationObject: UIButton, reaction:Int) {
        UIView.animateWithDuration(0.3, delay:0.1, options:[], animations: {
            animationObject.transform = CGAffineTransformMakeScale(2, 2)
            }, completion: {_ in
                
                UIView.animateWithDuration(0.3, delay:0.1, options:[], animations: {
                    animationObject.transform = CGAffineTransformMakeScale(0.5, 0.5)
                    animationObject.transform = CGAffineTransformRotate(animationObject.transform, CGFloat(M_PI))
                    animationObject.alpha = 0.5
                    }, completion: {_ in
                        UIView.animateWithDuration(0.4, delay:0.0, options:[], animations: {
                            animationObject.transform = CGAffineTransformMakeScale(1, 1)
                            animationObject.alpha = 1
                            }, completion: {_ in
                                self.myReaction(reaction)
                        })
                })
        })
    }
    
    
    func assignImage(postType:Int, postUid: String  ) {
        
        switch  postType {
            
        case 1:
            self.getImage(postUid)
        case 2:
            self.cellImage.image = UIImage(named:  "Logo")
        default:
            self.cellImage.image = UIImage(named:  "CrystalBall")
        }
        
    }
    
    func getImage(postUid: String) {
        ref.child("Users").child(postUid).observeSingleEventOfType(FIRDataEventType.Value, withBlock:{ (snapshot) in
            let userDetails = snapshot.value as! [String: AnyObject]
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            let profilePicUrl = NSData(contentsOfURL:  fileUrl!)
            self.cellImage.image = UIImage(data: profilePicUrl!)
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 2 )
            customization.addBorder(self.cellImage)
            self.cellImage.layer.cornerRadius  = self.cellImage.frame.width/2
            self.cellImage.clipsToBounds = true;
            
            
        })
        
    }
    
    
    func configureImage(postId: String)  {
        var userUid : String?
        var postTypeId : Int?
        self.ref.child("Posts").child(postId).observeSingleEventOfType(FIRDataEventType.Value,  withBlock: { (snapshot)in
            let pData = snapshot.value as! [String : AnyObject]
            userUid  = pData["useruid"] as? String
            postTypeId = pData["postType"] as? Int
            self.assignImage(postTypeId!, postUid: userUid!)
            
        })
        
        
    }
    
    
    func setReactionCount(postId: String) {
        self.ref.child("Posts").child(postId).child("reactionsData").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let reactionsData = snapshot.value as! [String : Int]
            self.ref.child("Users").child(self.uid as! String).child("Reactions").child(self.postId!).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                self.reaction1Label.text = String(reactionsData["Reaction1"]!)
                self.reaction1Label.textColor = self.grey.getColor()
                self.reaction2Label.text = String(reactionsData["Reaction2"]!)
                self.reaction2Label.textColor = self.grey.getColor()
                self.reaction3Label.text = String(reactionsData["Reaction3"]!)
                self.reaction3Label.textColor = self.grey.getColor()
                self.reaction4Label.text = String(reactionsData["Reaction4"]!)
                self.reaction4Label.textColor = self.grey.getColor()
                self.reaction5Label.text = String(reactionsData["Reaction5"]!)
                self.reaction5Label.textColor = self.grey.getColor()
                self.reaction6Label.text = String(reactionsData["Reaction6"]!)
                self.reaction6Label.textColor = self.grey.getColor()
                
                guard(!snapshot.exists()) else {
                    let rData = snapshot.value as! [String:Int]
                    let userReaction: Int = rData["userReaction"]!
                    
                    
                    switch userReaction{
                    case 1 :
                        self.reaction1Label.textColor = self.green.getColor()
                        break
                    case 2 :
                        self.reaction2Label.textColor = self.green.getColor()
                        break
                    case 3 :
                        self.reaction3Label.textColor = self.green.getColor()
                        break
                    case 4 :
                        self.reaction4Label.textColor = self.green.getColor()
                        break
                    case 5 :
                        self.reaction5Label.textColor = self.green.getColor()
                        break
                    case 6 :
                        self.reaction6Label.textColor = self.green.getColor()
                        break
                    default:
                        break
                        
                    }
                    return
                }
                
            })
            
            
            
            
        })
        
        
    }
    
    
    func setFlagCount(postId: String) {
        self.ref.child("Posts").child(postId).child("flags").observeSingleEventOfType(FIRDataEventType.Value, withBlock:{ (snapshot) in
            let flagsData = snapshot.value as! [String : Int]
            let flagCount: Int =  flagsData["flagCount"]!
            self.flagLabel.text = String(flagCount)
            self.flagLabel.textColor = self.grey.getColor()
            self.ref.child("Users").child(self.uid as! String).child("Flag").child(self.postId!).child("userFlag").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                if(snapshot.exists()){
                    let val =  snapshot.value as!Int
                    if (val == 1){
                       self.flagLabel.textColor = self.red.getColor()
                    }
                }
            })
            
            
        })
    }
    
    func myReaction (reaction: Int) {
        
        
        self.ref.child("Users").child(self.uid! as! String).child("Reactions").child(self.postId!).observeSingleEventOfType(FIRDataEventType.Value, withBlock :  { (snapshot) in
            if(snapshot.exists()){
                let rData =  snapshot.value as! [String : AnyObject]
                let existingReaction = rData["userReaction"]
                
                self.helperClass.updateReactions(self.postId!, uid: self.uid! as! String, Reaction: existingReaction as! Int, newReaction: reaction)
                
            }
            else {
                self.helperClass.updateReactions(self.postId!, uid: self.uid! as! String, Reaction: 0, newReaction: reaction)
            }
            
            
            
        })
        
        
        
    }
    
    
    
}
