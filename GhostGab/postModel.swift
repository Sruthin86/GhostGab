//
//  postModel.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//


import Foundation
import UIKit
import Firebase
import FirebaseDatabase

struct postModel {
    
    var posts: FIRDataSnapshot?
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    var postsArray = [String : AnyObject]()
    var postKeys = [String]()
    let ref = FIRDatabase.database().reference()
    
    init (posts : FIRDataSnapshot){
        self.posts = posts
        
    }
    
    //    func returnPost() -> String{
    //        return self.posts!["post"] as! String
    //
    //    }
    
    mutating func returnPostsForArray(friendsArray:Set<String>)  -> NSDictionary {
        
        let postData  = posts!.value as! NSDictionary
        let currentuserUid =  self.uid as! String
        for (key , val ) in postData {
            
            let postUid = (val as AnyObject).value(forKey: "useruid")! as! String
            if(friendsArray.count > 0){
                for fUid in friendsArray{
                    var frinedUID :String = fUid as! String
                    if (postUid == currentuserUid ||  postUid == frinedUID ){ //  logic to get self and friends posts
                        self.postsArray[key as! String] = val as AnyObject?
                        self.postKeys.append(key as! String)
                        
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
        
        
        
        return postsArray as NSDictionary
        
        
    }
    
    
    mutating func returnMyPostsForArray()  -> NSDictionary {
        
        let postData  = posts!.value as! NSDictionary
        let currentuserUid =  self.uid as! String
        for (key , val ) in postData {
            
            let postUid = (val as AnyObject).value(forKey: "useruid")! as! String
            
                if (postUid == currentuserUid  ){ // logic if the user doesn't have any friends
                    self.postsArray[key as! String] = val as AnyObject?
                    self.postKeys.append(key as! String)
                    
                }
                
            
            
            
        }
        
        
        
        return postsArray as NSDictionary
        
        
    }

    
    func returnPostKeys() -> [String]{
        return self.postKeys
    }
    
    
}
