//
//  UserModel.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/2/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit

class  UserModel {
    var name:String?
    var userName:String?
    var email:String?
    var photoUrl:String?
    var phoneNumber:String?
    var isVerified:Bool?
    var uid: String?


    
    
    
    
    init  (name: String?, userName:String?, email:String?, photoUrl: String?, phoneNumber:String?,isVerified:Bool, uid: String?) {
        
        self.name = name
        self.userName = userName
        self.email = email
        self.photoUrl = photoUrl
        self.phoneNumber = phoneNumber
        self.isVerified = isVerified
        self.uid = uid
    }
    
  

}
