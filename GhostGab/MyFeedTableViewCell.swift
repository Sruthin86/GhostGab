//
//  MyFeedTableViewCell.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/11/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation

class MyFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var FeedView: UIView!
    @IBOutlet weak var reactButton: UIButton!
    @IBOutlet weak var reactionsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ReactionsContent: UIView!
    @IBOutlet weak var ReactionsView: UIView!
    var cellSelected: Bool = false
    var width:CGFloat = 0.4
    override func awakeFromNib() {
        let verylightGrey : Color = Color.verylightGrey
        let customization: UICostomization = UICostomization (color: verylightGrey.getColor(), width:width)
        customization.addBackground(self)
        customization.addBorder(ReactionsView)
        customization.addBorder(FeedView)
        super.awakeFromNib()
        reactionsViewHeight.constant = 0
        self.ReactionsContent.hidden = true
        self.ReactionsView.hidden = true
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func openReactionsView(){
        
        reactionsViewHeight.constant = 76
        self.ReactionsContent.hidden = false
        self.ReactionsView.hidden = false
        
    }
    func closeReactionsView(){
        reactionsViewHeight.constant = 0
        self.ReactionsContent.hidden = true
        self.ReactionsView.hidden = true
        
    }
    
    
}
