//
//  EditViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/6/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseDatabase
import SCLAlertView

class EditViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ProfileImageView: UIImageView!
    
    @IBOutlet weak var name: UITextField!
    
    let green : Color = Color.green
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    var isImageEdited: Bool = false
    
    let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
    
    var overlayView = UIView()
    
    var spinner:loadingAnimation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner = loadingAnimation(overlayView: overlayView, senderView: self.view)
        self.name.delegate = self
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(self.uid as! String).observe(FIRDataEventType.value, with: { (snapshot) in
            
            let userDetails = snapshot.value as! [String: AnyObject]
            self.name.text = userDetails["displayName"] as! String?
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
            self.ProfileImageView.image = UIImage(data: profilePicUrl! as Data)
            self.ProfileImageView.layer.cornerRadius  = self.ProfileImageView.frame.width/2
            self.ProfileImageView.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 5)
            customization.addBorder(object: self.ProfileImageView)
            let textcustomization: UICostomization  = UICostomization(color:self.green.getColor(), width: 1)
            textcustomization.addBorder(object: self.name)
            let tap = UITapGestureRecognizer(target: self, action: #selector(EditViewController.handleSelectProfileImageView))
            self.ProfileImageView.addGestureRecognizer(tap)
            
            
        })
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.name.resignFirstResponder()
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
            isImageEdited = true
            self.ProfileImageView.image = resizeImage(image: pickedImage, newWidth: 240)
            self.ProfileImageView.layer.cornerRadius  = self.ProfileImageView.frame.width/2
            self.ProfileImageView.clipsToBounds = true;
            let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 5 )
            customization.addBorder(object: self.ProfileImageView)
        }
        dismiss(animated: true, completion: nil)
        
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
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkForInvalidValues() {
        
        if((self.name.text?.isEmpty)!){
            
            SCLAlertView().showError("Oops !!", subTitle: "Name field cannot be empty", circleIconImage:self.errorAletViewImage)
        }
        else if (isImageEdited){
            self.spinner?.showOverlay(alphaValue: 1)
            updateImage()
        }
        else {
            self.spinner?.showOverlay(alphaValue: 1)
            updateName()
        }
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 4
        self.present(mainTabBarView, animated: true, completion: nil)
        
    }
    
    
    func updateImage(){
        let profileImageName: String = uid as! String + ".png"
        let storageRef = FIRStorage.storage().reference().child(profileImageName)
        if let uplaodData = UIImagePNGRepresentation(self.ProfileImageView.image!){
            
            storageRef.put(uplaodData, metadata: nil, completion: { (metadata, error) in
                if(error != nil){
                    self.spinner?.hideOverlayView()
                    SCLAlertView().showError("Sorry !!", subTitle: "We encountered an error . Plaese try again later", circleIconImage:self.errorAletViewImage)
                }
                else {
                    if let highResImagePicUrl  = metadata?.downloadURL()?.absoluteString{
                      let databaseRef = FIRDatabase.database().reference()
                      databaseRef.child("Users").child(self.uid as! String).child("highResPhoto").setValue(highResImagePicUrl)
                      databaseRef.child("Users").child(self.uid as! String).child("photo").setValue(highResImagePicUrl)
                      databaseRef.child("Users").child(self.uid as! String).child("displayName").setValue(self.name.text)
                    }
                    
                }
            })
        }
    }
    
    func updateName(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(self.uid as! String).child("displayName").setValue(self.name.text)
        
    }
    
    @IBAction func save_btn(_ sender: Any) {
        checkForInvalidValues()
        
    }
    
    @IBAction func back_btn(_ sender: Any) {
        
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 4
        //trasition from left
        let transition = CATransition()
        transition.duration = 0.28
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
        self.present(mainTabBarView, animated: false, completion: nil)

    }
    
    
    
    
    
}
