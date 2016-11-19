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
    
    let ref = FIRDatabase.database().reference()
    
    var suggestionsFlag:Bool =  false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lightgrey :Color = Color.lightGrey
        let customization : UICostomization = UICostomization(color: lightgrey.getColor(), width: width )
        customization.addBorder(object: self.searchUserbtn)
        customization.addBorder(object: self.requestsBtn)
        customization.addBorder(object: self.suggestionsBtn)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: RequestSuggestionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "rsCell", for: indexPath) as! RequestSuggestionTableViewCell
        
        
        if (self.suggestionsFlag){
            
            cell.setImageData(photoUrl: self.suggestionsArray[self.suggestionsArrayKey[indexPath.row]]!.value(forKey :"photo")! as! String)
            cell.rsLabel.text = self.suggestionsArray[self.suggestionsArrayKey[indexPath.row]]!.value(forKey :"displayName")! as? String
        }
        
        return cell
    }
    
    
    @IBAction func suggestions(_ sender: AnyObject) {
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts){
        case .authorized:
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
                    print(MobNumVar!)
                    self.ref.child("Users").queryOrdered(byChild: "phoneNumber").queryStarting(atValue: MobNumVar!).queryEnding(atValue: MobNumVar!).observeSingleEvent(of: .value, with: { snapshot in
                        
                        if(snapshot.childrenCount > 0 ){
                            
                            
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                            
                            for suggestionsData in data{
                                
                                self.suggestionsArrayKey.append(suggestionsData.key as! String)
                                self.suggestionsArray[suggestionsData.key as! String] = suggestionsData.value as! NSDictionary
                            }
                            
                            
                            
                            self.tableView.reloadData()
                            
                        }
                        
                    })
                    
                    
                }
                
            }
            
            
        } catch let err{
            print(err)
        }
        
    }
    
}
