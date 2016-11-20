//
//  RequestsSuggestionsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Firebase
import FirebaseDatabase
import OneSignal

class RequestsSuggestionsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchUserbtn: UIButton!
    
    @IBOutlet weak var requestsBtn: UIButton!
    
    @IBOutlet weak var suggestionsBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var contactStore = CNContactStore()
    
    var width:CGFloat = 1
    
    var phNumbersForSuggestions = [String]()
    
    var suggestionsArray = [String: AnyObject]()
    var suggestionsArrayKey = [String]()
    var requestsArrayKey = [String]()
    var requestsArray = [String: AnyObject]()
    
    let ref = FIRDatabase.database().reference()
    
    var suggestionsFlag:Bool =  false
    
    var requestsFlag:Bool =  false
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    let currentUser =  UserDefaults.standard.object(forKey: displayName) as! String
    
    let lightgrey :Color = Color.lightGrey
    
     let grey :Color = Color.grey
    
    let green :Color = Color.green
    
    let white :Color = Color.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customization : UICostomization = UICostomization(color: lightgrey.getColor(), width: width )
        customization.addBorder(object: self.searchUserbtn)
        customization.addBorder(object: self.requestsBtn)
        customization.addBorder(object: self.suggestionsBtn)
        requestsBtn.sendActions(for: .allTouchEvents)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.suggestionsFlag){
            let imageName = "loading_00001.png"
            let labelText = "Sorry , we couldn't find any one that you might know!!!"
            if let suggestionsLength : Int = suggestionsArray.count{
                if (suggestionsLength > 0){
                    self.tableView.backgroundView = .none
                    self.tableView.separatorStyle = .singleLine
                    return suggestionsLength
                }
                else {
                    displyNoDataLabel(imageName:imageName, labelText:labelText)
                    return 0
                }
            }
            else{
                displyNoDataLabel(imageName:imageName, labelText:labelText)
                return 0
                
            }
        }
            
        else if (self.requestsFlag){
            let imageName = "loading_00002.png"
            let labelText = "somebody will show you some love soon!!!"
            if let requestsLength : Int = requestsArray.count{
                
                if (requestsLength > 0){
                    self.tableView.backgroundView = .none
                    self.tableView.separatorStyle = .singleLine
                    return requestsLength
                }
                else {
                   
                    displyNoDataLabel(imageName:imageName, labelText:labelText)
                    return 0
                }
            }
            else{
                displyNoDataLabel(imageName:imageName, labelText:labelText)
                return 0

            }
        }
        else {
            return 10
        }
    }
    
    func displyNoDataLabel(imageName: String, labelText: String) -> Void {
        
        
        let image : UIImage = UIImage(named: imageName)!
        let imageView :UIImageView = UIImageView(image: image)
        imageView.frame = CGRect(x:self.tableView.frame.width/2 - 37.5, y:self.tableView.frame.height/3, width:75, height:99)
        let textColor: Color = Color.grey
        let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:self.tableView.frame.height/4, width:self.tableView.frame.width, height:self.tableView.frame.height) )
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
        
        let cell: RequestSuggestionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "rsCell", for: indexPath) as! RequestSuggestionTableViewCell
        
        
        if (self.suggestionsFlag){
            
            cell.setImageData(photoUrl: self.suggestionsArray[self.suggestionsArrayKey[indexPath.row]]!.value(forKey :"photo")! as! String)
            cell.rsLabel.text = self.suggestionsArray[self.suggestionsArrayKey[indexPath.row]]!.value(forKey :"displayName")! as? String
            cell.sendRequestBtn.tag = indexPath.row
            cell.sendRequestBtn.addTarget(self, action: #selector(self.AcceptButton), for: .touchUpInside)
        }
        else if (self.requestsFlag){
            
            cell.setImageData(photoUrl: self.requestsArray[self.requestsArrayKey[indexPath.row]]!.value(forKey :"photo")! as! String)
            cell.rsLabel.text = self.requestsArray[self.requestsArrayKey[indexPath.row]]!.value(forKey :"displayName")! as? String
            cell.sendRequestBtn.tag = indexPath.row
            cell.sendRequestBtn.addTarget(self, action: #selector(self.AcceptButton), for: .touchUpInside)
        }
        
        return cell
    }
    
    
    func AcceptButton(sender: AnyObject) -> Void {
        let OnesignalIndexPath = NSIndexPath(row: sender.tag, section: 0)
        if(suggestionsFlag){
           sendRequest(OnesignalIndexPath: OnesignalIndexPath)
        }
        else if(requestsFlag){
            conformRequest(OnesignalIndexPath: OnesignalIndexPath)
        }
    }
    
    func sendRequest(OnesignalIndexPath: NSIndexPath) -> Void {
        let reqOneSignalId = self.suggestionsArray[self.suggestionsArrayKey[OnesignalIndexPath.row]]!.value(forKey :"oneSignalId")
        let requestedUserUid = self.suggestionsArrayKey[OnesignalIndexPath.row]
        ref.child("Users").child(requestedUserUid).child("Requests").child(currentUserId).setValue(currentUser)
        let notificationText: String = currentUser + " sent you a friend request"
        OneSignal.postNotification(["contents": ["en": notificationText], "include_player_ids": [reqOneSignalId]])
    }
    
    func conformRequest(OnesignalIndexPath: NSIndexPath) -> Void {
        let friendUid = self.requestsArrayKey[OnesignalIndexPath.row]
        let friendOneSignalId = self.requestsArray[self.requestsArrayKey[OnesignalIndexPath.row]]!.value(forKey :"oneSignalId")
        let requestedUserUid = self.requestsArrayKey[OnesignalIndexPath.row]
        let friendDisplayName = self.requestsArray[self.requestsArrayKey[OnesignalIndexPath.row]]!.value(forKey :"displayName")
        ref.child("Users").child(requestedUserUid).child("Friends").child(friendUid).setValue(friendDisplayName)
        ref.child("Users").child(currentUserId).child("Friends").child(friendUid).setValue(friendDisplayName)
        ref.child("Users").child(currentUserId).child("Requests").child(requestedUserUid).removeValue()
        let notificationText: String = currentUser + " Accepted you a friend request"
        OneSignal.postNotification(["contents": ["en": notificationText], "include_player_ids": [friendOneSignalId]])
    }

    
    
    
    @IBAction func showRequests(_ sender: Any) {
        let greenGustomization : UICostomization = UICostomization(color: green.getColor(), width: width )
        greenGustomization.addBackground(object: self.requestsBtn)
        self.requestsBtn.tintColor = white.getColor()
        let whiteGustomization : UICostomization = UICostomization(color: white.getColor(), width: width )
        whiteGustomization.addBackground(object: self.suggestionsBtn)
        self.suggestionsBtn.tintColor = grey.getColor()
        requestsFlag = true
        suggestionsFlag = false
        self.requestsArray.removeAll()
        self.requestsArrayKey.removeAll()
        ref.child("Users").child(currentUserId).child("Requests").observe(FIRDataEventType.value, with: { (snapshot) in
            
            if (!snapshot.exists()){
                
               self.requestsArray.removeAll()
               self.requestsArrayKey.removeAll()
               self.tableView.reloadData()
            }
            
            
            else {
               self.requestsArray.removeAll()
               self.requestsArrayKey.removeAll()
               let reqData = snapshot.value  as! [String : AnyObject]
             
                for (key,value) in reqData {
                    
                    self.ref.child("Users").child(key).observeSingleEvent(of: .value, with: { snapshot in
                         if(snapshot.childrenCount > 0 ){
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                                self.requestsArrayKey.append(key as! String)
                                self.requestsArray[key as! String] = data as AnyObject?
                                self.tableView.reloadData()
                        }
                        
                         else {
                           print("Inside else ")
                            
                        }
                     })
                   
                   
                }
                    return
                }
                          
            })
        self.tableView.reloadData()
    }
    
    
    
    @IBAction func suggestions(_ sender: AnyObject) {
        let greenGustomization : UICostomization = UICostomization(color: green.getColor(), width: width )
        greenGustomization.addBackground(object: self.suggestionsBtn)
        self.suggestionsBtn.tintColor = white.getColor()
        let whiteGustomization : UICostomization = UICostomization(color: white.getColor(), width: width )
        whiteGustomization.addBackground(object: self.requestsBtn)
        self.requestsBtn.tintColor = grey.getColor()
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts){
        case .authorized:
            requestsFlag = false;
            suggestionsFlag = true
            self.fetchContacts()
            self.tableView.reloadData()
            
        // This is the method we will create
        case .notDetermined:
            contactStore.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    let notAuthorizedMessage = "Please Allow Ghost Gossip to access contacts . You can do it in Setting->Privacy->Contacts"
                    return
                }
                
            }
        default:
            
            let notAuthorizedMessage = "Please Allow Ghost Gossip to access contacts . You can do it in Setting->Privacy->Contacts"
        }
    }
    
    
    
    
    
    // to fetch contacts
    
    func fetchContacts() {
        var iteratorKey: Int = 0
        let toFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: toFetch as [CNKeyDescriptor])
        do{
            try contactStore.enumerateContacts(with: request) {
                contact, stop in
                
                for numbers: CNLabeledValue in contact.phoneNumbers{
                    var MobNumVar  = (numbers.value as! CNPhoneNumber).value(forKey: "digits") as? String
                    MobNumVar! = String(format:"%@",  MobNumVar!.substring(with: MobNumVar!.index((MobNumVar?.endIndex)!, offsetBy: -10)..<MobNumVar!.endIndex ))
                    MobNumVar! = String(format: "(%@) %@-%@",
                                        MobNumVar!.substring(with: MobNumVar!.startIndex ..< MobNumVar!.index(MobNumVar!.startIndex, offsetBy: 3)),
                                        MobNumVar!.substring(with: MobNumVar!.index(MobNumVar!.startIndex, offsetBy: 3) ..< MobNumVar!.index(MobNumVar!.startIndex, offsetBy: 6)),
                                        MobNumVar!.substring(with: MobNumVar!.index(MobNumVar!.startIndex, offsetBy: 6) ..< MobNumVar!.index(MobNumVar!.startIndex, offsetBy: 10)))
                   
                    self.ref.child("Users").queryOrdered(byChild: "phoneNumber").queryStarting(atValue: MobNumVar!).queryEnding(atValue: MobNumVar!).observeSingleEvent(of: .value, with: { snapshot in
                        
                        if(snapshot.exists()){
                            
                            
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                            
                            for suggestionsData in data{
                                
                                self.suggestionsArrayKey.append(suggestionsData.key as! String)
                                self.suggestionsArray[suggestionsData.key as! String] = suggestionsData.value as! NSDictionary
                            }
                            
                            
                            
                            self.tableView.reloadData()
                            
                        }
                        else {
                            
                            
                        }
                        
                    })
                    
                    
                }
                
            }
            
            
        } catch let err{
            print(err)
        }
        
    }
    
}
