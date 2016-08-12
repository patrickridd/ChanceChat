//
//  ThreadController.swift
//  Chat
//
//  Created by Patrick Ridd on 8/9/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation
import CloudKit

class ThreadController {
    
    static let sharedController = ThreadController()
    let cloudKitManager = CloudKitManager()
    
    var users = [User]()
    // Fetching Methods
    
    func fetchThreads(completion: ((threads: [Thread]?) -> Void)?) {
        UserController.sharedController.fetchCustomLoggedInUser { (user) in
            guard let user = user else {
                print("Could not fetch custom user to fetch its threads")
                return
            }
            
                        let reference = CKReference(recordID: user.record.recordID, action: .DeleteSelf)
                        let predicate = NSPredicate(format: "users CONTAINS %@", argumentArray: [reference])
            //
            //  let predicate = NSPredicate(value: true)
            self.cloudKitManager.fetchRecordsWithType(Thread.recordType, predicate: predicate, recordFetchedBlock: { (record) in
                
                guard let thread = Thread(record: record) else {
                    return
                }
                if let completion = completion {
                    completion(threads: [thread])
                }
                
                
                }, completion: { (records, error) in
                    guard let records = records else {
                        print("Thread records were nil when unwrapping")
                        completion?(threads: nil)
                        return
                    }
                    
                    let threads = records.flatMap({Thread(record: $0)})
                    if let completion = completion {
                        completion(threads: threads)
                    }
            })
        }
    }
    
    
    func getUsersFromThread(thread: Thread, completion: (users: [User]) ->Void) {
        
        
        for reference in thread.userReferences {
            let recordId = reference.recordID
            
            self.cloudKitManager.fetchRecordWithID(recordId, completion: { (record, error) in
                
                guard let record = record,
                    user = User(record: record) else {
                        print("Couldn't get record from references recordID")
                        return
                }
                self.users.append(user)
            })
            
        }
        completion(users: users)
    }
    
    func createThreadWithUsers(completion: (thread: Thread?) -> Void) {
        fetchUsersInApp { (users) in
            guard let users = users else {
                print("Users were nil after Fetching Users")
                completion(thread: nil)
                return
            }
            
        UserController.sharedController.fetchCustomLoggedInUser({ (user) in
            guard let user = user else {
                print("Couldn't get current user for thread. ")
                completion(thread: nil)
                return
            }
            let record = CKRecord(recordType: Thread.recordType)
            
            let newusers = [user, users[1]]
            
            var references: [CKReference] = []
            
            for user in newusers {
                references.append(CKReference(recordID: user.record.recordID, action: .DeleteSelf))
            }
            
            record[Thread.usersReferenceKey] = references
            let thread = Thread(userReferences: references, record: record)
            record[Thread.timestampKey] = thread.timestamp
            self.saveRecordToCloudKit(record)
            completion(thread: thread)
            
            

            
        })
            
        }
    }
    
    
    
    func fetchUsersInApp(completion: (users: [User]?) -> Void) {
        let predicate = NSPredicate(value: true)
        cloudKitManager.fetchRecordsWithType(User.recordType, predicate: predicate, recordFetchedBlock: { (record) in
            
            
        }) { (records, error) in
            guard let records = records else {
                print("User Records were nil when unwrapping")
                completion(users: nil)
                return
            }
            var users = [User]()
            for record in records {
                guard let user = User(record: record) else {
                    print("User was not initialized")
                    completion(users: nil)
                    return
                }
                
                users.append(user)
                print(user.username)
                
            }
            
            completion(users: users)
            
            
            
        }
        
    }
    
    func fetchThreadUserRecordsWithIDs(threads: [Thread], completion: () -> Void) {
        var count = threads.count
        
        for thread in threads {
            
            
            for userReference in thread.userReferences {
                cloudKitManager.fetchRecordWithID(userReference.recordID, completion: { (record, error) in
                    guard let record = record, user = User(record: record) else {
                        return
                    }
                    
                    thread.users.append(user)
                    count += 1
                    if count > threads.count {
                        completion()
                    }
                })
                
            }
        }
        
    }

    
    //    func fetchUsersInThread(thread: Thread, completion: (users: [User]?)-> Void) {
    //        /// Trying to get Users of particular Threads
    //        var recordIDs: [CKRecordID] = []
    //        for reference in thread.userReferences {
    //            recordIDs.append(reference.recordID)
    //        }
    //
    //        let predicate = NSPredicate(format: "RecordID IN %@", argumentArray: [recordIDs])
    //
    //        cloudKitManager.fetchRecordsWithType(User.recordType, predicate: predicate, recordFetchedBlock: { (record) in
    //
    //
    //            }) { (records, error) in
    //                guard let records = records else {
    //                    print("Records were nil of users in thread.")
    //                    completion(users: nil)
    //                    return
    //                }
    //                let users = records.flatMap({User(record: $0)})
    //                completion(users: users)
    //        }
    //    }
    
    
    func fetchMessagesFromThread(thread: Thread, completion: (messages: [Message]?) ->Void) {
        let reference = CKReference(recordID: thread.record.recordID, action: .None)
        let predicate = NSPredicate(format: "thread CONTAINS %@", argumentArray: [reference])
        
        cloudKitManager.fetchRecordsWithType(Message.recordType, predicate: predicate, recordFetchedBlock: { (record) in
            
            
        }) { (records, error) in
            guard let records = records else {
                completion(messages: nil)
                return
            }
            let messages = records.flatMap({Message(record: $0)})
            completion(messages: messages)
        }
        
    }
    
    
    func fetchSenderOfMessage(message: Message, completion: (user: User) -> Void) {
        let reference = CKReference(recordID: message.record.recordID, action: .DeleteSelf)
        let predicate = NSPredicate(format: "sender CONTAINS %@", argumentArray: [reference])
        
        cloudKitManager.fetchRecordsWithType(User.recordType, predicate: predicate, recordFetchedBlock: { (record) in
            
            guard let user = User(record: record) else {
                print("Could not initialize User with record from Message's Reference")
                return
            }
            completion(user: user)
            
        }) { (records, error) in
            
            
        }
        
    }
    
    
    func addMessageToThread(text: String, thread: Thread, sender: User, completion: () -> Void) {
        
        let record = CKRecord(recordType: Message.recordType)
        let message = Message(text: text, sender: sender, thread: thread, record: record)
        
        record[Message.textKey] = text
        record[Message.timestampKey] = NSDate()
        record[Message.threadReferenceKey] = CKReference(record: thread.record, action: .DeleteSelf)
        record[Message.senderReferenceKey] = CKReference(record: sender.record, action: .DeleteSelf)
        
        saveRecordToCloudKit(message.record)
        completion()
        
    }
    
    // Saving to cloudKit
    
    func saveRecordToCloudKit(record: CKRecord) {
        cloudKitManager.saveRecord(record) { (record, error) in
            if let error = error {
                print("Error saving record. Error: \(error)")
            }
        }
    }
    
    
    
}