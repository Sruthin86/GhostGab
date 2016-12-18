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
        let currentDateToString = dateformatter.string(from: currentDate as Date)
        return currentDateToString
    }
    
    
    func getDifferenceInDates(postDate:String) ->String  {
        
        
        let currDate = NSDate()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
                })
                uRef.child("Flags").child("flagCount")
            }
            
        })
        
        
        
        
    }
    
}
