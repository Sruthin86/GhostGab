//
//  postModel.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase

struct postModel {
    
    var posts: FIRDataSnapshot?
    var uid :String
    var postsArray = [String : AnyObject]()
    var postKeys = [String]()
    let ref = FIRDatabase.database().reference()
    var radius = 30
    
    init (posts : FIRDataSnapshot, uid:String){
        self.posts = posts
        self.uid = uid
        
    }
    
    //    func returnPost() -> String{
    //        return self.posts!["post"] as! String
    //
    //    }
    
    mutating func returnPostsForArray(friendsArray:Set<String>,  mutedUsersDict: NSDictionary)  -> NSDictionary {
        
        let postData  = posts!.value as! NSDictionary
        let currentuserUid =  self.uid as! String
        
        for (key , val ) in postData {
            if((val as AnyObject).value(forKey: "useruid") != nil){
                let postUid = (val as AnyObject).value(forKey: "useruid")! as! String
                if ((val as AnyObject).value(forKey: "reportedUsers") != nil){
                    let reportedUserstUidDict = (val as AnyObject).value(forKey: "reportedUsers")! as? NSDictionary
                    
                    if(friendsArray.count > 0){
                        for fUid in friendsArray{
                            let frinedUID :String = fUid
                            if ( (postUid == currentuserUid ||  postUid == frinedUID) && (reportedUserstUidDict?[currentuserUid] == nil)){
                                if(mutedUsersDict != nil){
                                    if(mutedUsersDict[postUid] != nil){
                                        //  skip muted user
                                    }
                                        //  logic to get self and friends posts
                                    else if(!self.postKeys.contains(key as! String)){
                                        self.postsArray[key as! String] = val as AnyObject?
                                        self.postKeys.append(key as! String)
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        
                    }
                    else {
                        if (postUid == currentuserUid  ){ // logic if the user doesn't have any friends
                            self.postsArray[key as! String] = val as AnyObject?
                            self.postKeys.append(key as! String)
                            
                        }
                        
                    }
                }
                else {
                    
                    if(friendsArray.count > 0){
                        for fUid in friendsArray{
                            
                            var frinedUID :String = fUid as! String
                            if ( (postUid == currentuserUid ||  postUid == frinedUID)){ //  logic to get self and friends posts
                                if(mutedUsersDict != nil){
                                    
                                    if(mutedUsersDict[postUid] != nil){
                                        //  skip muted user
                                    }
                                        //  logic to get self and friends posts
                                    else if(!self.postKeys.contains(key as! String)){
                                        self.postsArray[key as! String] = val as AnyObject?
                                        self.postKeys.append(key as! String)
                                    }
                                    
                                }
                                
                                
                            }
                        }
                        
                        
                    }
                    else {
                        
                        if (postUid == currentuserUid  ){ // logic if the user doesn't have any friends
                            
                            self.postsArray[key as! String] = val as AnyObject?
                            self.postKeys.append(key as! String)
                            
                        }
                        
                    }
                    
                    
                }
                
            }
        }
        return postsArray as NSDictionary
        
        
    }
    
    
    mutating func returnMyPostsForArray()  -> NSDictionary {
        
        let postData  = posts!.value as! NSDictionary
        let currentuserUid =  self.uid as! String
        for (key , val ) in postData {
            if((val as AnyObject).value(forKey: "useruid") != nil){
                let postUid = (val as AnyObject).value(forKey: "useruid")! as! String
                
                if (postUid == currentuserUid  ){ // logic if the user doesn't have any friends
                    self.postsArray[key as! String] = val as AnyObject?
                    self.postKeys.append(key as! String)
                    
                }
            }
            
            
            
            
        }
        
        
        
        return postsArray as NSDictionary
        
        
    }
    
    
    mutating func returnFriendsPublicPostsForArray()  -> NSDictionary {
        
        let postData  = posts!.value as! NSDictionary
        let currentuserUid =  self.uid as! String
        for (key , val ) in postData {
            if((val as AnyObject).value(forKey: "useruid") != nil){
                let postUid = (val as AnyObject).value(forKey: "useruid")! as! String
                
                if (postUid == self.uid ){ // logic to get friends public posts
                    let postData = val as! NSDictionary
                    if(postData["postType"] as! Int == 1 || postData["postType"] as! Int == 4){
                        self.postsArray[key as! String] = val as AnyObject?
                        self.postKeys.append(key as! String)
                        print("key")
                        print(key)
                    }
                    
                }
            }
            
            
            
        }
        
        
        
        return postsArray as NSDictionary
        
        
    }
    
    
    mutating func returnLocationPostsForArray(currentLoaction:CLLocation)  -> NSDictionary {
        
        let postData  = posts!.value as! NSDictionary
        let currentuserUid =  self.uid as! String
        for (key , val ) in postData {
            if((val as AnyObject).value(forKey: "useruid") != nil){
                let postUid = (val as AnyObject).value(forKey: "useruid")! as! String
                
                if ((val as AnyObject).value(forKey: "locationData") != nil  ){ // logic to get friends public posts
                    let postData = val as! NSDictionary
                    let locationData = postData["locationData"] as! [String: AnyObject]
                    if(postData["postType"] as! Int == 1 || postData["postType"] as! Int == 2 || postData["postType"] as! Int == 4 ){
                        let locationData = CLLocation(latitude: locationData["la"] as! CLLocationDegrees, longitude: locationData["lx"] as! CLLocationDegrees)
                        
                        let distanceInMeters = locationData.distance(from: currentLoaction)
                        let distanceInMiles = distanceInMeters/1609.344
                        if(distanceInMiles <= 30) {
                            self.postsArray[key as! String] = val as AnyObject?
                            self.postKeys.append(key as! String)
                        }
                        
                        
                        
                    }
                    
                }
            }
            
            
            
        }
        
        
        
        return postsArray as NSDictionary
        
        
    }

    
    func returnPostKeys() -> [String]{
        return self.postKeys
    }
    
    
}
