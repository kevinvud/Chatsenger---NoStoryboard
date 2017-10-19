//
//  ChatLogController.swift
//  Chatsenger - NoStoryboard
//
//  Created by PoGo on 10/16/17.
//  Copyright © 2017 PoGo. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var user: User?{
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    
    var startingImageView: UIImageView?
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else{return}
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else{return}
                
                let message = Message(dictionary: dictionary)
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
                    }
                

            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Enter message..."
        inputTextField.delegate = self
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        return inputTextField
        
    }()
    
     let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive

        setupKeyboardObservers()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
//    @objc func handleKeyboardWillShow(notification: Notification){
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//
//        containerViewBottomAnchor?.constant -= (keyboardFrame?.height)!
//        UIView.animate(withDuration: keyboardDuration!) {
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    @objc func handleKeyboardWillHide(notification: Notification){
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//
//        containerViewBottomAnchor?.constant = 0
//        UIView.animate(withDuration: keyboardDuration!, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
    
    @objc func handleKeyBoardDidShow(notification: Notification){
        if messages.count > 0{
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "attachment")
        uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView

    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    
    @objc func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            handleVideoSelectedForUrl(url: videoUrl)

        }else{
             handleImageSelectedForInfo(info as [String : AnyObject])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleVideoSelectedForUrl(url: URL){
        
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_videos").child(fileName).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                print("failed upload video")
                
            }else{
                if let videoUrl = metadata?.downloadURL()?.absoluteString{
                    
                    if let thumbnailImage = self.thumbnailImageForVideoUrl(url){
                        self.uploadToFireBaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                            let properties: [String: Any] = ["imageUrl": imageUrl,"videoUrl": videoUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height]
                            self.sendMessageWithProperties(properties: properties)
                            self.inputTextField.resignFirstResponder()
                        })

                    }
                    
                    
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount{
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    func thumbnailImageForVideoUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
                    return UIImage(cgImage: thumbnailCGImage)
        }catch{
            print(error)
        }
        
        return nil
    }
    
    
    func handleImageSelectedForInfo(_ info: [String: AnyObject]) {
        
     var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            uploadToFireBaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessgeWithImageUrl(imageUrl: imageUrl, image : selectedImage)
            })
        }

    }

    private func uploadToFireBaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!.localizedDescription)
                }else{
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        completion(imageUrl)
                        
                        
                    }
                }
            })
       
        }
        
    }
    @objc func handleSend(){
        if let inputTextField = inputTextField.text, inputTextField != "" {
            let properties = ["text": inputTextField]
            sendMessageWithProperties(properties: properties as [String : Any])
            self.inputTextField.resignFirstResponder()
        }
    }
    
    private func sendMessgeWithImageUrl(imageUrl: String, image: UIImage){
        let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
        self.inputTextField.resignFirstResponder()
    }
    
    private func sendMessageWithProperties(properties: [String: Any]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        var values = ["toId": toId, "fromId": fromId, "timestamp" : timestamp] as [String : Any]
        
        for (key,value) in properties{
                values.updateValue(value, forKey: key)
        }

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                //send alert maybe
            }else{
                self.inputTextField.text = nil
                let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                let messageId = childRef.key
                userMessageRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 2])
            }
        }
    }



    var containerViewBottomAnchor: NSLayoutConstraint?

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout{
    
   
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.row]
        cell.message = message 
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)
        
        //modify buble width
        
        if let text = message.text {
             cell.bubleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil{
            cell.bubleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            
        }
        
        if message.videoUrl != nil{
            cell.playButton.isHidden = false
        }else{
            cell.playButton.isHidden = true
        }
       

        return cell
    }
    
    
    private func setupCell(cell: ChatMessageCell, message: Message){
      
        
        //blue or gray bubble
        if message.fromId == Auth.auth().currentUser?.uid{
            cell.bubleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubleViewRightAnchor?.isActive = true
            cell.bubleViewLeftAnchor?.isActive = false
        }else{
            cell.bubleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            
            cell.profileImageView.isHidden = false
            cell.bubleViewRightAnchor?.isActive = false
            cell.bubleViewLeftAnchor?.isActive = true
            
        }
        
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImagesUsingCacheWithUrlString(profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImagesUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            height = CGFloat(imageHeight/imageWidth) * 200
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(tap: UITapGestureRecognizer){
       if let zoomOutImageView = tap.view {
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomOutImageView.frame = self.startingFrame!
            self.blackBackgroundView?.alpha = 0
            self.inputContainerView.alpha = 1
        }, completion: { (completed) in
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        })
    
        }
    }
}
