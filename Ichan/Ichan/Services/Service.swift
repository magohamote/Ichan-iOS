//
//  Service.swift
//  Ichan
//
//  Created by Cédric Rolland on 28.05.18.
//  Copyright © 2018 Cédric Rolland. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Service {
    
    private var firebaseReference = Database.database().reference()
    
    func getLastRoomNumber(completion: @escaping (_ response: Int?, _ error: Error?) -> Void) {
        firebaseReference.child("last_room_code").observe(DataEventType.value, with: {(_ snapshot: DataSnapshot?) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if let value = snapshot?.value as? Int {
                    completion(value, nil)
                } else {
                    completion(nil, FormatError.badFormatError)
                }
            })
        })
        return
    }
    
    func createRoom(completion: @escaping (_ response: Int?, _ error: Error?) -> Void) {
        firebaseReference.child("last_room_code").runTransactionBlock({(_ currentData: MutableData?) -> TransactionResult in
            let roomNumber = currentData?.value as? Int
            var roomNumberInt = 0
            if roomNumber != nil {
                roomNumberInt = Int(roomNumber!)
            }
            roomNumberInt += 1
            let timestampInteger = Int64(Date().timeIntervalSince1970 * 1000)
            let timestamp = timestampInteger
            let room = ["display_name": "\(roomNumberInt)", "updated_at_timestamp": timestamp] as [String : Any]
            self.firebaseReference.child("hotspot_list").child("\(roomNumberInt)").setValue(room)
            currentData?.value = roomNumberInt
            return TransactionResult.success(withValue: currentData!)
        }, andCompletionBlock: {(_ error: Error?, _ committed: Bool, _ snapshot: DataSnapshot?) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if error != nil {
                    completion(nil, error)
                } else if let lastRoomNumber = snapshot?.value as? Int {
                    completion(lastRoomNumber, nil)
                }
            })
        })
    }
}
