//
//  R_STableViewCell.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 9/10/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit

class R_STableViewCell: UITableViewCell {

    @IBOutlet weak var r_s_imageView: UIImageView!
    
    @IBOutlet weak var r_s_label: UILabel!
    
    let green: Color = Color.green
    
    let width: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImageData (photoUrl: String) -> Void {
        let fileUrl = NSURL(string: photoUrl)
        let profilePicUrl = NSData(contentsOfURL:  fileUrl!)
        self.r_s_imageView.image = UIImage(data: profilePicUrl!)
        self.r_s_imageView.layer.cornerRadius  = self.r_s_imageView.frame.width/2
        self.r_s_imageView.clipsToBounds = true;
        let costomization:UICostomization =  UICostomization(color: green.getColor(), width:1)
        costomization.addRoundedBorder(self.r_s_imageView)
    }
    
    
   

}
