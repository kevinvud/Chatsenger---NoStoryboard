//
//  NewMessageController.swift
//  Chatsenger - NoStoryboard
//
//  Created by PoGo on 10/16/17.
//  Copyright © 2017 PoGo. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellID = "cellId"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        fetchUser()
    }
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
                
            }
            
            
        }, withCancel: nil)
        
        
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
            
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Use this only when haven't register cell
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserCell
        
        
        let user = users[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
//        cell.imageView?.contentMode = .scaleAspectFill
        //cell.imageView?.image = UIImage(named: "profile")
        
        if let profileImageUrl = user.profileImageUrl{
            
            cell?.profileImageView.loadImagesUsingCacheWithUrlString(profileImageUrl)
            
        }
        return cell!

    }

}




