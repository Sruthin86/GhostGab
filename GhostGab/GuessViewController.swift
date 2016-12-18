//
//  GuessViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/27/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class GuessViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var dateLable: UILabel!
    
    @IBOutlet weak var flagLabel: UILabel!
    
    @IBOutlet weak var wrongLabel: UILabel!
    
    @IBOutlet weak var rightLable: UILabel!
    
    @IBOutlet weak var messageLable: UILabel!
    
    @IBOutlet weak var cashCount: UILabel!
    
    @IBOutlet weak var cashButton: UIButton!
    
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let ref = FIRDatabase.database().reference()
    
    let helperClass : HelperFunctions = HelperFunctions()
    
    var postId: String = ""
    
    var guessPostArray = [String:AnyObject]()
    
    var oriFrinendsKeyArray = [String]()
    
    var friendsArray = [String: AnyObject]()
    
    var friendsArrayKey = [String]()
    
    var filteredFriendsArray = [String]()
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    var isShuffled:Bool = false
    
    var selfPostFalg:Bool = false
    
    var lowFriendCount:Bool = false
    
    var alreadyGuessed:Bool = false
    
    var justGuessed:Bool = false
    
    var selectdUid:String = ""
    
    var correctUid:String = ""
    
    var displayName:String = ""
    
    var cashCountNumber: Int = 0
    
    var correctGuessCounter: Int = 0
    
    var wrongGuessCounter: Int = 0
    
    var correctGuess:Bool = false
    
    var notenoughFriendsFlag:Bool = false
    
    var loaded:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.postLabel.text = guessPostArray["post"] as! String?
        self.dateLable.text = helperClass.getDifferenceInDates(postDate: (guessPostArray["date"]as? String)!)
        var flagCountObj: AnyObject = guessPostArray["flags"]!
        var postMetrics: AnyObject = guessPostArray["postMetrics"]!
        self.flagLabel.text =  String(describing: flagCountObj["flagCount"] as AnyObject)
        self.rightLable.text = String(describing: postMetrics["correctGuess"] as AnyObject)
        self.wrongLabel.text = String(describing: postMetrics["wrongGuess"] as AnyObject)
        self.correctGuessCounter = Int((postMetrics["correctGuess"] as AnyObject) as! NSNumber)
        self.wrongGuessCounter = Int((postMetrics["wrongGuess"] as AnyObject) as! NSNumber)
        self.displayName = guessPostArray["displayName"]! as! String
        self.cashButton.isEnabled = false
        getCashCount()
        
        if(guessPostArray["useruid"] as! String == uid as! String){
           selfPostFalg = true
        }
        else {
            if(self.oriFrinendsKeyArray.count>=3){
                 shuffleOriginalArray ()
                
            }
            else{
                self.notenoughFriendsFlag = true
                
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(selfPostFalg){
            let imageName = "Reaction3_lg.png"
            let labelText = "This is your post duh!!! "
            displyNoDataLabel(imageName:imageName, labelText:labelText)
            return 0
        }
        else if(isShuffled || alreadyGuessed ){
            return self.filteredFriendsArray.count
        }
        else if (notenoughFriendsFlag){
            let imageName = "Reaction2_lg.png"
            let labelText = "you dont have enough friends \nto guess!! "
            delay(0.75)  //Here you put time you want to delay
            {

                self.displyNoDataLabel(imageName:imageName, labelText:labelText)
            }
            return 0
        }
        else {
            return 0
        }
    }
    
    
    
    func displyNoDataLabel(imageName: String, labelText: String) -> Void {
        if(!self.loaded){
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            let image : UIImage = UIImage(named: imageName)!
            let imageView :UIImageView = UIImageView(image: image)
            imageView.frame = CGRect(x:self.tableView.frame.width/2 - 37.5, y:self.tableView.frame.height/3, width:75, height:99)
            let textColor: Color = Color.grey
            let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:self.tableView.frame.height/4, width:self.tableView.frame.width, height:self.tableView.frame.height) )
            
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
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let guessCell : GuessTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GuessCell") as! GuessTableViewCell
        
        
        if(isShuffled){
            self.loaded =  true;
            self.tableView.backgroundView = .none
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            guessCell.setImageData(photoUrl: self.friendsArray[self.filteredFriendsArray[indexPath.row]]!.value(forKey :"photo")! as! String)
            guessCell.displayName.text = self.friendsArray[self.filteredFriendsArray[indexPath.row]]!.value(forKey :"displayName")! as? String
            guessCell.setBackground(colorValue: "white")
            if(self.alreadyGuessed){
                if(self.selectdUid == guessPostArray["useruid"] as! String){
                    if(self.filteredFriendsArray[indexPath.row] == self.selectdUid ){
                        guessCell.setBackground(colorValue: "lightGreen")
                        correctGuess = true
                    }
                    
                }
                else{
                    if(self.filteredFriendsArray[indexPath.row] == self.selectdUid ){
                       guessCell.setBackground(colorValue: "lightRed")
                    }
                    
                }
            }
            
        }
        return guessCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if (self.alreadyGuessed){
            
        }
        else if (self.justGuessed){
            
        }
        else {
            let currIndexPath = tableView.indexPathForSelectedRow!
            let selectedIndexRow = currIndexPath.row
            let guessCell = tableView.cellForRow(at: currIndexPath as IndexPath) as! GuessTableViewCell
            if(self.filteredFriendsArray[selectedIndexRow] == guessPostArray["useruid"] as! String ){
                self.incrementCashCount(count:10)
                guessCell.setBackground(colorValue: "lightGreen")
                self.correctGuessCounter += 1
                self.rightLable.text = String(self.correctGuessCounter)
                self.ref.child("Posts").child(self.postId).child("postMetrics").child("correctGuess").setValue(correctGuessCounter)
            }
            else {
                self.decrementCashCount(count:5)
                guessCell.setBackground(colorValue: "lightRed")
                self.wrongGuessCounter += 1
                self.wrongLabel.text = String(self.wrongGuessCounter)
                self.ref.child("Posts").child(self.postId).child("postMetrics").child("wrongGuess").setValue(wrongGuessCounter)
                
            }
            let friendsList: [String:String] = ["friend1": self.filteredFriendsArray[0], "friend2": self.filteredFriendsArray[1], "friend3": self.filteredFriendsArray[2]]
            let guessData : [String : AnyObject] = ["postID": postId as AnyObject,"friendsList": friendsList as AnyObject, "seledtedUid": self.filteredFriendsArray[selectedIndexRow] as AnyObject, "postUid" : guessPostArray["useruid"] as AnyObject ]
            let guessPostData : [String : AnyObject] = [postId as String: guessData as AnyObject]
            ref.child("Users").child(self.uid as! String).child("guess").child(postId).setValue(guessData)
            ref.child("Posts").child(self.postId).child("guessedUsers").child(self.uid as! String).setValue(self.displayName)
            self.justGuessed = true
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 0
        self.present(mainTabBarView, animated: true, completion: nil)
    }
  
    
    
    
    func incrementCashCount(count:Int) {
        for index in 1...count{
            
            delay(0.1 * Double(index))  //Here you put time you want to delay
            {
                self.cashCountNumber += 1
                self.cashCount.text = String(self.cashCountNumber)
                if(index == count){
                    let cashCountString:String = String(self.cashCountNumber)
                    self.ref.child("Users").child(self.currentUserId).child("cash").setValue(cashCountString)
                }
            }
        }
        self.messageLable.text = "Congratulations , you got it right!!"
        self.cashButton.isEnabled = false
        
    }
    
    
    func decrementCashCount(count:Int) {
        for index in 1...count{
            
            delay(0.1 * Double(index))  //Here you put time you want to delay
            {
                self.cashCountNumber -= 1
                self.cashCount.text = String(self.cashCountNumber)
                if(index == count){
                    let cashCountString:String = String(self.cashCountNumber)
                    self.ref.child("Users").child(self.currentUserId).child("cash").setValue(cashCountString)
                }
            }
            
        }
        
        
        
        if(self.cashCountNumber>=15){
            self.messageLable.text = "You've already guessed once. \nIt'll cost you 10 points in cash to guess again"
            self.cashButton.isEnabled = true
        }
        else {
            self.messageLable.text = "You dont have enough points to guess again \ntough luck!!"
            
        }
        
    }

    
    
    
    func shuffleOriginalArray() {
        
        var count = self.oriFrinendsKeyArray.count
        for index in ((0 + 1)...self.oriFrinendsKeyArray.count - 1).reversed()
        {
            // Random int from 0 to index-1
            var j = Int(arc4random_uniform(UInt32(count-1)))
            
            // Swap two array elements
            // Notice '&' required as swap uses 'inout' parameters
            if(j != index){
                swap(&self.oriFrinendsKeyArray[index], &self.oriFrinendsKeyArray[j])
            }
        }
        checkPost()
    }
   
    func shuffleArray() {
        self.filteredFriendsArray = self.friendsArrayKey
        if(!self.filteredFriendsArray.contains(guessPostArray["useruid"] as! String)){
            self.filteredFriendsArray.removeLast()
            self.filteredFriendsArray.append(guessPostArray["useruid"] as! String)
        }
        var count = self.filteredFriendsArray.count
        for index in ((0 + 1)...self.filteredFriendsArray.count - 1).reversed()
        {
            // Random int from 0 to index-1
            var j = Int(arc4random_uniform(UInt32(index-1)))
            
            // Swap two array elements
            // Notice '&' required as swap uses 'inout' parameters
            swap(&self.filteredFriendsArray[index], &self.filteredFriendsArray[j])
        }
        isShuffled=true
       
       
        self.tableView.reloadData()
    }
    
    func getCashCount() {
        ref.child("Users").child(currentUserId).child("cash").observe(FIRDataEventType.value, with: {(snapshot) in
            
            if (snapshot.exists()){
                let cashCountval: String = snapshot.value as! String
                self.cashCountNumber = Int(cashCountval)!
                self.cashCount.text = cashCountval
            }
            
        })
        
    }
    func getFriends() -> Void {
        
        
            
        
                self.friendsArray.removeAll()
                self.friendsArrayKey.removeAll()
                let friendData = self.oriFrinendsKeyArray
                for (value) in friendData {
                    
                    self.ref.child("Users").child(value).observeSingleEvent(of: .value, with: { snapshot in
                        if(snapshot.childrenCount > 0 ){
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                            self.friendsArrayKey.append(value as! String)
                            self.friendsArray[value as! String] = data as AnyObject?
                            if(self.friendsArrayKey.count == 3){
                                self.notenoughFriendsFlag = false
                                if(self.alreadyGuessed){
                                    self.isShuffled=true
                                    self.tableView.reloadData()
                                    if(!self.correctGuess){
                                        if(self.cashCountNumber>=15){
                                            self.cashButton.isEnabled = true
                                        }
                                        else {
                                            self.messageLable.text = "You dont have enough points to guess again \ntough luck!!"
                                            
                                        }
                                    }
                                }
                                else {
                                    self.shuffleArray()
                                }
                            }
                            else if(self.friendsArrayKey.count < 3){
                                self.isShuffled = false
                                self.notenoughFriendsFlag = true
                                self.tableView.reloadData()
                            }

                        }
                            
                        else {
                            
                            
                        }
                    })
                    
                    
                }
                
        
            
       
    }

    func checkPost(){
        self.ref.child("Users").child(self.uid! as! String).child("guess").child(self.postId).observeSingleEvent(of: FIRDataEventType.value, with :  { (snapshot) in
            if(snapshot.exists()){
                let gData =  snapshot.value as! [String : AnyObject]
                for (key,value) in gData["friendsList"]  as! NSDictionary{
                   self.filteredFriendsArray.append(value as! String)
                }
                self.selectdUid = (gData["seledtedUid"] as! String?)!
                self.correctUid = (gData["postUid"] as! String?)!
                self.alreadyGuessed = true
                self.messageLable.text = "You've already guessed once. \nIt'll cost you 10 points in cash to guess again"
                self.getFriends()
                
            }
            else {
                self.getFriends()
            }
            
            
            
        })
        
    }
    

    @IBAction func spendCash(_ sender: Any) {
        if(cashCountNumber>=15){
            self.decrementCashCount(count:15)
            let newCashVal:String = String(self.cashCountNumber)
            ref.child("Users").child(currentUserId).child("cash").setValue(newCashVal)
            ref.child("Users").child(currentUserId).child("guess").child(postId).removeValue()
            self.alreadyGuessed = false
            self.justGuessed = false
            self.checkPost()
        }
        
    }
    
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

}
