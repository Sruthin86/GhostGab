//
//  FriendsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//
import UIKit
import Firebase
import FirebaseDatabase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var friendsArray = [String: AnyObject]()
    
    var friendsArrayKey = [String]()
    
    var freindsSearchArray = [String: AnyObject]()
    
    var friendsSearchKeyArray = [String]()
    
    var searching: Bool = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    let ref = FIRDatabase.database().reference()
    
    var spinner:loadingAnimation?
    
     var overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.spinner?.showOverlayNew(alphaValue: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor.white
        getFriends()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var imageName = "Reaction1_lg.png"
        var labelText = "you will find your friends soon!!! "
        
        if(searching){
            if let friendsLength : Int = self.freindsSearchArray.count{
                if (friendsLength > 0){
                    self.tableView.backgroundView = .none
                    self.tableView.separatorStyle = .singleLine
                    return friendsLength
                }
                else {
                    imageName = "Reaction3_lg.png"
                    labelText = "No Results Found!!! "
                    displyNoDataLabel(imageName:imageName, labelText:labelText)
                    return 0
                    
                }
            }
                
            else {
                
                displyNoDataLabel(imageName:imageName, labelText:labelText)
                return 0
                
            }
            
        }
        else {
            if let friendsLength : Int = friendsArray.count{
                if (friendsLength > 0){
                    self.tableView.backgroundView = .none
                    self.tableView.separatorStyle = .singleLine
                    return friendsLength
                }
                else {
                    displyNoDataLabel(imageName:imageName, labelText:labelText)
                    return 0
                    
                }
            }
                
            else {
                
                displyNoDataLabel(imageName:imageName, labelText:labelText)
                return 0
                
            }
        }
        
        
    }
    
    func displyNoDataLabel(imageName: String, labelText: String) -> Void {
        
        let image : UIImage = UIImage(named: imageName)!
        let imageView :UIImageView = UIImageView(image: image)
        imageView.frame = CGRect(x:self.tableView.frame.width/2 - 37.5, y:self.tableView.frame.height/3, width:75, height:99)
        let textColor: Color = Color.grey
        let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:self.tableView.frame.height/8, width:self.tableView.frame.width, height:self.tableView.frame.height) )
        
        noDataAvailableLabel.text =  labelText
        noDataAvailableLabel.textAlignment = .center
        noDataAvailableLabel.textColor =  textColor.getColor()
        noDataAvailableLabel.font = UIFont(name: "Avenir-Next", size:14.0)
        self.tableView.separatorStyle = .none
        var noFriendsView : UIView = UIView( frame: CGRect(x:0, y:300, width:self.tableView.frame.width, height:self.tableView.frame.height))
        noFriendsView.addSubview(imageView)
        noFriendsView.addSubview(noDataAvailableLabel)
        self.tableView.backgroundView = noFriendsView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendsCell :FriendsTableViewCell =  tableView.dequeueReusableCell(withIdentifier: "FriendsCell") as! FriendsTableViewCell
        
        if(searching){
            friendsCell.setImageData(photoUrl: self.freindsSearchArray[self.friendsSearchKeyArray[indexPath.row]]!.value(forKey :"highResPhoto")! as! String)
            friendsCell.displayName.text = self.freindsSearchArray[self.friendsSearchKeyArray[indexPath.row]]!.value(forKey :"displayName")! as? String
            
            friendsCell.removeFriend.tag = indexPath.row
            friendsCell.removeFriend.addTarget(self, action: #selector(self.removeFriend), for: .touchUpInside)
            friendsCell.setBackground(colorValue: "white")
            
        }
        else {
            friendsCell.setImageData(photoUrl: self.friendsArray[self.friendsArrayKey[indexPath.row]]!.value(forKey :"highResPhoto")! as! String)
            friendsCell.displayName.text = self.friendsArray[self.friendsArrayKey[indexPath.row]]!.value(forKey :"displayName")! as? String
                       
            friendsCell.removeFriend.tag = indexPath.row
            friendsCell.removeFriend.addTarget(self, action: #selector(self.removeFriend), for: .touchUpInside)
            friendsCell.setBackground(colorValue: "white")
        }
        return friendsCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var friendUdidToPass:String?
        if(searching){
            let currIndexPath = tableView.indexPathForSelectedRow!
            friendUdidToPass =  self.friendsSearchKeyArray[currIndexPath.row]
        }
        else {
            let currIndexPath = tableView.indexPathForSelectedRow!
            friendUdidToPass =  self.friendsArrayKey[currIndexPath.row]
        }
        var overlayView = UIView()
        var spinner:loadingAnimation = loadingAnimation(overlayView: overlayView, senderView: self.view)
        spinner.showOverlayNew(alphaValue: 0.5)
        let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
        let friendDetailsView  = storybaord.instantiateViewController(withIdentifier: "friend_details") as! FriendDetailsViewController
        friendDetailsView.friendUdid = friendUdidToPass
        //trasition from right
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransitionPush)
        self.present(friendDetailsView, animated: false, completion: nil)
        spinner.hideOverlayViewNew()
        
        
        
    }
    
    
    
    func removeFriend(sender: AnyObject){
        let removeIndexPath = NSIndexPath(row: sender.tag, section: 0)
        let highLightedCell : FriendsTableViewCell = self.tableView.cellForRow(at: removeIndexPath as IndexPath) as! FriendsTableViewCell
        highLightedCell.setBackground(colorValue: "lightRed")
        let friendUid = self.friendsArrayKey[removeIndexPath.row]
        let timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            self.ref.child("Users").child(self.currentUserId).child("Friends").child(friendUid).removeValue()
            self.ref.child("Users").child(friendUid).child("Friends").child(self.currentUserId).removeValue()
        }
        
    }
    
    func getFriends() -> Void {
        
        ref.child("Users").child(currentUserId).child("Friends").observe(FIRDataEventType.value, with: {(snapshot) in
            
            if (!snapshot.exists()){
                self.friendsArray.removeAll()
                self.friendsArrayKey.removeAll()
                self.tableView.reloadData()
            }
            else {
                self.friendsArray.removeAll()
                self.friendsArrayKey.removeAll()
                let friendData = snapshot.value as! [String:String] as [String : AnyObject]
                for (key,value) in friendData {
                    
                    self.ref.child("Users").child(key).observeSingleEvent(of: .value, with: { snapshot in
                        if(snapshot.childrenCount > 0 ){
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                            self.friendsArrayKey.append(key as! String)
                            self.friendsArray[key as! String] = data as AnyObject?
                            self.tableView.reloadData()
                             self.spinner?.hideOverlayViewNew()
                        }
                            
                        else {
                            
                            
                        }
                    })
                    
                    
                }
                
            }
            
        })
    }
    
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searching = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searching = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false;
        self.searchBar.endEditing(true)
        self.freindsSearchArray.removeAll()
        self.friendsSearchKeyArray.removeAll()
        self.searchBar.text = nil
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searching = false;
        self.searchBar.endEditing(true)
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.freindsSearchArray.removeAll()
        self.friendsSearchKeyArray.removeAll()
        searching = true;
        searchFriends(searchString:searchText)
        
    }
    
    func searchFriends(searchString:String) {
        
        if(searchString.characters.count>0){
            if(self.friendsArray.count>0){
                
                for (key,val) in self.friendsArray {
                    var compareString:String  = val["displayName"] as!String
                    if(compareString.lowercased().contains(searchString.lowercased())){
                        self.freindsSearchArray[key as! String] = val as AnyObject?
                        self.friendsSearchKeyArray.append(key as! String)
                    }
                    
                }
                
                if (freindsSearchArray.count>0){
                    searching = true
                    
                }
                tableView.reloadData()
                
            }
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
}
