//
//  SearchViewController.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 9/10/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Firebase
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchUserbtn: UIButton!
    
    @IBOutlet weak var requestsBtn: UIButton!
    
    @IBOutlet weak var suggestionsBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var contactStore = CNContactStore()
    
    var width:CGFloat = 1
    
    var phNumbersForSuggestions = [String]()
    
    var suggestionsArray = [Int: AnyObject]()
    
    let ref = FIRDatabase.database().reference()
    
    var suggestionsFlag:Bool =  false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lightgrey :Color = Color.lightGrey
        let customization : UICostomization = UICostomization(color: lightgrey.getColor(), width: width )
        customization.addBorder(self.searchUserbtn)
        customization.addBorder(self.requestsBtn)
        customization.addBorder(self.suggestionsBtn)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.suggestionsFlag){
            if let suggestionsLength : Int = suggestionsArray.count{
                return suggestionsLength
            }
            else{
                return 10
            }
        }
        else {
            return 10
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : R_STableViewCell = self.tableView.dequeueReusableCellWithIdentifier("R_SCell") as! R_STableViewCell
        
        if (self.suggestionsFlag){
            
            print(self.suggestionsArray[indexPath.row]!.valueForKey("image")! as! String)
            cell.setImageData(self.suggestionsArray[indexPath.row]!.valueForKey("image")! as! String)
            cell.r_s_label.text = self.suggestionsArray[indexPath.row]!.valueForKey("suggestionsName")! as? String
        }
        
        return cell
    }
    
    
    @IBAction func suggestions(sender: AnyObject) {
        suggestionsFlag = true
        switch CNContactStore.authorizationStatusForEntityType(.Contacts){
        case .Authorized:
            self.fetchContacts()
            print("Authorized")
        // This is the method we will create
        case .NotDetermined:
            contactStore.requestAccessForEntityType(.Contacts){succeeded, err in
                guard err == nil && succeeded else{
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
        let request = CNContactFetchRequest(keysToFetch: toFetch)
        do{
            try contactStore.enumerateContactsWithFetchRequest(request) {
                contact, stop in
                
                for numbers: CNLabeledValue in contact.phoneNumbers{
                    var MobNumVar  = (numbers.value as! CNPhoneNumber).valueForKey("digits") as? String
                    MobNumVar! = String(format:"%@",  MobNumVar!.substringWithRange(MobNumVar!.endIndex.advancedBy(-10)..<MobNumVar!.endIndex ))
                    MobNumVar! = String(format: "(%@) %@-%@",
                                        MobNumVar!.substringWithRange(MobNumVar!.startIndex ... MobNumVar!.startIndex.advancedBy(2)),
                                        MobNumVar!.substringWithRange(MobNumVar!.startIndex.advancedBy(3) ... MobNumVar!.startIndex.advancedBy(5)),
                                        MobNumVar!.substringWithRange(MobNumVar!.startIndex.advancedBy(6) ... MobNumVar!.startIndex.advancedBy(9)))
                    print(MobNumVar!)
                    self.ref.child("Users").queryOrderedByChild("phoneNumber").queryStartingAtValue(MobNumVar!).queryEndingAtValue(MobNumVar!+"\u{f8ff}").observeSingleEventOfType(.Value, withBlock: { snapshot in
                        for user in snapshot.children{
                            let suggestionsData : [String: AnyObject] = ["suggestionsUid" :user.key , "suggestionsName": (user.value?["displayName"])!, "image": (user.value?["highResPhoto"])! ]
                            self.suggestionsArray[iteratorKey] = suggestionsData
                            self.phNumbersForSuggestions.append(MobNumVar!)
                            print(self.phNumbersForSuggestions)
                            print(self.suggestionsArray)
                            iteratorKey += 1
                        }
                            self.tableView.reloadData()

                    })
                    
                }
            }
           
            
        } catch let err{
            print(err)
        }
    }
    
}
