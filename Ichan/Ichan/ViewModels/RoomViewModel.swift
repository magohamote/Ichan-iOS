//
//  RoomViewModel.swift
//  Ichan
//
//  Created by Cédric Rolland on 28.05.18.
//  Copyright © 2018 Cédric Rolland. All rights reserved.
//

import Foundation

protocol RoomViewModelDelegate: class {
    func didReceiveLastRoomNumber(lastRoomNumber: Int)
    func didCreateRoom(lastRoomNumber: Int)
    func didFailGettingLastRoomNumber(error: Error)
    func didFailCreatingRoom(error: Error)
}

class RoomViewModel {
    
    weak var delegate: RoomViewModelDelegate?
    
    internal var service = Service()
    
    func getLastRoomNumber() {
        service.getLastRoomNumber(completion: getLastRoomNumber)
    }
    
    func createRoom() {
        service.createRoom(completion: createRoom)
    }
    
    private func getLastRoomNumber(withResponse response: Int?, error: Error?) {
        guard let response = response else {
            if let error = error {
                delegate?.didFailGettingLastRoomNumber(error: error)
            } else {
                delegate?.didFailGettingLastRoomNumber(error: FormatError.badFormatError)
            }
            return
        }
        
        delegate?.didReceiveLastRoomNumber(lastRoomNumber: response)
    }
    
    private func createRoom(withResponse response: Int?, error: Error?) {
        guard let response = response else {
            if let error = error {
                delegate?.didFailCreatingRoom(error: error)
            } else {
                delegate?.didFailCreatingRoom(error: FormatError.badFormatError)
            }
            return
        }
        
        delegate?.didCreateRoom(lastRoomNumber: response)
    }
}
