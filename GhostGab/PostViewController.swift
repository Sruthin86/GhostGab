//
//  PostViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView


extension Notification.Name {
    static let reloadposts = Notification.Name("reloadposts")
}

class PostViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var PostText: UITextField!
    
    @IBOutlet weak var PostAsMeView: UIView!
    
    @IBOutlet weak var PostAsGhostView: UIView!
    
    @IBOutlet weak var PostAndGuessView: UIView!
    
    @IBOutlet weak var CancelView: UIView!
    
    @IBOutlet weak var TopViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ButtonViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var PostButtonsView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let KclosedHeight : CGFloat = 244
    
    let KopenHeight :CGFloat = 320
    
    var selectedInxexPath: NSIndexPath?
    
    var selectedInxexPathsArray :[NSIndexPath] = []
    
    var openedPostCellKey : String?
    
    
    @IBOutlet weak var postLabel: UILabel!
    
    var selfPost: Bool =  false
    
    var scrollingOffset: Int = 244
    
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
    
    let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
    
    var mutedUserDict: NSDictionary!
    
    var spinner:loadingAnimation?
    
    var overlayView = UIView()
    
    @IBOutlet weak var postLabelView: UILabel!
    
    @IBOutlet weak var gabsFromfriends: UIButton!
    
    @IBOutlet weak var gabsNearMe: UIButton!
    
    let lightgrey :Color = Color.lightGrey
    
    let grey :Color = Color.grey
    
    let green :Color = Color.green
    
    let white :Color = Color.white
    
    let lighrGreen :Color = Color.lightGreen
    
    var isLocationSelected: Bool = false
    
    var isLocationEnabled : Bool = false
    
    let locationManager = CLLocationManager()
    
    var loaction : CLLocation?
    
    var customization : UICostomization?
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        
        self.spinner?.showOverlayNew(alphaValue: 1)
        
        customization = UICostomization(color: green.getColor(), width: width )
        
        customization?.addBorder(object: self.gabsFromfriends)
        customization?.addBorder(object: self.gabsNearMe)
        if(!isLocationSelected){
            customization?.addBackground(object: self.gabsFromfriends)
            self.gabsFromfriends.tintColor = white.getColor()
        }
        
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let logo = UIImage(named: "Logo.png")
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 39))
        imageView.contentMode = .scaleAspectFit
        imageView = UIImageView(image:logo)
        self.navigationController?.navigationBar.topItem?.titleView = imageView

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostViewController.handlePost))
        postLabelView.addGestureRecognizer(tap)
        
       
        refreshControl.addTarget(self, action: #selector(PostViewController.uiRefreshActionControl), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        getFriends()
         NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableData(_:)), name: .reloadposts, object: nil)
        
        
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled()
        {
            
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined
            {
                isLocationEnabled = true
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            
            print("locationServices disenabled")
        }
        locationManager.startUpdatingLocation()
       
          // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        loaction = locations[0]
    }
    
    func uiRefreshActionControl() {
        self.animateTable()
    }
    
    func handlePost(){
        let storybaord: UIStoryboard = UIStoryboard(name: "Posts", bundle: nil)
        let gabView  = storybaord.instantiateViewController(withIdentifier: "gab_view") as! GabViewController
        
        //trasition from right
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransitionPush)
        self.present(gabView, animated: false, completion: nil)
        
    }
    
    
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.postsArray.keys.count == 0){
            let textColor: Color = Color.lightGrey
            let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:300, width:self.tableView.frame.width, height:self.tableView.frame.height) )
            if(self.isLocationSelected && !self.isLocationEnabled){
                noDataAvailableLabel.numberOfLines = 4
                noDataAvailableLabel.text =  "Sorry , there is No Activity in this location!.\n (Please check if location  is enabled in your settings)"
            }
            else {
              noDataAvailableLabel.text =  "Sorry , there is no activity yet!"
            }
            
            noDataAvailableLabel.textAlignment = .center
            noDataAvailableLabel.textColor =  textColor.getColor()
            noDataAvailableLabel.font = UIFont(name: "Avenir-Next", size:12.0)
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
        postFeedCell.isUsingLocation = isLocationSelected
        postFeedCell.postId = self.postKeys[indexPath.row]
        postFeedCell.postLabel.text  = postFeed["post"] as? String
        postFeedCell.setRepliesText()
        var type : Int = postFeed["postType"] as! Int
        if(self.friendsUidArray.count > 0 ){
            if(isLocationSelected &&  self.friendsUidArray.contains(postFeed["useruid"] as! String) && type == 4) {
               type = 1
            }
        }
        if(postFeed["useruid"] as! String == self.uid as! String && type == 4){
            type = 1
        }
        postFeedCell.setName(type: type, name: postFeed["displayName"] as! String)
        postFeedCell.dateString.text = helperClass.getDifferenceInDates(postDate: (postFeed["date"]as? String)!)
        postFeedCell.setReactionCount(postId: self.postKeys[indexPath.row])
        postFeedCell.setFlagCount(postId: self.postKeys[indexPath.row])
        postFeedCell.configureImage(postFeed["useruid"] as! String, postType: type, userPicUrl: postFeed["userPicUrl"] as! String)
        postFeedCell.reactButton.addTarget(self, action: #selector(self.reactionsActions), for: .touchUpInside)
        postFeedCell.gabBackBtn.tag = indexPath.row
        postFeedCell.gabBackBtn.addTarget(self, action: #selector(self.gabBack), for: .touchUpInside)
        
        let postNameLabelTap = UITapGestureRecognizer(target:self, action:#selector(self.handleNameTap(sender:)))
        postFeedCell.postNameLabel.addGestureRecognizer(postNameLabelTap)
        
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
    
    

    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("inside segue")
        if segue.identifier == "display_comment_segue" {
            let cell = sender as! UITableViewCell
            if let currIndexPath = tableView.indexPath(for: cell) {
              
                var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[currIndexPath.row]]! as! [String : AnyObject]
                postIdToPass =  self.postKeys[currIndexPath.row]
                let commentsView  = segue.destination as! CommentsViewController
                commentsView.postId = postIdToPass
                commentsView.thisPostArray = postFeed
                    
              
            }
            
            
            
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
        self.navigationController?.pushViewController(commentsView, animated: true)
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
       
        self.getFriends()
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
        self.mutedUserDict = [:]
        ref.child("Users").child(uid as! String).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            let snapData =  snapshot.value as! [String:AnyObject]
            if(snapData["mutedUsers"] != nil){
                
                self.mutedUserDict = snapData["mutedUsers"] as! NSDictionary!
            }else{
                self.mutedUserDict = ["noMutedUsers":"noMutedUsers"]
            }
            
            if(snapData["Friends"] != nil){
                for friendsUid in snapData["Friends"] as! NSDictionary{
                    if(!self.friendsUidArray.contains(friendsUid.key as! String )){
                        self.friendsUidArray.insert(friendsUid.key as! String)
                    }

                }
            }
            if(self.isLocationSelected){
                self.getPostsForLocation()
            }
            else {
              self.getPosts()
            }
            // ...
        })
        
    }
    
    
    

    
    
    
    
    func getPosts(){
        
        ref.child("Posts").queryOrdered(byChild: "TS").observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            
            if( !snapshot.exists()){
                self.postsArray.removeAll()
                self.postKeys.removeAll()
                self.tableView.reloadData()
                
            }else {
              
                var pModel = postModel(posts: snapshot, uid: self.uid as! String)
                self.oldPostKeysCount = self.postKeys.count
                
                self.postsArray = pModel.returnPostsForArray(friendsArray:self.friendsUidArray, mutedUsersDict: self.mutedUserDict) as! [String : AnyObject]
               
                self.postKeys = pModel.returnPostKeys()
                self.postKeys = self.postKeys.sorted{ $0 > $1 }
                self.tableView.reloadData()
                let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
                self.tableView.scrollToRow(at: top as IndexPath, at: .top, animated: true)
                self.spinner?.hideOverlayViewNew()
                if( self.oldPostKeysCount == 0) {
                    return
                }
                else if (self.oldPostKeysCount ==  self.postKeys.count){
                    return
                }
                else if (self.oldPostKeysCount < self.postKeys.count){
//                    let diff : Int = (self.postKeys.count - self.oldPostKeysCount)
//                    self.updateScrollPosition(diff: diff)
                    return
                }
                else {
                    return
                }
            }
            
        })
        
        
        
    }
    
    
    func getPostsForLocation() {
        
        if let currentLocation = loaction{
            ref.child("Posts").queryOrdered(byChild: "TS").observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
                
                if( !snapshot.exists()){
                    self.postsArray.removeAll()
                    self.postKeys.removeAll()
                    self.tableView.reloadData()
                    
                }else {
                    var pModel = postModel(posts: snapshot, uid: self.uid as! String)
                    self.oldPostKeysCount = self.postKeys.count
                    self.postsArray = pModel.returnLocationPostsForArray(currentLoaction: currentLocation) as! [String : AnyObject]
                    self.postKeys = pModel.returnPostKeys()
                    self.postKeys = self.postKeys.sorted{ $0 > $1 }
                    self.tableView.reloadData()
                    let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
                    self.tableView.scrollToRow(at: top as IndexPath, at: .top, animated: true)
                    self.spinner?.hideOverlayViewNew()
                    if( self.oldPostKeysCount == 0) {
                        return
                    }
                    else if (self.oldPostKeysCount ==  self.postKeys.count){
                        return
                    }
                    else if (self.oldPostKeysCount < self.postKeys.count){
//                        let diff : Int = (self.postKeys.count - self.oldPostKeysCount)
//                        self.updateScrollPosition(diff: diff)
                        return
                    }
                    else {
                        return
                    }
                }
                
            })
        }
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
        self.getFriends()
    }
    
    
    @IBAction func gabsFromFriends_btn(_ sender: Any) {
        self.isLocationSelected = false
        
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.spinner?.showOverlayNew(alphaValue: 1)
        
        customization = UICostomization(color: green.getColor(), width: width )
        customization?.addBackground(object: self.gabsFromfriends)
        self.gabsFromfriends.tintColor = white.getColor()
        
        customization = UICostomization(color: white.getColor(), width: width )
        customization?.addBackground(object: self.gabsNearMe)
        self.gabsNearMe.tintColor = green.getColor()
        self.getFriends()
    }
    
    @IBAction func gabsNearMe_btn(_ sender: Any) {
        self.isLocationSelected = true
        
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.spinner?.showOverlayNew(alphaValue: 1)
        
        customization = UICostomization(color: green.getColor(), width: width )
        customization?.addBackground(object: self.gabsNearMe)
        self.gabsNearMe.tintColor = white.getColor()
        
        customization = UICostomization(color: white.getColor(), width: width )
        customization?.addBackground(object: self.gabsFromfriends)
        self.gabsFromfriends.tintColor = green.getColor()
        
        self.getFriends()
        
    }
    
    func handleNameTap(sender : UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let currIndexPath = self.tableView.indexPathForRow(at: tapLocation)
        
        var postFeed :[String: AnyObject] = self.postsArray[self.postKeys[currIndexPath!.row]]! as! [String : AnyObject]
        postIdToPass =  self.postKeys[(currIndexPath?.row)!]
        var type : Int = postFeed["postType"] as! Int
        if(self.friendsUidArray.count > 0 ){
            if(isLocationSelected &&  self.friendsUidArray.contains(postFeed["useruid"] as! String) && type == 4) {
                type = 1
            }
        }
        if(postFeed["useruid"] as! String == self.uid as! String && type == 4){
            type = 1
        }
        
        if(type == 1){
            if( postFeed["useruid"] as! String == self.uid as! String ){
                let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                mainTabBarView.selectedIndex = 2
                //trasition from left
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
                self.present(mainTabBarView, animated: false, completion: nil)
            }
            else {
                let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
                let friendDetailsView  = storybaord.instantiateViewController(withIdentifier: "friend_details") as! FriendDetailsViewController
                friendDetailsView.friendUdid = postFeed["useruid"] as! String
                self.navigationController?.pushViewController(friendDetailsView, animated:true)
            }
           
        }
        else if(type == 3 ){
            let storybaord: UIStoryboard = UIStoryboard(name: "Posts", bundle: nil)
            let guessView  = storybaord.instantiateViewController(withIdentifier: "guessController") as! GuessViewController
            guessView.postId = postIdToPass
            guessView.guessPostArray = postFeed
            guessView.oriFrinendsKeyArray = Array(self.friendsUidArray)
            self.navigationController?.pushViewController(guessView, animated:true)
        }
        
        
        
    }
    
    
    
}
