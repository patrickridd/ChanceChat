//
//  Message.swift
//  Chat
//
//  Created by Patrick Ridd on 8/9/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation
import CloudKit

class Message {
    
    static var cloudKitManager = CloudKitManager()
    
    static let timestampKey = "timestamp"
    static let recordType = "message"
    static let textKey = "text"
    static let threadReferenceKey = "thread"
    static let senderReferenceKey = "sender"
    static var senderReference: User?
    static var threadReference: Thread?
    //////////////////////////////////////////
    
    // MARK: - Properties and Initializer
    
    var text: String
    let timestamp: NSDate
    var sender: User
    var thread: Thread
    var record: CKRecord
    
    init(text: String, sender: User, thread: Thread, timestamp: NSDate = NSDate(), record: CKRecord) {
        
        self.text = text
        self.timestamp = timestamp
        self.sender = sender
        self.thread = thread
        self.record = record
    }
    
    
    /////////////////////////////////////////
    
    // MARK: - CloudKit Properties and failable Initializer
    
//    var cloudKitRecord: CKRecord {
//        let record = CKRecord(recordType: Message.recordType)
//        record[Message.timestampKey] = timestamp
//        record[Message.textKey] = text
//        
//        record[Message.threadReferenceKey] = CKReference.init(record: thread.record, action: .DeleteSelf)
//        record[Message.senderReferenceKey] = CKReference(record: sender.record, action: .None)
//        
//        return record
//    }
    
    
    
    init?(record: CKRecord) {
        guard let text = record[Message.textKey] as? String,
            timestamp = record[Message.timestampKey] as? NSDate,
            threadReference = record[Message.threadReferenceKey] as? CKReference,
            senderReference = record[Message.senderReferenceKey] as? CKReference else {
                print("Could not initialze Message with CKRecord")
                return nil
        }
        
        self.text = text
        self.timestamp = timestamp
        
        Message.cloudKitManager.fetchRecordWithID(threadReference.recordID) { (record, error) in
            if let record = record, let thread = Thread(record: record) {
                Message.threadReference = thread
            } else {
            print("Could Not retreive thread from CKreference for Message")
            }
        }
        
          Message.cloudKitManager.fetchRecordWithID(senderReference.recordID) { (record, error) in
            if let record = record, sender = User(record: record) {
                Message.senderReference = sender
            }
        }
        
        self.sender = Message.senderReference!
        self.thread = Message.threadReference!
        self.record = record
        
    }
    
    
    
    
    
}