//
//  RequestsSuggestionsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 10/16/16.
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
    
    var suggestionsArray = [Int: AnyObject]()
    
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
            
            print(self.suggestionsArray[indexPath.row]!.value(forKey: "image") as! String)
            cell.setImageData(photoUrl: self.suggestionsArray[indexPath.row]!.value(forKey :"image")! as! String)
            cell.rsLabel.text = self.suggestionsArray[indexPath.row]!.value(forKey :"suggestionsName")! as? String
        }
        
        return cell
    }
    
    
    @IBAction func suggestions(sender: AnyObject) {
        suggestionsFlag = true
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            self.fetchContacts()
            print("Authorized")
        // This is the method we will create
        case .notDetermined:
            contactStore.requestAccess(for: .contacts){succeeded, err in
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
        let request = CNContactFetchRequest(keysToFetch: toFetch as [CNKeyDescriptor])
        do{
            try contactStore.enumerateContacts(with: request) {
                contact, stop in
                
                //                for numbers: CNLabeledValue in contact.phoneNumbers{
                //                    var MobNumVar  = (numbers.value as! CNPhoneNumber).value(forKey: "digits") as? String
                //                    MobNumVar! = String(format:"%@",  MobNumVar!.substring(with: MobNumVar!.index((MobNumVar?.endIndex)!, offsetBy: -10)..<MobNumVar!.endIndex ))
                //                    MobNumVar! = String(format: "(%@) %@-%@",
                //                                        MobNumVar!.substringWith(MobNumVar!.startIndex ... MobNumVar!.index(after: 2)),
                //                                        MobNumVar!.substringWithRange(MobNumVar!.index(after: 3) ... MobNumVar!.index(after: 5)),
                //                                        MobNumVar!.substringWithRange(MobNumVar!.index(after: 6) ... MobNumVar!.index(after: 9)))
                //                    print(MobNumVar!)
                //                    self.ref.child("Users").queryOrdered(byChild: "phoneNumber").queryStarting(atValue: MobNumVar!).queryEnding(atValue: MobNumVar!+"\u{f8ff}").observeSingleEvent(of: .value, with: { snapshot in
                //                        for user:AnyObject in snapshot.children  {
                //                            let suggestionsData : [String: AnyObject] = ["suggestionsUid" :(user as AnyObject).key , "suggestionsName": (user.value?["displayName"])!, "image": (user.value?["highResPhoto"])! ]
                //                            self.suggestionsArray[iteratorKey] = suggestionsData as AnyObject?
                //                            self.phNumbersForSuggestions.append(MobNumVar!)
                //                            print(self.phNumbersForSuggestions)
                //                            print(self.suggestionsArray)
                //                            iteratorKey += 1
                //                        }
                //                            self.tableView.reloadData()
                //
                //                    })
                //                    
                //                }
            }
            
            
        } catch let err{
            print(err)
        }
    }
    
}
