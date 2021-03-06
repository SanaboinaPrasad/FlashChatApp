//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    var messageArray = [Message]()
    // Declare instance variables here

    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        
        messageTableView.delegate  = self
        messageTableView.dataSource = self
        configureTableView()
        messageTableView.separatorStyle = .none
        //TODO: Set yourself as the delegate of the text field here:
        
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        SenderretieveMessages()
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for:  indexPath) as!CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        if cell.senderUsername.text == Auth.auth().currentUser?.email as! String {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
        }
        else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelonColorDark()
            cell.messageBackground.backgroundColor = UIColor.flatRed()
        }
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
    }
    
    //TODO: Declare configureTableView here:
    
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
       let messageDB  = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,"MessageBody":messageTextfield.text!]
        messageDB.childByAutoId().setValue(messageDictionary){
            (error,reference) in
            if error != nil{
                print(error?.localizedDescription ?? "error")
            }
            else{
                print("Message saved Succesfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        
        //TODO: Send the message to Firebase and save it in our database
        
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func SenderretieveMessages(){
        
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded, with: { (snapchat) in
            let snapChatvalue = snapchat.value as! Dictionary<String,String>
            let text = snapChatvalue["MessageBody"]!
            let sender = snapChatvalue["Sender"]!
            print("\(sender),\(text)")
            let message = Message()
                message.messageBody = text
                message.sender  = sender
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        })
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try  Auth.auth().signOut()
        }
        catch{
            print("Signout is not succesfull")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil else {
            print("No viewController to Pop")
        return  
        }
    }
    


}
