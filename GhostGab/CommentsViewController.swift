//
//  CommentsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/18/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import SCLAlertView
import Alamofire
import OneSignal


extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x:self.center.x + 10, y:self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
}


class CommentsViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileViewImage: UIImageView!
    
    @IBOutlet weak var postName: UILabel!
    
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var commentsCountLabe: UILabel!
    
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
    
    @IBOutlet weak var keyboardView: UIView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var replyText: UILabel!
    
    let green : Color = Color.green
    
    let red : Color = Color.red
    
    let grey :Color = Color.grey
    
    let verylightGrey : Color = Color.verylightGrey
    
    let ref = FIRDatabase.database().reference()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    var helperClass : HelperFunctions = HelperFunctions()
    
    var thisPostArray = [String:AnyObject]()
    
    var postId: String = ""
    
    var origianlPostUserId: String = ""
    
    var origianlPostOneSignalId: String = ""
    
    var width:CGFloat = 1
    
    var overlayView = UIView()
    
    var spinner:loadingAnimation?
    
    var commentArray = [String : AnyObject]()
    
    var commentArrayKey = [String]()
    
    
    @IBOutlet weak var keyboardBottomViewcontraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.spinner?.showOverlayNew(alphaValue: 1)
        self.postLabel.text = thisPostArray["post"] as! String?
        self.origianlPostUserId = (thisPostArray["useruid"]  as! String?)!
        self.dateLabel.text = helperClass.getDifferenceInDates(postDate: (thisPostArray["date"]as? String)!)
        self.setFlagCount(postId: self.postId)
        self.setReactionCount(postId: self.postId)
        self.setRepliesText(postId: self.postId)
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor.white
        
        if(thisPostArray["postType"]as! Int == 1){
            self.getThisUserData()
        }
        else if(thisPostArray["postType"] as! Int == 2){
            self.setUpGhost()
        }
        else if(thisPostArray["postType"] as! Int == 3){
            self.setUpGuess()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        self.getComments()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleKeyboardNotification(notification:NSNotification){
        if let notificationinfo = notification.userInfo{
            let keyboardFrame = (notificationinfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeybaordShowing = notification.name == .UIKeyboardWillShow
            self.keyboardBottomViewcontraint.constant = isKeybaordShowing ? -(keyboardFrame?.height)! : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            
            
        }
        
        
    }
    
    func getThisUserData() {
        self.ref.child("Users").child(self.origianlPostUserId as! String).observe(FIRDataEventType.value, with: { (snapshot) in
            
            let userDetails = snapshot.value as! [String: AnyObject]
            self.postName.text =  userDetails["displayName"] as? String;
            self.origianlPostOneSignalId = (userDetails["oneSignalId"] as? String)!
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            
            Alamofire.request(userDetails["highResPhoto"] as! String).responseData { response in
                if let alamofire_image = response.result.value {
                    let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
                    self.profileViewImage.image = UIImage(data: profilePicUrl! as Data)
                    self.spinner?.hideOverlayViewNew()
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
        self.spinner?.hideOverlayViewNew()

    }
    
    func setUpGuess() {
         self.postName.text = "Guess me"
        self.profileViewImage.image  = UIImage(named:  "CrystalBall")
        self.profileViewImage.layer.cornerRadius  = self.profileViewImage.frame.width/2
        self.profileViewImage.clipsToBounds = true;
        let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 1 )
        customization.addBorder(object: self.profileViewImage)
        self.spinner?.hideOverlayViewNew()
        
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
    
    @IBAction func Back_btn(_ sender: Any) {
        
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
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var imageName = "no_comments.png"
        var labelText = "Be the first to gab back!!! "
        
        if let commentLength : Int = self.commentArrayKey.count{
            if (commentLength > 0){
                self.tableView.backgroundView = .none
                self.tableView.separatorStyle = .singleLine
                return commentLength
            }
            else {
                imageName = "no_comments.png"
                labelText = "Be the first to gab back!!! "
                displyNoDataLabel(imageName:imageName, labelText:labelText)
                return 0
                
            }
        }
        
        else{
            return self.commentArrayKey.count
        }
       
    }
    
    func displyNoDataLabel(imageName: String, labelText: String) -> Void {
        
        let image : UIImage = UIImage(named: imageName)!
        let imageView :UIImageView = UIImageView(image: image)
        imageView.frame = CGRect(x:self.tableView.frame.width/2 - 37.5, y:self.tableView.frame.height/3, width:60, height:50)
        let textColor: Color = Color.grey
        let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:self.tableView.frame.height/8, width:self.tableView.frame.width, height:self.tableView.frame.height) )
        
        noDataAvailableLabel.text =  labelText
        noDataAvailableLabel.textAlignment = .center
        noDataAvailableLabel.textColor =  textColor.getColor()
        noDataAvailableLabel.font = UIFont(name: "Avenir-Next", size:14.0)
        self.tableView.separatorStyle = .none
        var noFriendsView : UIView = UIView( frame: CGRect(x:0, y:300, width:self.tableView.frame.width, height:self.tableView.frame.height))
        noFriendsView.addSubview(imageView)
        noFriendsView.addSubview(noDataAvailableLabel)
        self.tableView.backgroundView = noFriendsView
        
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! CommentsTableViewCell
        var commentFeed :[String: AnyObject] = self.commentArray[self.commentArrayKey[indexPath.row]]! as! [String : AnyObject]
        commentCell.postId = self.postId
        commentCell.commentId = self.commentArrayKey[indexPath.row]
        if(commentFeed["commentType"] as! Int == 1){
             commentCell.commentName.text = commentFeed["commentDisplayName"] as! String?
        }
        if(commentFeed["commentType"] as! Int == 2){
             commentCell.commentName.text = ""
        }
        commentCell.commentText.text = commentFeed["commentText"] as! String?
       
        commentCell.commentDate.text = helperClass.getDifferenceInDates(postDate: commentFeed["commentdate"] as! String)
        commentCell.setCommentFlagCount(postId: self.postId, commentId: self.commentArrayKey[indexPath.row])
        commentCell.setImage(commentType: commentFeed["commentType"] as! Int, commentImageUrl: commentFeed["commentPicUrl"] as! String )
        commentCell.deletButton.isHidden = true
        if(commentFeed["useruid"] as! String == self.uid as! String){
            commentCell.deletButton.isHidden = false
        }
        return commentCell
        
    }

    @IBAction func gabAsMe(_ sender: Any) {
        if((self.commentTextField.text?.isEmpty)! || (self.commentTextField.text?.characters.count)! > 200 ){
            self.keyboardView.shake()
        }
        else {
            self.saveComment(commentType: 1)
            
        }
        
    }
    @IBAction func gabBackasGhost(_ sender: Any) {
        if((self.commentTextField.text?.isEmpty)! || (self.commentTextField.text?.characters.count)! > 200 ){
            self.keyboardView.shake()
        }
        else {
            self.saveComment(commentType: 2)
            
        }
        
    }
    
    @IBAction func cancelGabBack(_ sender: Any) {
        returnFromComment()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func saveComment(commentType: Int){
        let currentDateToString: String = helperClass.returnCurrentDateinString()
        self.ref.child("Users").child(self.uid as! String).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            if(snapshot.exists()){
                let userData =  snapshot.value as! [String:AnyObject]
                let commentDisplayName = userData["displayName"]
                let commentPicUrl = userData["highResPhoto"]
                let commentFlags =  0
                let commentText: String = self.commentTextField.text!
                let commentData : [String: AnyObject] = ["commentText":commentText as AnyObject , "useruid": self.uid as AnyObject, "commentDisplayName":commentDisplayName!, "commentPicUrl" : commentPicUrl!, "commentType":commentType as AnyObject,  "commentFlags":commentFlags as AnyObject, "commentdate":currentDateToString as AnyObject, "timestamp":NSDate().timeIntervalSince1970 as AnyObject]
                
                let commentsDataRef = self.ref.child("Posts").child(self.postId).child("Comments").childByAutoId()
                commentsDataRef.setValue(commentData)
                self.returnFromComment()
            }
            
            
        })
        
        
    }
    
    func getComments(){
        ref.child("Posts").child(self.postId).child("Comments").queryOrdered(byChild: "timestamp").observe(FIRDataEventType.value, with: { (snapshot) in
            self.commentArrayKey.removeAll()
            self.commentArray.removeAll()
            if( !snapshot.exists()){
               
                self.tableView.reloadData()
                
            }else {
               var commentData  =  snapshot.value as! NSDictionary
                for (key, val) in commentData {
                    self.commentArrayKey.append(key as! String)
                    self.commentArray[key as! String] = val as! AnyObject
                    
                }
                 self.commentArrayKey.sort()
                self.tableView.reloadData()
            }
            
        })
        

    }
    
    func returnFromComment(){
        self.view.endEditing(true)
        self.commentTextField.text = ""
    }

}
