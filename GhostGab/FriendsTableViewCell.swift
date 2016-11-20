//
//  FriendsTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var friendsImageView: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    let green: Color = Color.green
    
    let width: Int = 1
    
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
        let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
        self.friendsImageView.image = UIImage(data: profilePicUrl! as Data)
        self.friendsImageView.layer.cornerRadius  = self.friendsImageView.frame.width/2
        self.friendsImageView.clipsToBounds = true;
        let costomization:UICostomization =  UICostomization(color: green.getColor(), width:1)
        costomization.addRoundedBorder(object: self.friendsImageView)
    }


}
