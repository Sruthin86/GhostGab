//
//  FriendPublicPostsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/12/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView


extension Notification.Name {
    static let reloadFriendposts = Notification.Name("reloadFriendposts")
}


class FriendPublicPostsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    let KclosedHeight : CGFloat = 244
    
    let KopenHeight :CGFloat = 320
    
    var selectedInxexPath: NSIndexPath?
    
    var selectedInxexPathsArray :[NSIndexPath] = []
    
    var openedPostCellKey : String?
    
    var friendUdid: String?
    
    var scrollingOffset: Int = 244
    
    var selfPost: Bool =  false
    
    var width:CGFloat = 1
    
    let refreshControl :UIRefreshControl = UIRefreshControl()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let ref = FIRDatabase.database().reference()
    
    var postsArray = [String : AnyObject]()
    
    var postKeys = [String]()
    
    var friendsUidArray = Set<String>()
    
    var postIdToPass:String!
    
    var oldPostKeysCount : Int = 0
    
    @IBOutlet weak var tableview: UITableView!
    
    let helperClass : HelperFunctions = HelperFunctions()
    
    let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
    @IBOutlet weak var tableView: UITableView!
    
    var mutedUserDict: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mutedUserDict = ["noMutedUsers":"noMutedUsers"]
        let lightGrey:Color = Color.lightGrey
        let customization :UICostomization = UICostomization(color:lightGrey.getColor(), width:width)
       
     
        refreshControl.addTarget(self, action: #selector(PostViewController.uiRefreshActionControl), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        getPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableData(_:)), name: .reloadFriendposts, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uiRefreshActionControl() {
        self.animateTable()
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
        let postFeedCell = tableView.dequeueReusableCell(withIdentifier: "FriendPublicPostViewCell", for: indexPath) as! FriendPublicPostsTableViewCell
        postFeedCell.ReactionsContent.isHidden = true
        postFeedCell.reactButton.tag = indexPath.row
        postFeedCell.gabBack.tag = indexPath.row
        var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[indexPath.row]]! as! [String : AnyObject]
        postFeedCell.postId = self.postKeys[indexPath.row]
        postFeedCell.postLabel.text  = postFeed["post"] as? String
        postFeedCell.setRepliesText()
        postFeedCell.setName(type: postFeed["postType"] as! Int, name: postFeed["displayName"] as! String)
        postFeedCell.dateString.text = helperClass.getDifferenceInDates(postDate: (postFeed["date"]as? String)!)
        postFeedCell.setReactionCount(postId: self.postKeys[indexPath.row])
        postFeedCell.setFlagCount(postId: self.postKeys[indexPath.row])
        postFeedCell.configureImage(postFeed["useruid"] as! String, postType: postFeed["postType"] as! Int, userPicUrl: postFeed["userPicUrl"] as! String)
        postFeedCell.reactButton.addTarget(self, action: #selector(self.reactionsActions), for: .touchUpInside)
        postFeedCell.gabBack.addTarget(self, action: #selector(self.gabBack), for: .touchUpInside)
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
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! FriendPublicPostsTableViewCell
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
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! FriendPublicPostsTableViewCell
            cell.openReactionsView()
            self.tableView.endUpdates()
            
        }
        else if (selectedInxexPath!.row == selectedCellIndexPath.row){
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.selectedInxexPath = nil
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! FriendPublicPostsTableViewCell
            cell.closeReactionsView()
            self.openedPostCellKey =  nil
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            self.tableView.endUpdates()
            selectedInxexPathsArray.removeAll()
            
            
        }
        
        
        
    }
    
    
    func animateTable() {
        getPosts()
        self.tableView.reloadData()
        let cells = self.tableView.visibleCells
        
        let tableHeight:CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell :UITableViewCell = i
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            
        }
        
        let index = 0
        for a in cells {
            let cell :UITableViewCell = a
            UIView.animate(withDuration: 1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 1, initialSpringVelocity: 0.5  ,options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion : nil)
        }
        self.refreshControl.endRefreshing()
    }
    
    
    
    
    
    
    
    
    
    
    
    func getPosts(){
        
        ref.child("Posts").queryOrdered(byChild: "TS").observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            
            if( !snapshot.exists()){
                self.postsArray.removeAll()
                self.postKeys.removeAll()
                self.tableView.reloadData()
                
            }else {
                
                var pModel = postModel(posts: snapshot, uid: self.friendUdid!)
                self.oldPostKeysCount = self.postKeys.count
                self.postsArray = pModel.returnFriendsPublicPostsForArray() as! [String : AnyObject]
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
            self.scrollingOffset = 244
            self.tableView.contentOffset.y = contentOffset.y + (144 * CGFloat(diff))
        }
        
    }
    
    
        
        
        
        
        
    
    
    
    
    
    func reloadTableData(_ notification: Notification) {
        self.getPosts()
    }
    
    
    @IBAction func back_btn(_ sender: Any) {
        let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
        let friendDetailsView  = storybaord.instantiateViewController(withIdentifier: "friend_details") as! FriendDetailsViewController
        friendDetailsView.friendUdid = self.friendUdid
        //trasition from right
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransitionPush)
        self.present(friendDetailsView, animated: false, completion: nil)

        
    }
    
    @IBAction func all_posts(_ sender: Any) {
        
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 0
        //trasition from left
        let transition = CATransition()
        transition.duration = 0.28
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
        self.present(mainTabBarView, animated: false, completion: nil)
    }
    
}
