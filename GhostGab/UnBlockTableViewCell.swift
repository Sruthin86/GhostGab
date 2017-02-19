//
//  UnBlockTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/12/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire

class UnBlockTableViewCell: UITableViewCell {

    @IBOutlet weak var blockedUserImage: UIImageView!
    
    @IBOutlet weak var BlockedUserName: UILabel!
    
    @IBOutlet weak var unBlockButton: UIButton!
    
    let green: Color = Color.green
    
    let white: Color = Color.white
    
    let lightGreen: Color = Color.lightGreen
    
    let lightRed: Color = Color.lightRed
    
    let width: Int = 1
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImageData (photoUrl: String) -> Void {
        
        let fileUrl = NSURL(string: photoUrl)
        Alamofire.request(photoUrl).responseData { response in
            if let alamofire_image = response.result.value {
                
                self.blockedUserImage.image = UIImage(data: alamofire_image as Data)
                self.blockedUserImage.layer.cornerRadius  = self.blockedUserImage.frame.width/2
                self.blockedUserImage.clipsToBounds = true;
                let costomization:UICostomization =  UICostomization(color: self.green.getColor(), width:1)
                costomization.addRoundedBorder(object: self.blockedUserImage)
            }
        }
        
        
    }

}
