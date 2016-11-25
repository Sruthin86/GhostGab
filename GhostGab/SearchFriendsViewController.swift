//
//  SearchFriendsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/24/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import OneSignal


class SearchFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    let currentUser =  UserDefaults.standard.object(forKey: displayName) as! String

    let ref = FIRDatabase.database().reference()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    var searchArray = [String: AnyObject]()
    
    var searchKeyArray = [String]()
    
    var friendsUidArray = Set<String>()
    
    var sentRequestsUidArray = Set<String>()
    
    var searchActive : Bool = false
    
    var imageName = "loading_00001.png"
    
    var labelText = "Search using any User's by ph#"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.getFriends()
        self.getSentRequests()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(SearchFriendsViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        // Do any additional setup after loading the view.
    }
    func didTapView(){
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let searchLength : Int = searchArray.count{
            if (searchLength > 0){
                self.tableView.backgroundView = .none
                self.tableView.separatorStyle = .singleLine
                return searchLength
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
        let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:-200, width:self.tableView.frame.width, height:self.tableView.frame.height) )
        noDataAvailableLabel.text = labelText
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
        let searchUserCell: SearchUsersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "searchUsers", for: indexPath) as! SearchUsersTableViewCell
        searchUserCell.setImageData(photoUrl: self.searchArray[self.searchKeyArray[indexPath.row]]!.value(forKey :"photo")! as! String)
        searchUserCell.displayName.text = self.searchArray[self.searchKeyArray[indexPath.row]]!.value(forKey :"displayName")! as? String
        if(self.friendsUidArray.contains(self.searchKeyArray[indexPath.row]) || self.sentRequestsUidArray.contains(self.searchKeyArray[indexPath.row])){
            searchUserCell.addFriend.isEnabled = false
        }
        else {
            searchUserCell.addFriend.tag = indexPath.row
            searchUserCell.addFriend.addTarget(self, action: #selector(self.addFriend), for: .touchUpInside)
        }
        searchUserCell.setBackground(colorValue: "white")

        
        return searchUserCell
    }
    
    
    func addFriend(sender: AnyObject){
        let addIndexPath = NSIndexPath(row: sender.tag, section: 0)
        let highLightedCell : SearchUsersTableViewCell = self.tableView.cellForRow(at: addIndexPath as IndexPath) as! SearchUsersTableViewCell
        highLightedCell.setBackground(colorValue: "lightGreen")
        let friendUid = self.searchKeyArray[addIndexPath.row]
        let friendOneSignalId = self.searchArray[self.searchKeyArray[addIndexPath.row]]!.value(forKey :"oneSignalId")
        let friendDisplayName = self.searchArray[self.searchKeyArray[addIndexPath.row]]!.value(forKey :"displayName")

        let timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            self.ref.child("Users").child(self.currentUserId).child("RequestsSent").child(friendUid).setValue(friendDisplayName)
            self.ref.child("Users").child(friendUid).child("Requests").child(self.currentUserId).setValue(self.currentUser)
            let notificationText: String = self.currentUser + " sent you a friend request"
            OneSignal.postNotification(["contents": ["en": notificationText], "include_player_ids": [friendOneSignalId]])
            self.getSentRequests()
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
   
    @IBAction func Back(_ sender: Any) {
     
            
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 3
        self.present(mainTabBarView, animated: true, completion: nil)
       

    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func getFriends() {
        ref.child("Users").child(uid as! String).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            let snapData =  snapshot.value as! [String:AnyObject]
            if(snapData["Friends"] != nil){
                for friendsUid in snapData["Friends"] as! NSDictionary{
                    if(!self.friendsUidArray.contains(friendsUid.key as! String )){
                        self.friendsUidArray.insert(friendsUid.key as! String)
                    }
                    
                }
            }
            // ...
        })
        
    }
    
    func getSentRequests() {
        ref.child("Users").child(uid as! String).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            let snapData =  snapshot.value as! [String:AnyObject]
            if(snapData["RequestsSent"] != nil){
                for sentreqUid in snapData["RequestsSent"] as! NSDictionary{
                    if(!self.sentRequestsUidArray.contains(sentreqUid.key as! String )){
                        self.sentRequestsUidArray.insert(sentreqUid.key as! String)
                    }
                    
                }
            }
            // ...
        })
        
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        
        if(searchText.characters.count < 10){
            labelText = "Enter 10 numeric digits"
            self.searchArray.removeAll()
            self.searchKeyArray.removeAll()
            self.tableView.reloadData()
        }
        else if (searchText.characters.count == 10) {
            
            var searchPhNum: String  = String(format: "(%@) %@-%@",
                                searchText.substring(with: searchText.startIndex ..< searchText.index(searchText.startIndex, offsetBy: 3)),
                                searchText.substring(with: searchText.index(searchText.startIndex, offsetBy: 3) ..< searchText.index(searchText.startIndex, offsetBy: 6)),
                                searchText.substring(with: searchText.index(searchText.startIndex, offsetBy: 6) ..< searchText.index(searchText.startIndex, offsetBy: 10)))
            
            
            ref.child("Users").queryOrdered(byChild: "phoneNumber").queryEqual(toValue: searchPhNum).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                print(snapshot.value)
                if(snapshot.exists()){
                    let searchData = snapshot.value as! NSDictionary
                    print("searchData")
                    print(searchData)
                    for sData in searchData{
                        self.searchKeyArray.append(sData.key as! String)
                        self.searchArray[sData.key as! String] = sData.value as AnyObject?
                    }
                    self.tableView.reloadData()
                }
                else {
                    self.imageName = "loading_00003.png"
                    self.labelText = "Sorry , May be the user doesn't exist"
                    self.searchArray.removeAll()
                    self.searchKeyArray.removeAll()
                    self.tableView.reloadData()
                }
            })
        }
        
        else {
            self.imageName = "loading_00003.png"
            self.labelText = "Enter only 10 numeric digits"
            self.searchArray.removeAll()
            self.searchKeyArray.removeAll()
            self.tableView.reloadData()
        }
    }
}
