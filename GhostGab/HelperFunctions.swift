//
//  HelperFunctions.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import OneSignal

class HelperFunctions {
    
    let ref = FIRDatabase.database().reference()
    func returnFromTextField(textField: UITextField! , PostButtonsView: UIView, ButtonViewHeight: NSLayoutConstraint, TopViewHeight: NSLayoutConstraint  ) //
    {
        
        
        textField.resignFirstResponder()
        textField.text = ""
        PostButtonsView.isHidden = true
        ButtonViewHeight.constant = 0
        TopViewHeight.constant = 65
        
        
        
    }
    
    func returnCurrentDateinString() -> String {
        let currentDate = NSDate()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let currentDateToString = dateformatter.string(from: currentDate as Date)
        return currentDateToString
    }
    
    
    func getDifferenceInDates(postDate:String) ->String  {
        
        
        let currDate = NSDate()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let formattedCurrentDate =  dateformatter.string(from: currDate as Date)
        let firstDate = dateformatter.date(from: postDate)
        let secondDate = dateformatter.date(from: formattedCurrentDate)
        return compareDates(pDate: firstDate! as NSDate, curDate: secondDate! as NSDate)
        
        
    }
    
    func compareDates (pDate:NSDate , curDate:NSDate) ->String {
        var dateString:String?
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.medium
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year, .hour, .minute, .second])
        let diffDateComponents = calendar.dateComponents(unitFlags, from: pDate as Date,  to: curDate as Date)
        
        if(diffDateComponents.year != 0){
            dateString = dateformatter.string(from: pDate as Date)
        }
        else if (diffDateComponents.month != 0){
            dateString = dateformatter.string(from: pDate as Date)
        }
            
        else if (diffDateComponents.day != 0){
            dateString = String(describing: diffDateComponents.day!) + " days ago"
        }
            
        else if(diffDateComponents.hour != 0 ){
            dateString = String(describing: diffDateComponents.hour!) + " hrs ago"
        }
        else if(diffDateComponents.minute != 0){
            dateString = String(describing: diffDateComponents.minute!) + " mins ago"
        }
        else if(diffDateComponents.second != 0){
            dateString = String(describing: diffDateComponents.second!) + " s ago"
        }
        else {
            dateString = "now"
        }
        return dateString!
    }
    
    
    func updateReactions(postId:String, uid:String,  Reaction:Int, newReaction:Int) {
        
        guard (Reaction == newReaction ) else {
            var reactionsInUser = [String: AnyObject]()
            reactionsInUser["userReaction"] = newReaction as AnyObject?
            let postRef =  self.ref.child("Posts").child(postId)
            postRef.observeSingleEvent(of: FIRDataEventType.value , with:{ (snapshot) in
                let pData = snapshot.value as![String: AnyObject]
                let reactions = pData["reactionsData"]as![String: AnyObject]
                
                switch Reaction {
                case 1:
                    var rec1 = reactions["Reaction1"] as! Int
                    rec1 -= 1
                    postRef.child("reactionsData").child("Reaction1").setValue(rec1)
                    break
                case 2:
                    var rec2 = reactions["Reaction2"] as! Int
                    rec2 -= 1
                    postRef.child("reactionsData").child("Reaction2").setValue(rec2)
                    break
                case 3:
                    var rec3 = reactions["Reaction3"] as! Int
                    rec3 -= 1
                    postRef.child("reactionsData").child("Reaction3").setValue(rec3)
                    break
                case 4:
                    var rec4 = reactions["Reaction4"] as! Int
                    rec4 -= 1
                    postRef.child("reactionsData").child("Reaction4").setValue(rec4)
                    break
                case 5:
                    var rec5 = reactions["Reaction5"] as! Int
                    rec5 -= 1
                    postRef.child("reactionsData").child("Reaction5").setValue(rec5)
                    break
                case 6:
                    var rec6 = reactions["Reaction6"] as! Int
                    rec6 -= 1
                    postRef.child("reactionsData").child("Reaction6").setValue(rec6)
                    break
                    
                default:
                    break
                    
                }
                
                
                switch newReaction {
                case 1:
                    var rec1 = reactions["Reaction1"] as! Int
                    rec1 += 1
                    postRef.child("reactionsData").child("Reaction1").setValue(rec1)
                    break
                case 2:
                    var rec2 = reactions["Reaction2"] as! Int
                    rec2 += 1
                    postRef.child("reactionsData").child("Reaction2").setValue(rec2)
                    break
                case 3:
                    var rec3 = reactions["Reaction3"] as! Int
                    rec3 += 1
                    postRef.child("reactionsData").child("Reaction3").setValue(rec3)
                    break
                case 4:
                    var rec4 = reactions["Reaction4"] as! Int
                    rec4 += 1
                    postRef.child("reactionsData").child("Reaction4").setValue(rec4)
                    break
                case 5:
                    var rec5 = reactions["Reaction5"] as! Int
                    rec5 += 1
                    postRef.child("reactionsData").child("Reaction5").setValue(rec5)
                    break
                case 6:
                    var rec6 = reactions["Reaction6"] as! Int
                    rec6 += 1
                    postRef.child("reactionsData").child("Reaction6").setValue(rec6)
                    break
                default:
                    break
                }
            })
            
            
            
            
            
            self.ref.child("Users").child(uid).child("Reactions").child(postId).setValue(reactionsInUser)
            return
        }
    }
    
    
    func updatePostFlag(postId:String, uid:String) {
        
        var flagsInUser = [String: Int]()
        
        
        let uRef = ref.child("Users").child(uid)
        let pRef = ref.child("Posts").child(postId)
        
        pRef.child("FlaggedUsers").child(uid).setValue(uid)
        uRef.child("Flag").child(postId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            if(snapshot.exists()){
                let flagVal =  snapshot.value as! [String:Int]
                let fCount : Int = flagVal["userFlag"]!
                if(fCount == 1 ){
                    flagsInUser["userFlag"] = 0
                    uRef.child("Flag").child(postId).setValue(flagsInUser)
                    pRef.child("flags").observeSingleEvent(of: FIRDataEventType.value, with:  { (snapshot) in
                        let flags = snapshot.value as! [String: Int]
                        var flagCount: Int = flags["flagCount"]!
                        flagCount -= 1
                        pRef.child("flags").child("flagCount").setValue(flagCount)
                    })
                }
                else if(fCount == 0 ){
                    flagsInUser["userFlag"] = 1
                    uRef.child("Flag").child(postId).setValue(flagsInUser)
                    pRef.child("flags").observeSingleEvent(of: FIRDataEventType.value, with:  { (snapshot) in
                        let flags = snapshot.value as! [String: Int]
                        var flagCount: Int = flags["flagCount"]!
                        flagCount += 1
                        pRef.child("flags").child("flagCount").setValue(flagCount)
                        if(flagCount>=5){
                            self.deletePost(postId:postId)
                        }
                        
                    })
                }
                
                
            }
            else {
                flagsInUser["userFlag"] = 1
                uRef.child("Flag").child(postId).setValue(flagsInUser)
                pRef.child("flags").observeSingleEvent(of: FIRDataEventType.value, with:  { (snapshot) in
                    let flags = snapshot.value as! [String: Int]
                    var flagCount: Int = flags["flagCount"]!
                    flagCount += 1
                    pRef.child("flags").child("flagCount").setValue(flagCount)
                    if(flagCount>=5){
                        self.deletePost(postId:postId)
                    }
                })
                
                
            }
            
        })
        
        
        
        
    }
    
    func updateCommentFlag(postId:String, uid:String, commentId:String){
        ref.child("Posts").child(postId).child("Comments").child(commentId).observeSingleEvent(of: FIRDataEventType.value, with:{ (snapshot) in
            if(snapshot.exists()){
                let commentsData = snapshot.value as! NSDictionary
                var flagCount: Int =  commentsData["commentFlags"]! as! Int
                 if(commentsData["commentFlagUsers"] != nil){
                    let commentFlaggedUsers = commentsData["commentFlagUsers"] as! NSDictionary
                    print(commentFlaggedUsers)
                    if(commentFlaggedUsers[uid] != nil){
                        self.ref.child("Posts").child(postId).child("Comments").child(commentId).child("commentFlagUsers").child(uid).removeValue()
                       flagCount -= 1
                        self.ref.child("Posts").child(postId).child("Comments").child(commentId).child("commentFlags").setValue(flagCount)
                    }
                    else {
                        flagCount += 1
                        self.ref.child("Posts").child(postId).child("Comments").child(commentId).child("commentFlagUsers").child(uid).setValue(uid)
                        self.ref.child("Posts").child(postId).child("Comments").child(commentId).child("commentFlags").setValue(flagCount)
                    }
                }
                 else {
                    flagCount += 1
                    self.ref.child("Posts").child(postId).child("Comments").child(commentId).child("commentFlagUsers").child(uid).setValue(uid)
                    self.ref.child("Posts").child(postId).child("Comments").child(commentId).child("commentFlags").setValue(flagCount)
                }
                
                if( flagCount >= 5){
                  self.deleteComment(postId:postId, commentId:commentId)
                }
                
                
            }
            
        })
        
    }
    
    func deleteComment(postId:String, commentId:String){
        self.ref.child("Posts").child(postId).child("Comments").child(commentId).removeValue()
    }
    
    func deletePost(postId:String) {
        
        self.ref.child("Posts").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()){
                var deletePostArray = snapshot.value as! NSDictionary
                
                if((deletePostArray["ReactedUsers"]) != nil){
                    
                    var reactedUserArray = deletePostArray["ReactedUsers"] as! NSDictionary
                    for (key,val) in reactedUserArray{
                        self.ref.child("Users").child(key as! String).child("Reactions").child(postId).removeValue()
                        
                    }
                    
                }
                
                if((deletePostArray["FlaggedUsers"]) != nil){
                    
                    var flaggedUserArray = deletePostArray["FlaggedUsers"] as! NSDictionary
                    for (key,val) in flaggedUserArray{
                        self.ref.child("Users").child(key as! String).child("Flag").child(postId).removeValue()
                        
                    }
                    
                }
                
                if((deletePostArray["guessedUsers"]) != nil){
                    
                    var guessedUsersArray = deletePostArray["guessedUsers"] as! NSDictionary
                    for (key,val) in guessedUsersArray{
                        self.ref.child("Users").child(key as! String).child("guess").child(postId).removeValue()
                        
                    }
                    
                }
                
                self.ref.child("Users").child(deletePostArray["useruid"] as! String).child("posts").child(postId).removeValue()
                self.ref.child("Posts").child(postId).removeValue()
                NotificationCenter.default.post(name: .reload, object: nil)
                NotificationCenter.default.post(name: .reloadposts, object: nil)
                
            }
            else {
                
            }
        })
        
    }
    
    
    func reportPosts(postId: String, userUid:String){
        var reported: Int = 0
        
        self.ref.child("Posts").child(postId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                
                let postData  = snapshot.value as! NSDictionary
                let postedUserId = postData["useruid"] as! String
                let postText = postData["post"] as! String
                if(postData["Reported"] != nil){
                    reported = postData["Reported"] as! Int
                    reported = reported+1
                    if(reported > 3){
                        self.ref.child("Users").child(postedUserId).child("oneSignalId").observeSingleEvent(of: FIRDataEventType.value, with: { (snap) in
                            if(snap.exists()){
                                var notificationText: String = "your post about ' " + postText + " ' has been reported and deleted"
                                var postedUseroneSignalId = snap.value as! String
                                OneSignal.postNotification(["contents": ["en": notificationText], "include_player_ids": [postedUseroneSignalId]])
                                self.deletePost(postId: postId)
                            }
                        })
                        
                    }
                    else {
                        self.ref.child("Posts").child(postId).child("Reported").setValue(reported)
                        self.ref.child("Posts").child(postId).child("reportedUsers").child(userUid).setValue(userUid)
                    }
                }
                else {
                    reported = reported+1
                    self.ref.child("Posts").child(postId).child("Reported").setValue(reported)
                    self.ref.child("Posts").child(postId).child("reportedUsers").child(userUid).setValue(userUid)
                }
                self.hideReportedPostFromTimeline(postId: postId, userUid:userUid)
                
                
                
            }
            else {
                
            }
        })
    }
    
    
    func hideReportedPostFromTimeline(postId: String, userUid:String){
        self.ref.child("Users").child(userUid).child("reportedGabs").child(userUid).setValue(userUid)
        NotificationCenter.default.post(name: .reloadposts, object: nil)
    }
    
    
    func muteUser(_postId: String, userUid: String){
        self.ref.child("Posts").child(_postId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let postData = snapshot.value as! NSDictionary
                let postedUserId = postData["useruid"] as! String
                let postedUserDisplayName = postData["displayName"] as! String
                self.ref.child("Users").child(userUid).child("mutedUsers").child(postedUserId).setValue(postedUserDisplayName)
                self.ref.child("Users").child(postedUserId).child("mutedByUsers").child(userUid).setValue(userUid)
            }
        })
    }
    
    
    func blockUser(_postId: String, userUid: String){
        self.ref.child("Posts").child(_postId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let postData = snapshot.value as! NSDictionary
                let postedUserId = postData["useruid"] as! String
                let postedUserDisplayName = postData["displayName"] as! String
                self.ref.child("Users").child(userUid).child("Friends").child(postedUserId).removeValue()
                self.ref.child("Users").child(postedUserId).child("Friends").child(userUid).removeValue()
                self.ref.child("Users").child(userUid).child("blockedUsers").child(postedUserId).setValue(postedUserDisplayName)
                self.ref.child("Users").child(postedUserId).child("blockedByUsers").child(userUid).setValue(userUid)
            }
        })
        
    }
    
    func muteUserWithuserId(_otherUserUid: String, userUid: String){
        self.ref.child("Users").child(_otherUserUid).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let otherUserData = snapshot.value as! NSDictionary
                let otherUserDataDisplayName = otherUserData["displayName"] as! String
                self.ref.child("Users").child(userUid).child("mutedUsers").child(_otherUserUid).setValue(otherUserDataDisplayName)
                self.ref.child("Users").child(_otherUserUid).child("mutedByUsers").child(userUid).setValue(userUid)
            }
        })
    }
    
    func blockUserWithuserId(_otherUserUid: String, userUid: String){
        self.ref.child("Users").child(_otherUserUid).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let otherUserData = snapshot.value as! NSDictionary
                let otherUserDataDisplayName = otherUserData["displayName"] as! String
                self.ref.child("Users").child(userUid).child("Friends").child(_otherUserUid).removeValue()
                self.ref.child("Users").child(_otherUserUid).child("Friends").child(userUid).removeValue()
                self.ref.child("Users").child(userUid).child("blockedUsers").child(_otherUserUid).setValue(otherUserDataDisplayName)
                self.ref.child("Users").child(_otherUserUid).child("blockedByUsers").child(userUid).setValue(userUid)
            }
        })
    }
    
    func reportUser(_postId: String){
        self.ref.child("Posts").child(_postId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let postData = snapshot.value as! NSDictionary
                let postedUserId = postData["useruid"] as! String
                self.ref.child("Users").child(postedUserId).observeSingleEvent(of: FIRDataEventType.value, with: { (snap) in
                    if(snap.exists()){
                        var reportedCount:Int = 0
                        let reportedUserData = snap.value as! NSDictionary
                        if(reportedUserData["reportedCount"] != nil){
                            reportedCount = reportedUserData["reportedCount"] as! Int
                            reportedCount = reportedCount+1
                            self.ref.child("Users").child(postedUserId).child("reportedCount").setValue(reportedCount)
                            
                        }
                        else {
                            reportedCount = reportedCount+1
                            self.ref.child("Users").child(postedUserId).child("reportedCount").setValue(reportedCount)
                        }
                    }
                })
            }
        })
    }
    
    
    func reportUserWithUserId(_rpreportedUserId: String){
        self.ref.child("Users").child(_rpreportedUserId).observeSingleEvent(of: FIRDataEventType.value, with: { (snap) in
            if(snap.exists()){
                var reportedCount:Int = 0
                let reportedUserData = snap.value as! NSDictionary
                if(reportedUserData["reportedCount"] != nil){
                    reportedCount = reportedUserData["reportedCount"] as! Int
                    reportedCount = reportedCount+1
                    self.ref.child("Users").child(_rpreportedUserId).child("reportedCount").setValue(reportedCount)
                    
                }
                else {
                    reportedCount = reportedCount+1
                    self.ref.child("Users").child(_rpreportedUserId).child("reportedCount").setValue(reportedCount)
                }
            }
        })
    }
    
    func removeAllFriends(_rpreportedUserId: String){
        self.ref.child("Users").child(_rpreportedUserId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if(snapshot.exists()){
                let reportedUserData = snapshot.value as! NSDictionary
                if( reportedUserData["Friends"] != nil){
                    let friendData = reportedUserData["Friends"] as! NSDictionary
                    for friends in friendData{
                        self.ref.child("Users").child(_rpreportedUserId).child("Friends").child(friends.key as! String).removeValue()
                        self.ref.child("Users").child(friends.key as! String).child("Friends").child(_rpreportedUserId).removeValue()
                    }
                }
                
            }
            
        })
        
    }
    
}
