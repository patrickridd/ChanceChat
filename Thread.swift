//
//  Thread.swift
//  Chat
//
//  Created by Patrick Ridd on 8/9/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation
import CloudKit

class Thread {
    
    var cloud = CloudKitManager()
    
    static let recordType = "thread"
    static let timestampKey = "timestamp"
    static let usersReferenceKey = "users"
    
    ////////////////////////////////////////////////
    
        // MARK: Properties & Model Initializer
    
    var userReferences: [CKReference]
    let timestamp: NSDate
    let record: CKRecord
    var users: [User]
    
    init(userReferences:[CKReference], timestamp: NSDate = NSDate(), record: CKRecord, users: [User] = []) {
        self.userReferences = userReferences
        self.timestamp = timestamp
        self.record = record
        self.users = users

    }
    
    ////////////////////////////////////////////////
    
    // MARK: CloudKit Properties and failable initializer

    init?(record: CKRecord) {
       guard let timestamp = record[Thread.timestampKey] as? NSDate,
        userReferences = record[Thread.usersReferenceKey] as? [CKReference]
        else {
                return nil
        }
        self.record = record
        self.timestamp = timestamp
        self.userReferences = userReferences
        self.users = []

    }
    
}