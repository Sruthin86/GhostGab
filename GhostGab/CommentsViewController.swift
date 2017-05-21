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
    
    
    @IBOutlet weak var keyboardView: UIView!
    
     @IBOutlet weak var commentTextField: UITextField!
    let green : Color = Color.green
    
    let lightGreen : Color = Color.lightGreen
    
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
    
    var commentingUserOneSignalId: String = ""
    
    var origianlPostText: String = ""
    
    var width:CGFloat = 1
    
    var overlayView = UIView()
    
    var spinner:loadingAnimation?
    
    var commentArray = [String : AnyObject]()
    
    var commentArrayKey = [String]()
    
    var checkUserNotificationKeys = [String]()
    
    var isThisUserFriend:Bool = false
    
    @IBOutlet weak var keyboardBottomViewcontraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.spinner?.showOverlayNew(alphaValue: 1)
        self.origianlPostUserId = (thisPostArray["useruid"]  as! String?)!
        origianlPostText = (thisPostArray["post"] as! String?)!
        self.tableView.allowsSelection = true
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor.white
        
        let customization : UICostomization = UICostomization(color: lightGreen.getColor(), width: 5 )
        customization.addBorder(object: self.commentTextField)
        
        
        self.getCommentingUsersOnesignalId()
        self.getThisUsersOnesignalId()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        self.checkIfTheUserIsaFreind()
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
            self.keyboardBottomViewcontraint.constant = isKeybaordShowing ? (keyboardFrame?.height)!-50 : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            
            
        }
        
        
    }
    
    func getCommentingUsersOnesignalId(){
        self.ref.child("Users").child(self.uid as! String).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let commentingUsersData = snapshot.value as! NSDictionary
                if((commentingUsersData["oneSignalId"]) != nil){
                    self.commentingUserOneSignalId = commentingUsersData["oneSignalId"] as! String
                }
            }
        })
    }
    
    func getThisUsersOnesignalId(){
        self.ref.child("Users").child(self.origianlPostUserId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let userDetails = snapshot.value as! [String: AnyObject]
                if(userDetails["oneSignalId"] != nil){
                    self.origianlPostOneSignalId = (userDetails["oneSignalId"] as? String)!
                }
                
               
            }
           
        
            
            
        })
    }
    
    func checkIfTheUserIsaFreind() {
        if(self.origianlPostUserId == self.uid as! String){
            self.isThisUserFriend = true
        }
        else {
            self.ref.child("Users").child(self.uid as! String).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if(snapshot.exists()){
                    let userData = snapshot.value as! NSDictionary
                    
                    if(userData["Friends"] != nil){
                        let userFriends = userData["Friends"] as! NSDictionary
                        if(userFriends[self.origianlPostUserId] != nil){
                           self.isThisUserFriend = true
                        }
                            
                        else {
                            self.isThisUserFriend = false
                        }
                    }
                    else {
                        self.isThisUserFriend = false
                    }
                }
            })
        }
        
    }
    
  
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var imageName = "no_comments.png"
        var labelText = "Be the first to gab back!!! "
        
        if(section == 0){
            return 1
        }
        else {
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
        
        
    }
    
    func displyNoDataLabel(imageName: String, labelText: String) -> Void {
        
        let image : UIImage = UIImage(named: imageName)!
        let imageView :UIImageView = UIImageView(image: image)
        imageView.frame = CGRect(x:self.tableView.frame.width/2 - 37.5, y:self.tableView.frame.height/(1.5), width:60, height:50)
        let textColor: Color = Color.grey
        let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:self.tableView.frame.height/3, width:self.tableView.frame.width, height:self.tableView.frame.height) )
        
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
        if(indexPath.section == 0){
            return 220
        }
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.section == 0){
             let commentCell = tableView.dequeueReusableCell(withIdentifier: "original_post_cell", for: indexPath) as! CommentsTableViewCell
            commentCell.postId = self.postId
            commentCell.origianlPostUserId = self.origianlPostUserId
            if(thisPostArray["postType"]as! Int == 1){
                commentCell.getThisUserData()
            }
            else if(thisPostArray["postType"] as! Int == 2){
                commentCell.setUpGhost()
            }
            else if(thisPostArray["postType"] as! Int == 3){
                commentCell.setUpGuess()
            }
            else if(thisPostArray["postType"] as! Int == 4){
                commentCell.setUpUserForFriends()
            }
            commentCell.postLabel.text = thisPostArray["post"] as! String?
            commentCell.dateLabel.text = helperClass.getDifferenceInDates(postDate: (thisPostArray["date"]as? String)!)
            commentCell.setFlagCount(postId: self.postId)
            commentCell.setReactionCount(postId: self.postId)
            commentCell.setRepliesText(postId: self.postId)
            return commentCell
        }
        
        else {
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! CommentsTableViewCell
            var commentFeed :[String: AnyObject] = self.commentArray[self.commentArrayKey[indexPath.row]]! as! [String : AnyObject]
            commentCell.postId = self.postId
            commentCell.commentId = self.commentArrayKey[indexPath.row]
            commentCell.origianlPostUserId = self.origianlPostUserId
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
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            if((thisPostArray["postType"]as! Int == 1 ) || (thisPostArray["postType"]as! Int == 4 && self.isThisUserFriend) ){
                if(self.origianlPostUserId == self.uid as! String){
                    let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                    let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                    mainTabBarView.selectedIndex = 2
                    //trasition from left
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
                    self.present(mainTabBarView, animated: false, completion: nil)
                }
                else {
                    let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
                    let friendDetailsView  = storybaord.instantiateViewController(withIdentifier: "friend_details") as! FriendDetailsViewController
                    friendDetailsView.friendUdid = self.origianlPostUserId
                    //trasition from right
                    self.navigationController?.pushViewController(friendDetailsView, animated:true)
                }
            }
        }
        else if(indexPath.section == 1){
            var commentFeed :[String: AnyObject] = self.commentArray[self.commentArrayKey[indexPath.row]]! as! [String : AnyObject]
             if(commentFeed["commentType"] as! Int == 1){
                if( commentFeed["useruid"] as! String == self.uid as! String){
                    let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                    let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                    mainTabBarView.selectedIndex = 2
                    //trasition from left
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
                    self.present(mainTabBarView, animated: false, completion: nil)
                }
                else {
                    let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
                    let friendDetailsView  = storybaord.instantiateViewController(withIdentifier: "friend_details") as! FriendDetailsViewController
                    friendDetailsView.friendUdid = commentFeed["useruid"] as! String
                    //trasition from right
                    self.navigationController?.pushViewController(friendDetailsView, animated:true)
                }
            }
        }
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
                let commentData : [String: AnyObject] = ["commentText":commentText as AnyObject , "useruid": self.uid as AnyObject, "commentDisplayName":commentDisplayName!, "commentPicUrl" : commentPicUrl!, "commentType":commentType as AnyObject,  "commentFlags":commentFlags as AnyObject, "commentdate":currentDateToString as AnyObject, "timestamp":NSDate().timeIntervalSince1970 as AnyObject, "commentingUserOneSignalId": self.commentingUserOneSignalId as AnyObject]
                
                let commentsDataRef = self.ref.child("Posts").child(self.postId).child("Comments").childByAutoId()
                commentsDataRef.setValue(commentData)
                if( self.origianlPostUserId != self.uid as! String) {
                    var  notificationText: String = ""
                    if(commentType == 2 ){
                           notificationText = "Someone commented on your post ' " + self.origianlPostText + " ' "
                    }
                    else {
                        notificationText = (commentDisplayName  as? String)! + " commented on your post ' " + self.origianlPostText + " ' "
                    }
                    
                    
                    OneSignal.postNotification(["contents": ["en": notificationText], "include_player_ids": [self.origianlPostOneSignalId]])
                    self.helperClass.saveNotification(notificationType: 1, postId: self.postId, notificationText: notificationText, useruid: self.origianlPostUserId )
                }
                self.sendNotificationsToAll(commentType: commentType, commentDisplayName:commentDisplayName as! String)
                self.returnFromComment()
            }
            
            
        })
        
        
    }
    
    func getComments(){
        ref.child("Posts").child(self.postId).child("Comments").queryOrdered(byChild: "timestamp").observe(FIRDataEventType.value, with: { (snapshot) in
            self.commentArrayKey.removeAll()
            self.commentArray.removeAll()
            if( !snapshot.exists()){
                self.spinner?.hideOverlayViewNew()
                self.tableView.reloadData()
                
            }else {
                var commentData  =  snapshot.value as! NSDictionary
                for (key, val) in commentData {
                    self.commentArrayKey.append(key as! String)
                    self.commentArray[key as! String] = val as! AnyObject
                    
                }
                self.commentArrayKey.sort()
                self.tableView.reloadData()
                self.spinner?.hideOverlayViewNew()
            }
            
        })
        
        
    }
    
    
    
    func returnFromComment(){
        self.view.endEditing(true)
        self.commentTextField.text = ""
    }
    
    func sendNotificationsToAll(commentType: Int, commentDisplayName:String){
        var  notificationText: String = ""
        self.ref.child("Posts").child(self.postId).child("Comments").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let commentData: NSDictionary = snapshot.value as! NSDictionary
                for (key, val) in commentData{
                    let comment: NSDictionary = val as! NSDictionary
                    let commentUid :String = comment["useruid"] as! String
                    print("commentUid")
                    print(commentUid)
                    if(comment["commentingUserOneSignalId"] != nil){
                        let commentOneSignalId: String = comment["commentingUserOneSignalId"] as! String
                        if(self.uid as! String == commentUid as! String || self.origianlPostUserId == commentUid as! String || self.checkUserNotificationKeys.contains(commentUid as! String)){
                            //don't send notification
                        }
                        else {
                            print("in else")
                            self.checkUserNotificationKeys.append(commentUid as! String)
                            if(commentType == 2 ){
                                notificationText = "Someone commented on the post ' " + self.origianlPostText + " ' "
                                
                                
                            }
                            else {
                                notificationText = (commentDisplayName  as? String)! + " also commented on the post ' " + self.origianlPostText + " ' "
                                
                            }
                            self.helperClass.saveNotification(notificationType: 1, postId: self.postId, notificationText: notificationText, useruid: commentUid )
                             OneSignal.postNotification(["contents": ["en": notificationText], "include_player_ids": [commentOneSignalId]])
                          
                        }
                        
                    }
                }
                self.checkUserNotificationKeys.removeAll()
            }
        })
    }
    
}
