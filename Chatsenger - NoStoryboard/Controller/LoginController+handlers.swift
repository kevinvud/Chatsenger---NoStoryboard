//
//  LoginController+handlers.swift
//  Chatsenger - NoStoryboard
//
//  Created by PoGo on 10/16/17.
//  Copyright © 2017 PoGo. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!)
                
            }else{
                
                guard let uid = user?.uid else {return}
                
                //storage firebase
                let imageName = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
                
                //Compress image to reduce size
                if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            print(error as Any)
                        }else{
                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                                let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                                self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]){
        let ref = Database.database().reference(fromURL: "https://chatsenger.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err!)
                
            }else{
                
                let user = User(dictionary: values)
                self.messagesController?.setupNavBarWithUser(user)
  
                //self.messagesController?.fetchUserAndSetupNavBarTitle()
                self.dismiss(animated: true, completion: nil)
                print("Saved user successfully into Firebase db")
            }
        })
    }
    
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
    }
}

