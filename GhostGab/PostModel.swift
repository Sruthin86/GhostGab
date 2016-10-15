//
//  PostModel.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/16/16.
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
    
    mutating func returnPostsForArray()  -> NSDictionary {
        
        let postData  = posts!.value as! NSDictionary
            let currentuserUid =  self.uid as! String
            for (key , val ) in postData {
                
                let postUid = (val as AnyObject).value(forKey: "useruid")! as! String
                if (postUid == currentuserUid  ){ // entire logic needs to be re written once friends functionality is implemented
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
