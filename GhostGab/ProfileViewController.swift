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
import FBSDKShareKit
import Alamofire


extension Notification.Name {
    static let reload = Notification.Name("reload")
}
class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var cashCount: UILabel!
    
    let KclosedHeight : CGFloat = 194
    let KopenHeight :CGFloat = 270
    
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
    
    var overlayView = UIView()
    
    var postIdToPass:String!
    
    var spinner:loadingAnimation?
    
    override func viewDidLoad() {
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.spinner?.showOverlayNew(alphaValue: 1)
        self.getUserDetails()
        self.getPosts()
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func getUserDetails() {
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(self.uid as! String).observe(FIRDataEventType.value, with: { (snapshot) in
            
            let userDetails = snapshot.value as! [String: AnyObject]
            self.fullName.text =  userDetails["displayName"] as? String;
            self.cashCount.text = userDetails["cash"] as? String;
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
        
            Alamofire.request(userDetails["highResPhoto"] as! String).responseData { response in
                if let alamofire_image = response.result.value {
                    let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
                    self.profileImage.image = UIImage(data: profilePicUrl! as Data)
                    self.spinner?.hideOverlayViewNew()
                }
            }
            
            
            self.profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
            self.profileImage.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 5 )
            customization.addBorder(object: self.profileImage)
            NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableData(_:)), name: .reload, object: nil)
            
        })
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
        postFeedCell.gabBackBtn.tag = indexPath.row
        var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[indexPath.row]]! as! [String : AnyObject]
        postFeedCell.postId = self.postKeys[indexPath.row]
        postFeedCell.postLabel.text  = postFeed["post"] as? String
        postFeedCell.dateString.text = helperClass.getDifferenceInDates(postDate: (postFeed["date"]as? String)!)
        postFeedCell.setReactionCount(postId: self.postKeys[indexPath.row])
        postFeedCell.setFlagCount(postId: self.postKeys[indexPath.row])
        postFeedCell.configureImage(postFeed["useruid"] as! String, postType: postFeed["postType"] as! Int, userPicUrl: postFeed["userPicUrl"] as! String  )
        postFeedCell.reactButton.addTarget(self, action: #selector(self.reactionsActions), for: .touchUpInside)
        postFeedCell.gabBackBtn.addTarget(self, action: #selector(self.gabBack), for: .touchUpInside)
       
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
    
    
    func gabBack(sender: AnyObject) {
        var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[sender.tag]]! as! [String : AnyObject]
        postIdToPass =  self.postKeys[sender.tag]
        
        let storybaord: UIStoryboard = UIStoryboard(name: "Posts", bundle: nil)
        let commentsView  = storybaord.instantiateViewController(withIdentifier: "comments_view") as! CommentsViewController
        commentsView.postId = postIdToPass
        commentsView.thisPostArray = postFeed
        //trasition from right
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
        self.present(commentsView, animated: false, completion: nil)
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
            
            if( !snapshot.exists()){
                 self.postsArray.removeAll()
                self.postKeys.removeAll()
                self.tableView.reloadData()
            }else {
                
                var pModel = postModel(posts: snapshot, uid: self.uid as! String)
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
    
    
    func reloadTableData(_ notification: Notification) {
        self.getPosts()
    }
    
   
    @IBAction func shareToFacebook(_ sender: Any) {
        //shareScoreToFB()
    }
    
    
    func shareScoreToFB(){
//        let shareString =  "My ghost gab score is " + self.cashCount.text! + " I challenge you to beat me "
//        var content = FBSDKShareLinkContent()
//        content.contentURL = NSURL(string: "https://www.ghostgab.com")! as URL!
//        content.quote = shareString
//        var dialog = FBSDKShareDialog()
//        dialog.fromViewController = self
//        dialog.shareContent = content
//        dialog.mode = .automatic
//        dialog.show()
    }
    
    
}
