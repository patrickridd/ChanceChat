//
//  MessageListTableViewController.swift
//  Chat
//
//  Created by Patrick Ridd on 8/9/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import UIKit

class ThreadListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LoginDelegate {
    
    var cloudKitManager = CloudKitManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    var threads = [Thread]()
    var users = [User]()
    var numbers = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
            if let error = error  {
                print("error fetching logged in user. Error: \(error.localizedDescription)")
                self.alertUserToSignInToCloudKit()
                return
            }
        }
        
        UserController.sharedController.fetchCustomLoggedInUserRecord { (record) in
          
            guard let record = record else {
                print("custom logged in user record is nil")
                self.presentLoginViewController()
                return
            }
            
            let user = User(record: record)
            if user == nil {
                self.presentLoginViewController()
            }
        }
        
        
        ThreadController.sharedController.fetchThreads { (threads) in
            guard let threads = threads else {
                print("Threads were nil when unwrapping on ThreadTVC")
                return
            }
            
            let sortedThreads = threads.sort{$0.0.timestamp.timeIntervalSince1970 > $0.1.timestamp.timeIntervalSince1970}
            
            self.threads = sortedThreads
        
            ThreadController.sharedController.fetchThreadUserRecordsWithIDs(self.threads, completion: { 
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.numbers += 1
                    print("\(self.numbers)")
                    
                    self.tableView.reloadData()
                    
                })
                
            })
            

        }
    }
    
    
    
    // Load Login Screen
    
    func presentLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginScreen = storyboard.instantiateViewControllerWithIdentifier("loginScreen")
        presentViewController(loginScreen, animated: true, completion: nil)
        
    }
    
    // Alert User to press ChanceChat button to start chatting
    
    func presentPressButtonAction() {
        let alert = UIAlertController(title: "Hey New User", message: "To start Chatting with someone by chance, tap the ChanceChat Button", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Sounds Good", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // Alert user to sign into cloudkit
    func alertUserToSignInToCloudKit() {
        let alert = UIAlertController(title: "Not Signed Into iCloud Account", message: "In order for this app to function correctly you need to sign into your iCloud Account", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: "prefs:root=CASTLE")
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(dismissAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
        
    
    // MARK: - Action Methods
    
    
    // MARK: - DataSource Methods
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.threads.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath) as? ThreadTableViewCell
        
        let thread = self.threads[indexPath.row]
        
        cell?.updateCell(thread)
        

        return cell ?? UITableViewCell()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "existingThread" {
            
            let MessageTVC = segue.destinationViewController as? MessagesTableViewController
            // Pass the selected object to the new view controller.
            
            // What do I Need and How am I going to get it?
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let thread = threads[indexPath.row]
            
            ThreadController.sharedController.fetchMessagesFromThread(thread, completion: { (messages) in
                guard let messages = messages,
                    messageTVC = MessageTVC else {
                        return
                }
                let sortedMessages = messages.sort({$0.0.timestamp.timeIntervalSince1970 < $0.1.timestamp.timeIntervalSince1970})
                messageTVC.messages = sortedMessages
            })
        } else if segue.identifier == "newThread" {
            
            let MessageTVC = segue.destinationViewController as? MessagesTableViewController

            
            ThreadController.sharedController.createThreadWithUsers({ (thread) in
                guard let thread = thread  else {
                    print("Thread was nil when unwrapping")
                    return
                }
                
                
                ThreadController.sharedController.fetchMessagesFromThread(thread, completion: { (messages) in
                    guard let messages = messages, messagesTVC = MessageTVC else {
                        print("messages were nil when unwrapping")
                        return
                    }
                    let sortedMessages = messages.sort({$0.0.timestamp.timeIntervalSince1970 < $0.1.timestamp.timeIntervalSince1970})
                   
                    
                    messagesTVC.messages = sortedMessages
                    messagesTVC.thread = thread
                    
                })
                
                
            })
            
            
            
        }
    }
}
