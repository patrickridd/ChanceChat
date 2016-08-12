//
//  UserController.swift
//  Chat
//
//  Created by Patrick Ridd on 8/9/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation
import CloudKit


class UserController {
    
    static let sharedController = UserController()
    var cloudKitManager = CloudKitManager()
    
    
    
    func createUser(username: String) {
        
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
            guard let record = record else {
                print("No logged in record found")
                return
            }
            let newRecord = CKRecord(recordType: User.recordType)
            newRecord["identifier"] = CKReference(recordID: record.recordID, action: .None)
            newRecord[User.usernameKey] = username
            let user = User(username: username, threads: [], record: newRecord)
            
            for thread in user.threads {
                newRecord[User.referencesPointingToThreadsKey] = CKReference(record: thread.record, action: .None)
            }
            
            self.cloudKitManager.saveRecord(newRecord, completion: { (record, error) in
                if let record = record {
                    print("Successfully Saved User Record: \(record)")
                } else {
                    print("Error in saving the Current User's username. Error: \(error)")
                }
            })
        }
        
    }
    
        
    func fetchCustomLoggedInUserRecord(completion: (record: CKRecord?) -> Void) {
        
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
            guard let record = record else {
                return
            }
            
            let reference = CKReference(recordID: record.recordID, action: .None)
            let predicate = NSPredicate(format: "identifier == %@", reference)
            
            self.cloudKitManager.fetchRecordsWithType(User.recordType, predicate: predicate , recordFetchedBlock: { (record) in
                
                completion(record: record)
                
                }, completion: { (records, error) in
                    
            })
            
        }
    }
    
    
    func fetchCustomLoggedInUser(completion: (user: User?) -> Void) {
        
        fetchCustomLoggedInUserRecord { (record) in
            guard let record = record, user = User(record: record) else {
                print("Could not fetch custom logged in user record or couldn't initialize the user from that record")
                completion(user: nil)
                return
            }
            completion(user: user)
        }
    }

}







