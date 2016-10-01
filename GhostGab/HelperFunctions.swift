//
//  HelperFunctions.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/28/16.
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
        PostButtonsView.hidden = true
        ButtonViewHeight.constant = 0
        TopViewHeight.constant = 65
        
        
        
    }
    
    func returnCurrentDateinString() -> String {
        let currentDate = NSDate()
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateToString = dateformatter.stringFromDate(currentDate)
        return currentDateToString
    }
    
    
    func getDifferenceInDates(postDate:String) ->String  {
        
        
        let currDate = NSDate()
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedCurrentDate =  dateformatter.stringFromDate(currDate)
        let firstDate = dateformatter.dateFromString(postDate)
        let secondDate = dateformatter.dateFromString(formattedCurrentDate)
        return compareDates(firstDate!, curDate: secondDate!)
        
        
    }
    
    func compareDates (pDate:NSDate , curDate:NSDate) ->String {
        var dateString:String?
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: pDate, toDate: curDate, options: NSCalendarOptions.init(rawValue: 0))
        
        if(diffDateComponents.year != 0){
            dateString = dateformatter.stringFromDate(pDate)
        }
        else if (diffDateComponents.month != 0){
            dateString = dateformatter.stringFromDate(pDate)
        }
            
        else if (diffDateComponents.day != 0){
            dateString = String(diffDateComponents.day) + " days ago"
        }
            
        else if(diffDateComponents.hour != 0 ){
            dateString = String(diffDateComponents.hour) + " hrs ago"
        }
        else if(diffDateComponents.minute != 0){
            dateString = String(diffDateComponents.minute) + " mins ago"
        }
        else if(diffDateComponents.second != 0){
            dateString = String(diffDateComponents.second) + " s ago"
        }
        else {
            dateString = "now"
        }
        return dateString!
    }
    
    
    func updateReactions(postId:String, uid:String,  Reaction:Int, newReaction:Int) {
        
        guard (Reaction == newReaction ) else {
            var reactionsInUser = [String: AnyObject]()
            reactionsInUser["userReaction"] = newReaction
            let postRef =  self.ref.child("Posts").child(postId)
            postRef.observeSingleEventOfType(FIRDataEventType.Value , withBlock:{ (snapshot) in
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
        
        uRef.child("Flag").child(postId).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            if(snapshot.exists()){
                let flagVal =  snapshot.value as! [String:Int]
                let fCount : Int = flagVal["userFlag"]!
                if(fCount == 1 ){
                    flagsInUser["userFlag"] = 0
                    uRef.child("Flag").child(postId).setValue(flagsInUser)
                    pRef.child("flags").observeSingleEventOfType(FIRDataEventType.Value, withBlock:  { (snapshot) in
                        let flags = snapshot.value as! [String: Int]
                        var flagCount: Int = flags["flagCount"]!
                        flagCount -= 1
                        pRef.child("flags").child("flagCount").setValue(flagCount)
                    })
                }
                else if(fCount == 0 ){
                    flagsInUser["userFlag"] = 1
                    uRef.child("Flag").child(postId).setValue(flagsInUser)
                    pRef.child("flags").observeSingleEventOfType(FIRDataEventType.Value, withBlock:  { (snapshot) in
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
                pRef.child("flags").observeSingleEventOfType(FIRDataEventType.Value, withBlock:  { (snapshot) in
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