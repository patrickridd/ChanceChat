//
//  MessagesTableViewController.swift
//  Chat
//
//  Created by Patrick Ridd on 8/11/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import UIKit

class MessagesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var messages: [Message] = []
    var thread: Thread?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = ""
        
        
        
        
    }
    // MARK: Action Methods
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        guard let messageText = messageTextField.text where !(messageText.isEmpty) else {
            presentAlert()
            return
        }
           self.messageTextField.text = ""
        UserController.sharedController.fetchCustomLoggedInUser { (user) in
            guard let user = user, thread = self.thread else {
                print("Couldn't fetch user to find sender")
                return
            }
            
            ThreadController.sharedController.addMessageToThread(messageText, thread: thread, sender: user, completion: { 
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            })
            
        }
        
    }
    
    func setTitleText(thread: Thread) {
        UserController.sharedController.fetchCustomLoggedInUser { (user) in
            guard let user = user else {
                print("Couldn't fetch current user for messagetvc title")
                return
            }
            var titleText = ""
            
            ThreadController.sharedController.getUsersFromThread(thread, completion: { (users) in
                
                for messageUser in users {
                    if user.username == messageUser.username {
                        continue
                    }
                    titleText += messageUser.username + " "
                }
                
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.title = titleText
            })
            
        }
       
        
    }
    
    // Alert User to Enter Message that is not empty
    func presentAlert() {
        let alert = UIAlertController(title: "Message needs at least one character", message: nil, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Got it", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)

    }
    // MARK: - Table view data source
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath)
        
        let message = messages[indexPath.row]
        // Configure the cell...
        ThreadController.sharedController.fetchSenderOfMessage(message) { (user) in
            
            cell.textLabel?.text = "\(user.username) says: \(message.text)"
        }
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(message.timestamp)
        
        return cell
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
