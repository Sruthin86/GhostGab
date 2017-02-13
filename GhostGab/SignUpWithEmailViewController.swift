//
//  SignUpWithEmailViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/6/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SCLAlertView
import OneSignal

class SignUpWithEmailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var conformPassword: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    let green: Color = Color.green
    
    var isImagePicked: Bool = false
    
    let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
    
    var oneSignalId:String?
    
    var overlayView = UIView()
    
    var spinner:loadingAnimation?
    override func viewDidLoad() {
        
        OneSignal.idsAvailable({ (userId, pushToken) in
            self.oneSignalId = userId!
            
            if (pushToken != nil) {
                
            }
        })
        
        super.viewDidLoad()
        spinner = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.name.delegate = self
        self.email.delegate = self
        self.password.delegate = self
        self.conformPassword.delegate = self
        let costomization:UICostomization =  UICostomization(color: green.getColor(), width:1)
        costomization.addBorder(object: self.name)
        costomization.addBorder(object: self.email)
        costomization.addBorder(object: self.password)
        costomization.addBorder(object: self.conformPassword)
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpWithEmailViewController.handleSelectProfileImageView))
        profileImageView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.name.resignFirstResponder()
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        self.conformPassword.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion:nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var SelectedImage: UIImage?
        if case let editedImage as UIImage =  info["UIImagePickerControllerEditedImage"]{
            
            SelectedImage = editedImage
        }
            
        else if case let originalImage as UIImage =  info["UIImagePickerControllerOriginalImage"]{
            
            SelectedImage = originalImage
        }
        
        if let pickedImage = SelectedImage{
            isImagePicked = true
            self.profileImageView.image = resizeImage(image: pickedImage, newWidth: 240)
            self.profileImageView.layer.cornerRadius  = self.profileImageView.frame.width/2
            self.profileImageView.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 5 )
            customization.addBorder(object: self.profileImageView)
        }
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func checkForInvalidValues() {
        
        if((self.name.text?.isEmpty)! || (self.email.text?.isEmpty)! || (self.password.text?.isEmpty)! || (self.conformPassword.text?.isEmpty)!){
            
            SCLAlertView().showError("Oops !!", subTitle: "Please enter all the fields ", circleIconImage:self.errorAletViewImage)
        }
            
        else if ((self.password.text?.characters.count)! < 8){
            SCLAlertView().showError("Oops !!", subTitle: "Your password must be atleast 8 characters", circleIconImage:self.errorAletViewImage)
        }
        else if (self.password.text != self.conformPassword.text){
            SCLAlertView().showError("Oops !!", subTitle: "Both your passwords does not match!!", circleIconImage:self.errorAletViewImage)
        }
            
        else if(!isImagePicked){
            SCLAlertView().showError("Oops !!", subTitle: "Please select an image from your Camera Roll  ", circleIconImage:self.errorAletViewImage)
        }
        else {
           
            self.spinner?.showOverlay(alphaValue: 1)
            saveImageToFirebase()
        }
        
        
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func saveImageToFirebase(){
        
        FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
            if(error != nil){
                self.spinner?.hideOverlayView()
                if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case .errorCodeInvalidEmail:
                       SCLAlertView().showError("Sorry !!", subTitle: "Please enter a valid email address", circleIconImage:self.errorAletViewImage)
                    case .errorCodeEmailAlreadyInUse:
                        SCLAlertView().showError("Sorry !!", subTitle: "The entered email address is already in use", circleIconImage:self.errorAletViewImage)
                    default:
                        print("Create User Error: \(error!)")
                    }
                }
            }
            else if (user != nil) {
                let profileImageName: String = user!.uid + ".png"
                let storageRef = FIRStorage.storage().reference().child(profileImageName)
                if let uplaodData = UIImagePNGRepresentation(self.profileImageView.image!){
                    
                    storageRef.put(uplaodData, metadata: nil, completion: { (metadata, error) in
                        if(error != nil){
                            self.spinner?.hideOverlayView()
                            SCLAlertView().showError("Sorry !!", subTitle: "We encountered an error . Plaese try again later", circleIconImage:self.errorAletViewImage)
                        }
                        else {
                            if let highResImagePicUrl  = metadata?.downloadURL()?.absoluteString{
                                
                                
                                let databaseRef = FIRDatabase.database().reference()
                                databaseRef.child("Users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if(snapshot.exists()){
                                        let comparingData = snapshot.value as! [String: AnyObject]
                                        let verified = comparingData["isVerified"] as! Bool
                                        
                                        if((verified != nil)){
                                            
                                            if(!verified){
                                                let uModel =  UserModel(name: user?.displayName, userName: "", email: user?.email, photoUrl:user?.photoURL?.absoluteString , phoneNumber:"" , isVerified: false, uid: user?.uid  )
                                                UserDefaults.standard.set(user?.uid, forKey: fireBaseUid)
                                                UserDefaults.standard.set(self.name.text, forKey: displayName)
                                                UserDefaults.standard.set("email", forKey: isUsing)
                                                let postUserData : [String : AnyObject] = ["displayName": self.name.text! as AnyObject,"photo": highResImagePicUrl as AnyObject, "highResPhoto": highResImagePicUrl as AnyObject,  "email":user!.email! as AnyObject, "userName":user!.uid as AnyObject,  "phoneNumber": "" as AnyObject,"isVerified":false as AnyObject, "isUsing":"email" as AnyObject, "oneSignalId":self.oneSignalId as AnyObject, "cash":"200"as! AnyObject   ]
                                                databaseRef.child("Users").child((user?.uid)!).setValue(postUserData)
                                                DispatchQueue.main.async (execute: {
                                                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                    let vc = storyboard.instantiateViewController(withIdentifier: "userNameandPh") as! UserNameAndPhoneNoViewController
                                                    self.present(vc, animated:true, completion:nil)
                                                    
                                                })
                                            }
                                            else {
                                                let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                                                let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                                                mainTabBarView.selectedIndex = 0
                                                self.present(mainTabBarView, animated: true, completion: nil)
                                            }
                                        }
                                        else {
                                            
                                        }
                                        
                                    }
                                    else {
                                        
                                        
                                        let uModel =  UserModel(name: self.name.text, userName: "", email: user?.email, photoUrl:user?.photoURL?.absoluteString , phoneNumber:"" , isVerified: false, uid: user?.uid  )
                                        UserDefaults.standard.set(user?.uid, forKey: fireBaseUid)
                                        UserDefaults.standard.set(self.name.text, forKey: displayName)
                                        UserDefaults.standard.set("email", forKey: isUsing)
                                        let postUserData : [String : AnyObject] = ["displayName": self.name.text as AnyObject,"photo": highResImagePicUrl as AnyObject, "highResPhoto": highResImagePicUrl as AnyObject,  "email":user!.email! as AnyObject, "userName":user!.uid as AnyObject,  "phoneNumber": "" as AnyObject,"isVerified":false as AnyObject, "isUsing":"email" as AnyObject, "oneSignalId":self.oneSignalId as AnyObject, "cash":"200" as AnyObject  ]
                                        databaseRef.child("Users").child((user?.uid)!).setValue(postUserData)
                                        DispatchQueue.main.async (execute: {
                                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = storyboard.instantiateViewController(withIdentifier: "userNameandPh") as! UserNameAndPhoneNoViewController
                                            self.present(vc, animated:true, completion:nil)
                                            
                                        })
                                    }
                                })
                                
                                
                                
                                
                            }
                        }
                        
                    })
                    
                }
            }
        }
    }
    
    @IBAction func Sign_Up(_ sender: Any) {
        
        checkForInvalidValues()
    }
    
    
}
