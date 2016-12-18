//
//  PostViewController.swift
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


extension Notification.Name {
    static let reloadposts = Notification.Name("reloadposts")
}

class PostViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var PostText: UITextField!
    
    @IBOutlet weak var PostAsMeView: UIView!
    
    @IBOutlet weak var PostAsGhostView: UIView!
    
    @IBOutlet weak var PostAndGuessView: UIView!
    
    @IBOutlet weak var CancelView: UIView!
    
    @IBOutlet weak var TopViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ButtonViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var PostButtonsView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let KclosedHeight : CGFloat = 144
    
    let KopenHeight :CGFloat = 220
    
    var selectedInxexPath: NSIndexPath?
    
    var selectedInxexPathsArray :[NSIndexPath] = []
    
    var openedPostCellKey : String?
    
    
    @IBOutlet weak var postLabel: UILabel!
    
    var selfPost: Bool =  false
    
    var scrollingOffset: Int = 144
    
    var userIsEditing:Bool = false
    
    var width:CGFloat = 1
    
    let refreshControl :UIRefreshControl = UIRefreshControl()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let ref = FIRDatabase.database().reference()
    
    var postsArray = [String : AnyObject]()
    
    var postKeys = [String]()
    
    var friendsUidArray = Set<String>()
    
    var oldPostKeysCount : Int = 0
    
    var postIdToPass:String!
    
    let helperClass : HelperFunctions = HelperFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lightGrey:Color = Color.lightGrey
        let customization :UICostomization = UICostomization(color:lightGrey.getColor(), width:width)
        customization.addBorder(object: self.PostAsMeView)
        customization.addBorder(object: self.PostAsGhostView)
        customization.addBorder(object: self.PostAndGuessView)
        customization.addBorder(object: self.CancelView)
        PostText.addTarget(self, action: #selector(PostViewController.textFieldDidChange(textField:)), for: UIControlEvents.allEvents)
        self.PostButtonsView.isHidden = true
        self.ButtonViewHeight.constant = 0
        self.TopViewHeight.constant = 65
        refreshControl.addTarget(self, action: #selector(PostViewController.uiRefreshActionControl), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        getFriends()
         NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableData(_:)), name: .reloadposts, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uiRefreshActionControl() {
        self.animateTable()
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(!userIsEditing){
            userIsEditing = !userIsEditing
            self.PostButtonsView.isHidden = false
            self.ButtonViewHeight.constant = 40
            self.TopViewHeight.constant = 105
        }
        
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        helperClass.returnFromTextField(textField: self.PostText, PostButtonsView: PostButtonsView, ButtonViewHeight: ButtonViewHeight, TopViewHeight: TopViewHeight)
        userIsEditing = !userIsEditing

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
        let postFeedCell = tableView.dequeueReusableCell(withIdentifier: "PostViewCell", for: indexPath) as! PostCellTableViewCell
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
        let currIndexPath = tableView.indexPathForSelectedRow!
        var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[currIndexPath.row]]! as! [String : AnyObject]
        postIdToPass =  self.postKeys[currIndexPath.row]


        if(postFeed["postType"] as! Int == 3){
            let storybaord: UIStoryboard = UIStoryboard(name: "Posts", bundle: nil)
            let guessView  = storybaord.instantiateViewController(withIdentifier: "guessController") as! GuessViewController
            guessView.postId = postIdToPass
            guessView.guessPostArray = postFeed
            guessView.oriFrinendsKeyArray = Array(self.friendsUidArray)
            self.present(guessView, animated: true, completion: nil)

        }
        
        if(postFeed["postType"] as! Int == 1){
            let storybaord: UIStoryboard = UIStoryboard(name: "Posts", bundle: nil)
            let friendPostView  = storybaord.instantiateViewController(withIdentifier: "friendPostController") as! FriendPostViewController
            friendPostView.postId = postIdToPass
            friendPostView.friendPostArray = postFeed
             self.present(friendPostView, animated: true, completion: nil)
            
        }
        
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
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! PostCellTableViewCell
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
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! PostCellTableViewCell
            cell.openReactionsView()
            self.tableView.endUpdates()
            
        }
        else if (selectedInxexPath!.row == selectedCellIndexPath.row){
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.selectedInxexPath = nil
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! PostCellTableViewCell
            cell.closeReactionsView()
            self.openedPostCellKey =  nil
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            self.tableView.endUpdates()
            selectedInxexPathsArray.removeAll()
            
            
        }
        
        
        
    }
    
    
    func animateTable() {
        getFriends()
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
    
    
    
    func getFriends() {
        self.friendsUidArray.removeAll()
        ref.child("Users").child(uid as! String).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            let snapData =  snapshot.value as! [String:AnyObject]
            if(snapData["Friends"] != nil){
                for friendsUid in snapData["Friends"] as! NSDictionary{
                    if(!self.friendsUidArray.contains(friendsUid.key as! String )){
                        self.friendsUidArray.insert(friendsUid.key as! String)
                    }

                }
            }
            self.getPosts()
            // ...
        })
        
    }
    
    
    

    
    
    
    
    func getPosts(){
        
        ref.child("Posts").queryOrdered(byChild: "TS").observe(FIRDataEventType.value, with: { (snapshot) in
            
            if( !snapshot.exists()){
                self.postsArray.removeAll()
                self.postKeys.removeAll()
                self.tableView.reloadData()
                
            }else {
                
                var pModel = postModel(posts: snapshot)
                self.oldPostKeysCount = self.postKeys.count
                self.postsArray = pModel.returnPostsForArray(friendsArray:self.friendsUidArray) as! [String : AnyObject]
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
    
    func saveNewPost(post:String, uid: String, postType: Int) {
        
        let currentDateToString: String = helperClass.returnCurrentDateinString()
        ref.child("Users").child(uid).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            let userData =  snapshot.value as! [String:AnyObject]
            let displayName = userData["displayName"]
            let picUrl = userData["photo"]
            let reactionsData: [String:Int] = ["Reaction1": 0, "Reaction2": 0, "Reaction3": 0, "Reaction4": 0, "Reaction5": 0, "Reaction6": 0]
            let flags: [String : Int] = ["flagCount": 0]
            let postMetrics: [String:Int] = ["flag":0, "correctGuess":0, "wrongGuess":0]
            let postData : [String: AnyObject] = ["post":post as AnyObject , "useruid": uid as AnyObject, "displayName":displayName!, "userPicUrl" : picUrl!, "postType":postType as AnyObject,  "reactionsData":reactionsData as AnyObject, "flags":flags as AnyObject, "postMetrics":postMetrics as AnyObject,"date":currentDateToString as AnyObject]
            
            let postDataRef = self.ref.child("Posts").childByAutoId()
            postDataRef.setValue(postData)
            let postDataId = postDataRef.key
            
            self.ref.child("Users").child(uid).child("posts").child(postDataId).child("posId").setValue(postDataId)
            // ...
        })
        
        
        
        
        
    }
    
    @IBAction func postAsMe(_ sender: AnyObject) {
        
        post(typeId: 1)
        
        
    }
    
    
    @IBAction func postAsGhost(_ sender: AnyObject) {
        post(typeId: 2)
        
    }
    
    
    @IBAction func postAndGuess(_ sender: AnyObject) {
        post(typeId: 3)
        
    }
    
    func post(typeId: Int){
        
        if( !((self.PostText.text?.isEmpty)!) || ((self.PostText.text?.characters.count)! > 200) ){
            self.saveNewPost(post: (self.PostText?.text)!, uid:self.uid as! String, postType: typeId)
            helperClass.returnFromTextField(textField: self.PostText, PostButtonsView: PostButtonsView, ButtonViewHeight: ButtonViewHeight, TopViewHeight: TopViewHeight)
            userIsEditing = !userIsEditing
            self.selfPost = !self.selfPost
            
        }
    }
    
    func reloadTableData(_ notification: Notification) {
        self.getFriends()
    }
    
}
