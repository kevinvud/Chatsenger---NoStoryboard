//
//  ViewController.swift
//  Chatsenger - NoStoryboard
//
//  Created by PoGo on 10/15/17.
//  Copyright © 2017 PoGo. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "newmessage")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
       // observerMessages()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    var messages = [Message]()
//    var messagesDictionary = [String: Message]()
    
    
    func observerUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if let dictionary = snapshot.value as? [String: Any]{
                    let message = Message(dictionary: dictionary)
                    self.messages.insert(message, at: 0)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, withCancel: nil)

           
        }, withCancel: nil)
        
        
    }
    
//    func observerMessages(){
//        let ref = Database.database().reference().child("messages")
//        ref.observe(.childAdded, with: { (snapshot) in
//          
//            if let dictionary = snapshot.value as? [String: Any]{
//                
//                let message = Message(dictionary: dictionary)
//                //self.messages.append(message)
//                self.messages.insert(message, at: 0)
//                
//                DispatchQueue.main.async {
//                     self.tableView.reloadData()
//                }
//            }
//            
//        }, withCancel: nil)
//        
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }else{
            fetchUserAndSetupNavBarTitle()
        }

    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                
                let user = User(dictionary: dictionary as [String : AnyObject])
                self.setupNavBarWithUser(user)
                
                
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User){
        
        messages.removeAll()
        tableView.reloadData()
        
        observerUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImagesUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        
    }
    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user

        //similar to perform segue
        navigationController?.pushViewController(chatLogController, animated: true)
        
        
    }
    
    @objc func handleLogout(){
        
        do{
            try   Auth.auth().signOut()
        } catch{
            print(error)
        }
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)

        
    }
}

