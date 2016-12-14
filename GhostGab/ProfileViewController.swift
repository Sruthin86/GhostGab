//
//  ProfileViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var cashCount: UILabel!
    
    let KclosedHeight : CGFloat = 144
    let KopenHeight :CGFloat = 220
    
    var selectedInxexPath: NSIndexPath?
    var selectedInxexPathsArray :[NSIndexPath] = []
    var openedPostCellKey : String?
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    let ref = FIRDatabase.database().reference()
    var postsArray = [String : AnyObject]()
    var postKeys = [String]()
    var oldPostKeysCount : Int = 0
    
    let helperClass : HelperFunctions = HelperFunctions()

    let green : Color = Color.green
    
    var selfPost: Bool =  false
    
    var scrollingOffset: Int = 144
    
    override func viewDidLoad() {
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(self.uid as! String).observe(FIRDataEventType.value, with: { (snapshot) in
            
            let userDetails = snapshot.value as! [String: AnyObject]
            self.fullName.text =  userDetails["displayName"] as? String;
            self.cashCount.text = userDetails["cash"] as? String;
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
            self.profileImage.image = UIImage(data: profilePicUrl! as Data)
            self.profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
            self.profileImage.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 5 )
            customization.addBorder(object: self.profileImage)
            
            
        })
        self.getPosts()
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.postsArray.keys.count == 0){
            let textColor: Color = Color.grey
            let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:300, width:self.tableView.frame.width, height:self.tableView.frame.height) )
            noDataAvailableLabel.text =  "Sorry , there is No Activity yet!"
            noDataAvailableLabel.textAlignment = .center
            noDataAvailableLabel.textColor =  textColor.getColor()
            noDataAvailableLabel.font = UIFont(name: "Avenir-Next", size:14.0)
            self.tableView.backgroundView = noDataAvailableLabel
        }
        else {
            self.tableView.backgroundView = .none
        }
         return self.postsArray.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postFeedCell = tableView.dequeueReusableCell(withIdentifier: "MyFeedCell", for: indexPath as IndexPath) as! MyFeedTableViewCell
        postFeedCell.ReactionsContent.isHidden = true
        postFeedCell.reactButton.tag = indexPath.row
        var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[indexPath.row]]! as! [String : AnyObject]
        postFeedCell.postId = self.postKeys[indexPath.row]
        postFeedCell.postLabel.text  = postFeed["post"] as? String
        postFeedCell.dateString.text = helperClass.getDifferenceInDates(postDate: (postFeed["date"]as? String)!)
        postFeedCell.setReactionCount(postId: self.postKeys[indexPath.row])
        postFeedCell.setFlagCount(postId: self.postKeys[indexPath.row])
        postFeedCell.configureImage(postFeed["useruid"] as! String, postType: postFeed["postType"] as! Int, userPicUrl: postFeed["userPicUrl"] as! String  )
        postFeedCell.reactButton.addTarget(self, action: #selector(self.reactionsActions), for: .touchUpInside)
       
        if  (self.openedPostCellKey != nil ) {
            if (self.postKeys[indexPath.row] ==  self.openedPostCellKey){
                self.selectedInxexPath = indexPath as NSIndexPath?
            }
        }
        guard self.selectedInxexPath != nil else {
            
            return postFeedCell
        }
        if (self.selectedInxexPath! as IndexPath == indexPath){
            if(self.postKeys[indexPath.row] ==  self.openedPostCellKey){
                postFeedCell.openReactionsView()
            }
        }
        else {
            postFeedCell.closeReactionsView()
        }
        
        
        return postFeedCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selIndex = selectedInxexPath?.row {
            if(selIndex == indexPath.row){
                return KopenHeight
            }
            else {
                return KclosedHeight
            }
        }
        else {
            return KclosedHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func reactionsActions(sender: AnyObject) -> Void {
        let selectedCellIndexPath = NSIndexPath(row: sender.tag, section: 0)
        selectedInxexPathsArray.removeAll()
        if (selectedInxexPath != nil) {
            let previousSelectedPath :NSIndexPath = selectedInxexPath!
            selectedInxexPathsArray.append(previousSelectedPath)
        }
        
        
        
        
        guard ((selectedInxexPath) != nil)  else {
            
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! MyFeedTableViewCell
            self.openedPostCellKey =  self.postKeys[(selectedInxexPath?.row)!]
            cell.openReactionsView()
            return
            
        }
        
        if selectedInxexPath!.row != selectedCellIndexPath.row{
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.openedPostCellKey =  self.postKeys[(selectedInxexPath?.row)!]
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            self.tableView.beginUpdates()
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! MyFeedTableViewCell
            cell.openReactionsView()
            self.tableView.endUpdates()
            
        }
        else if (selectedInxexPath!.row == selectedCellIndexPath.row){
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.selectedInxexPath = nil
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! MyFeedTableViewCell
            cell.closeReactionsView()
            self.openedPostCellKey =  nil
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            self.tableView.endUpdates()
            selectedInxexPathsArray.removeAll()
            
            
        }
        
        
        
    }
    
    
    func getPosts(){
        
        ref.child("Posts").queryOrdered(byChild: "TS").observe(FIRDataEventType.value, with: { (snapshot) in
            
            guard !snapshot.exists() else {
                
                var pModel = postModel(posts: snapshot)
                self.oldPostKeysCount = self.postKeys.count
                self.postsArray = pModel.returnMyPostsForArray() as! [String : AnyObject]
                self.postKeys = pModel.returnPostKeys()
                self.postKeys = self.postKeys.sorted{ $0 > $1 }
                self.tableView.reloadData()
                if( self.oldPostKeysCount == 0) {
                    return
                }
                else if (self.oldPostKeysCount ==  self.postKeys.count){
                    return
                }
                else if (self.oldPostKeysCount < self.postKeys.count){
                    let diff : Int = (self.postKeys.count - self.oldPostKeysCount)
                    self.updateScrollPosition(diff: diff)
                    return
                }
                else {
                    return
                }
            }
            
        })
        
        
        
    }
    
    func updateScrollPosition(diff: Int){
        let contentOffset = self.tableView.contentOffset
        if(self.selfPost){
            
            self.scrollingOffset = 0
            self.selfPost = !self.selfPost
            let indexpath = NSIndexPath(row: 0 , section:0)
            self.tableView.scrollToRow(at: indexpath as IndexPath, at: .top, animated:
                true)
            //self.tableView.contentOffset.y = contentOffset.y - (144 *  CGFloat(diff))
            
        }
        else {
            self.scrollingOffset = 144
            self.tableView.contentOffset.y = contentOffset.y + (144 * CGFloat(diff))
        }
        
    }
    
    
}
