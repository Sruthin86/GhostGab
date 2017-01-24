//
//  PostCellTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
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
    
    @IBOutlet weak var flagButton: UIButton!
    
    var postId: String?
    
    var helperClass : HelperFunctions = HelperFunctions()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let verylightGrey : Color = Color.verylightGrey
    
    let red : Color = Color.red
    
    let grey :Color = Color.grey
    
    let green : Color = Color.green
    
    var imageCache = NSCache<NSString, UIImage>();
    
    var redflag : UIImage = UIImage(named: "Flag_red@1x")!
    //@IBOutlet weak var reaction1: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let customization: UICostomization = UICostomization (color: verylightGrey.getColor(), width:width)
        customization.addBackground(object: self)
        customization.addBorder(object: ReactionsView)
        //customization.addBorder(object: FeedView)
        super.awakeFromNib()
        reactionsViewHeight.constant = 0
        self.ReactionsContent.isHidden = true
        self.ReactionsView.isHidden = true
        self.selectionStyle = UITableViewCellSelectionStyle.none
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func openReactionsView(){
        
        reactionsViewHeight.constant = 76
        self.ReactionsContent.isHidden = false
        self.ReactionsView.isHidden = false
        
    }
    func closeReactionsView(){
        reactionsViewHeight.constant = 0
        self.ReactionsContent.isHidden = true
        self.ReactionsView.isHidden = true
        
    }
    
    @IBAction func ReactionButton(_ sender: AnyObject) {
        
        
        animateButton(animationObject: self.reaction1, reaction:1)
        
        
        
    }
    
    
    @IBAction func Reaction2Button(_ sender: AnyObject) {
        
        animateButton(animationObject: self.reaction2,reaction:2)
        
        
        
    }
    
    @IBAction func Reaction3Button(_ sender: AnyObject) {
        
        animateButton(animationObject: self.reaction3,reaction:3)
        
        
        
    }
    
    
    @IBAction func Reaction4Button(_ sender: AnyObject) {
        
        animateButton(animationObject: self.reaction4, reaction:4)
        
        
        
    }
    
    
    @IBAction func Reaction5Button(_ sender: AnyObject) {
        
        
        animateButton(animationObject: self.reaction5, reaction:5)
        
        
    }
    
    @IBAction func Reaction6Button(_ sender: AnyObject) {
        
        
        animateButton(animationObject: self.reaction6, reaction:6)
        
        
    }
    
    
    @IBAction func FlagButton(_ sender: AnyObject) {
        animateButton(animationObject: self.flagButton, reaction:7)
        
        
    }
    
    func animateButton(animationObject: UIButton, reaction:Int) {
        UIView.animate(withDuration: 0.3, delay:0.1, options:[], animations: {
            animationObject.transform = CGAffineTransform(scaleX: 2, y: 2)
        }, completion: {_ in
            
            UIView.animate(withDuration: 0.4, delay:0.1, options:[], animations: {
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
                    else if (reaction == 7){
                        self.helperClass.updatePostFlag(postId: self.postId!, uid: self.uid as! String)
                    }
                })
            })
        })
    }
    
    
    func assignImage(postType:Int, userUid: String, userPicUrl: String  ) {
        
        switch  postType {
            
        case 1:
            
            
            if let profileImage :UIImage = (imageCache.object(forKey: userUid as NSString)){
                self.cellImage.image = profileImage
            }
            else {
                self.cellImage.image = UIImage(named:  "PlaceHolder")
                //DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                self.getImage(userUid: userUid, userPicUrl: userPicUrl)
                //})
            }
            
            
        case 2:
            self.cellImage.image = UIImage(named:  "Logo")
        default:
            self.cellImage.image = UIImage(named:  "CrystalBall")
        }
        
    }
    
    func getImage(userUid: String, userPicUrl:String) {
        
        let fileUrl = NSURL(string: userPicUrl)
        let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
        self.cellImage.image = UIImage(data: profilePicUrl! as Data)
        
        let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 2 )
        customization.addBorder(object: self.cellImage)
        imageCache.setObject(UIImage(data: profilePicUrl! as Data)!, forKey: userUid as NSString)
        self.cellImage.layer.cornerRadius  = self.cellImage.frame.width/2
        self.cellImage.clipsToBounds = true;
        
        
    }
    
    
    func configureImage(_ userUid: String, postType: Int, userPicUrl: String)  {
        
        self.assignImage(postType: postType, userUid: userUid , userPicUrl:userPicUrl)
        
        
        
    }
    
    
    func setReactionCount(postId: String) {
        self.ref.child("Posts").child(postId).child("reactionsData").observe(FIRDataEventType.value, with: { (snapshot) in
            
             if(snapshot.exists()){
                let reactionsData = snapshot.value as! [String : Int]
                self.ref.child("Users").child(self.uid as! String).child("Reactions").child(self.postId!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
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
                
            }
            
            
        })
        
        
    }
    
    
    func setFlagCount(postId: String) {
      
        self.ref.child("Posts").child(postId).child("flags").observeSingleEvent(of: FIRDataEventType.value, with:{ (snapshot) in
            if(snapshot.exists()){
                    let flagsData = snapshot.value as! [String : Int]
                    var flagCount: Int =  flagsData["flagCount"]!
                    self.flagLabel.text = String(flagCount)
                    self.flagLabel.textColor = self.grey.getColor()
                    

                    self.ref.child("Users").child(self.uid as! String).child("Flag").child(self.postId!).child("userFlag").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                        
                        if(snapshot.exists()){
                            let val =  snapshot.value as!Int
                            if (val == 1){
                                self.flagLabel.textColor = self.red.getColor()
                            }
                        }
                    })
            }
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
    
    
    
}
