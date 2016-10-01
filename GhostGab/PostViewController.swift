//
//  PostViewController.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/14/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

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
    
    let uid = NSUserDefaults.standardUserDefaults().objectForKey(fireBaseUid)
    
    let ref = FIRDatabase.database().reference()
    
    var postsArray = [String : AnyObject]()
    
    var postKeys = [String]()
    
    var oldPostKeysCount : Int = 0
    
    let helperClass : HelperFunctions = HelperFunctions()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lightGrey:Color = Color.lightGrey
        let customization :UICostomization = UICostomization(color:lightGrey.getColor(), width:width)
        customization.addBorder(self.PostAsMeView)
        customization.addBorder(self.PostAsGhostView)
        customization.addBorder(self.PostAndGuessView)
        customization.addBorder(self.CancelView)
        PostText.addTarget(self, action: #selector(PostViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.AllEvents)
        self.PostButtonsView.hidden = true
        self.ButtonViewHeight.constant = 0
        self.TopViewHeight.constant = 65
        refreshControl.addTarget(self, action: #selector(PostViewController.uiRefreshActionControl), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        getPosts()
        
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
            self.PostButtonsView.hidden = false
            self.ButtonViewHeight.constant = 40
            self.TopViewHeight.constant = 105
        }
        
    }
    
    @IBAction func CancelEditing(sender: AnyObject) {
        
        helperClass.returnFromTextField(self.PostText, PostButtonsView: PostButtonsView, ButtonViewHeight: ButtonViewHeight, TopViewHeight: TopViewHeight)
        userIsEditing = !userIsEditing
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.postsArray.keys.count == 0){
            let textColor: Color = Color.grey
            let noDataAvailableLabel: UILabel = UILabel(frame: CGRectMake(0, 300, self.tableView.frame.width, self.tableView.frame.height) )
            noDataAvailableLabel.text =  "Sorry , there is No Activity yet!"
            noDataAvailableLabel.textAlignment = .Center
            noDataAvailableLabel.textColor =  textColor.getColor()
            noDataAvailableLabel.font = UIFont(name: "Avenir-Next", size:14.0)
            self.tableView.backgroundView = noDataAvailableLabel
        }
        else {
            self.tableView.backgroundView = .None
        }
        
        
        
        return self.postsArray.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let postFeedCell = tableView.dequeueReusableCellWithIdentifier("PostViewCell", forIndexPath: indexPath) as! PostCellTableViewCell
        postFeedCell.ReactionsContent.hidden = true
        postFeedCell.reactButton.tag = indexPath.row
        var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[indexPath.row]]! as! [String : AnyObject]
        postFeedCell.postId = self.postKeys[indexPath.row]
        postFeedCell.postLabel.text  = postFeed["post"] as? String
        postFeedCell.dateString.text = helperClass.getDifferenceInDates((postFeed["date"]as? String)!)
        postFeedCell.setReactionCount(self.postKeys[indexPath.row])
        postFeedCell.setFlagCount(self.postKeys[indexPath.row])
        postFeedCell.configureImage(self.postKeys[indexPath.row])
        postFeedCell.reactButton.addTarget(self, action: #selector(self.reactionsActions), forControlEvents: .TouchUpInside)
        if  (self.openedPostCellKey != nil ) {
            if (self.postKeys[indexPath.row] ==  self.openedPostCellKey){
                self.selectedInxexPath = indexPath
            }
        }
        guard self.selectedInxexPath != nil else {
            
            return postFeedCell
        }
        if (self.selectedInxexPath! == indexPath){
            postFeedCell.openReactionsView()
        }
        
        return postFeedCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func reactionsActions(sender: AnyObject) -> Void {
        let selectedCellIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        selectedInxexPathsArray.removeAll()
        if (selectedInxexPath != nil) {
            let previousSelectedPath :NSIndexPath = selectedInxexPath!
            print(previousSelectedPath.row)
            selectedInxexPathsArray.append(previousSelectedPath)
        }
        
        
        
        
        guard ((selectedInxexPath) != nil)  else {
            
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.tableView.reloadRowsAtIndexPaths(selectedInxexPathsArray, withRowAnimation: UITableViewRowAnimation.Fade)
            let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) as! PostCellTableViewCell
            self.openedPostCellKey =  self.postKeys[(selectedInxexPath?.row)!]
            cell.openReactionsView()
            return
            
        }
        
        if selectedInxexPath!.row != selectedCellIndexPath.row{
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.openedPostCellKey =  self.postKeys[(selectedInxexPath?.row)!]
            self.tableView.reloadRowsAtIndexPaths(selectedInxexPathsArray, withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.beginUpdates()
            let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) as! PostCellTableViewCell
            cell.openReactionsView()
            self.tableView.endUpdates()
            
        }
        else if (selectedInxexPath!.row == selectedCellIndexPath.row){
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.selectedInxexPath = nil
            let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) as! PostCellTableViewCell
            cell.closeReactionsView()
            self.openedPostCellKey =  nil
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths(selectedInxexPathsArray, withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.endUpdates()
            selectedInxexPathsArray.removeAll()
            
            
        }
        
        
        
    }
    
    
    func animateTable() {
        self.tableView.reloadData()
        let cells = self.tableView.visibleCells
        
        let tableHeight:CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell :UITableViewCell = i
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
            
        }
        
        let index = 0
        for a in cells {
            let cell :UITableViewCell = a
            UIView.animateWithDuration(1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 1, initialSpringVelocity: 0.5  ,options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion : nil)
        }
        self.refreshControl.endRefreshing()
    }
    
    
    func getPosts(){
        
        ref.child("Posts").queryOrderedByChild("TS").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            guard !snapshot.exists() else {
                
                var pModel = postModel(posts: snapshot)
                self.oldPostKeysCount = self.postKeys.count
                self.postsArray = pModel.returnPostsForArray() as! [String : AnyObject]
                self.postKeys = pModel.returnPostKeys()
                self.postKeys = self.postKeys.sort{ $0 > $1 }
                self.tableView.reloadData()
                if( self.oldPostKeysCount == 0) {
                    print("zero")
                    return
                }
                else if (self.oldPostKeysCount ==  self.postKeys.count){
                    print("Equal")
                    return
                }
                else if (self.oldPostKeysCount < self.postKeys.count){
                    print("diff")
                    let diff : Int = (self.postKeys.count - self.oldPostKeysCount)
                    self.updateScrollPosition(diff)
                    return
                }
                else {
                    print("Notttt")
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
            let indexpath = NSIndexPath(forRow: 0 , inSection:     0)
            self.tableView.scrollToRowAtIndexPath(indexpath, atScrollPosition: .Top, animated:
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
        ref.child("Users").child(uid).observeSingleEventOfType(FIRDataEventType.Value, withBlock :{ (snapshot) in
            let userData =  snapshot.value as! [String:AnyObject]
            let displayName = userData["displayName"]
            let reactionsData: [String:Int] = ["Reaction1": 0, "Reaction2": 0, "Reaction3": 0, "Reaction4": 0, "Reaction5": 0, "Reaction6": 0]
            let flags: [String : Int] = ["flagCount": 0]
            let postMetrics: [String:Int] = ["flag":0, "correctGuess":0, "wrongGuess":0]
            let postData : [String: AnyObject] = ["post":post , "useruid": uid, "displayName":displayName!, "postType":postType,  "reactionsData":reactionsData, "flags":flags, "postMetrics":postMetrics, "TS": [".sv": "timestamp"],"date":currentDateToString]
            
            let postDataRef = self.ref.child("Posts").childByAutoId()
            postDataRef.setValue(postData)
            let postDataId = postDataRef.key
            
            self.ref.child("Users").child(uid).child("posts").child(postDataId).child("posId").setValue(postDataId)
            // ...
        })
        
        
        
        
        
    }
    
    @IBAction func postAsMe(sender: AnyObject) {
        
        post(1)
        
        
    }
    
    
    @IBAction func postAsGhost(sender: AnyObject) {
        post(2)
        
    }
    
    
    @IBAction func postAndGuess(sender: AnyObject) {
        post(3)
        
    }
    
    func post(typeId: Int){
        
        if( !((self.PostText.text?.isEmpty)!) || (self.PostText.text?.characters.count > 200) ){
            self.saveNewPost((self.PostText?.text)!, uid:self.uid as! String, postType: typeId)
            helperClass.returnFromTextField(self.PostText, PostButtonsView: PostButtonsView, ButtonViewHeight: ButtonViewHeight, TopViewHeight: TopViewHeight)
            userIsEditing = !userIsEditing
            self.selfPost = !self.selfPost
            
        }
    }
    
    
}
