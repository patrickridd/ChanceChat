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
                    completion(record: records?.first)
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


    func getRandomUsers(completion: (users: [User])-> Void) {
        fetchUsersBesidesLoggedInUser { (users) in
            
            let rand = Int(arc4random_uniform(UInt32(users.count-1)))
            
            let randomUsers = [users[rand]]
            
            completion(users: randomUsers)
            
            
        }
        
    }
    
    func fetchUsersBesidesLoggedInUser(completion: (users: [User]) ->Void) {
        
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
//          guard let userRecord = record
//            //, currentUser = User(record: userRecord)
//            else {
//                return
//            }
            
            
            
           // let referenceToExclude = CKReference(recordID: userRecord.recordID, action: .None)
            
          //  let predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referenceToExclude])
            let predicate = NSPredicate(value: true)
            
            self.cloudKitManager.fetchRecordsWithType(User.recordType, predicate: predicate, recordFetchedBlock: { (record) in
            
                }, completion: { (records, error) in
                    guard let records = records else {
                        return
                    }
                    
                    let users = records.flatMap({User(record: $0)})
                    print(users[1].username)
                    //print(users[1].username)
                    completion(users: records.flatMap({User(record: $0)}))
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
                    
                }
                completion(users: users)
            }
            
        }
        

        func getUsersFromThread(thread: Thread, completion: (users: [User]) ->Void) {
            var users = [User]()
            
            for reference in thread.userReferences {
                let recordId = reference.recordID
                
                self.cloudKitManager.fetchRecordWithID(recordId, completion: { (record, error) in
                    
                    guard let record = record,
                        user = User(record: record) else {
                            print("Couldn't get record from references recordID")
                            return
                    }
                    users.append(user)
                })
                
            }
            completion(users: users)
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
    
    func checkCloudKit(completion: (signedIn: Bool) -> Void) {
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
            if let error = error  {
                print("error fetching logged in user. Error: \(error.localizedDescription)")
                completion(signedIn: false)
                return
            }
            completion(signedIn: true)
        }
        
        
    }

    
    func checkForUserName(completion: (hasUserName: Bool) -> Void) {
        fetchCustomLoggedInUserRecord { (record) in
            
            guard let record = record else {
                print("custom logged in user record is nil")
                completion(hasUserName: false)
                return
            }
            
            let user = User(record: record)
            if user == nil {
                completion(hasUserName: false)
            }
            
            completion(hasUserName: true)
            
        }

        
        
    }

}









