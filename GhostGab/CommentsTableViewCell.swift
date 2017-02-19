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
    
    @IBOutlet weak var flagButton: UIButton!
    
    @IBOutlet weak var commentFlagCount: UILabel!
    
    @IBOutlet weak var deletButton: UIButton!
    
    let ref = FIRDatabase.database().reference()
    
    var postId: String?
    
    var commentId: String?
    
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
                    self.commentImage.layer.cornerRadius  = self.commentImage.frame.width/2
                    self.commentImage.clipsToBounds = true;
                    let costomization:UICostomization =  UICostomization(color: self.green.getColor(), width:1)
                    costomization.addRoundedBorder(object: self.commentImage)
                }
            }
        }
        else {
             self.commentImage.image = UIImage(named:  "Logo")
        }
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
    
}
