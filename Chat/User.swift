//
//  User.swift
//  Chat
//
//  Created by Patrick Ridd on 8/9/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class User {
    
    static var cloudKitManager = CloudKitManager()
    
    static let recordType = "User"
    static let photoKey = "photo"
    static let usernameKey = "username"
    static let searchForNewChatKey = "searchForNewChat"
    static let referencesPointingToThreadsKey = "referencesPointingToThreadsKey"
    static var ckThreads = [Thread]()
    //////////////////////////////////////
    
    
    
    // MARK: Properties and Initializer for Model
    
    var username: String
    var searchForNewChat: Bool
    var threads: [Thread]
    let record: CKRecord
    
    init(username: String, searchForNewChat: Bool = true, threads: [Thread], record: CKRecord) {
        
        self.username = username
        self.searchForNewChat = searchForNewChat
        self.threads = threads
        self.record = record
        
    }
    
    
    ////////////////////////////////////////
    
    
    
    //Failable Initialize
    
    convenience init?(record: CKRecord) {
        guard let username = record[User.usernameKey] as? String else {
            return nil
        }
        
        if let threadsAsReferences = record[User.referencesPointingToThreadsKey] as? [CKReference] {
            
            for threadReference in threadsAsReferences {
                User.cloudKitManager.fetchRecordWithID(threadReference.recordID, completion: { (record, error) in
                    if let record = record, thread = Thread(record: record)  {
                        User.ckThreads.append(thread)
                    }
                    
                })
                
            }
        }
        
        self.init(username: username, searchForNewChat: false, threads: User.ckThreads, record: record)
        
    }
    
    
    
}