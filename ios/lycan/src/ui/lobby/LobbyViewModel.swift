//
//  ReadyViewModel.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

protocol LobbyViewModelDelegate: class {
    func updatePlayersList(playerList: [ConnectedPlayer])
    func updateReadyButton(isReady: Bool)
}

class LobbyViewModel {
    
    private(set) weak var delegate: LobbyViewModelDelegate?
    private(set) var isReady: Bool = false
    private(set) var playerList = [ConnectedPlayer]()
    private(set) var isLoading = true
    
    init(delegate: LobbyViewModelDelegate) {
        self.delegate = delegate
        
        delegate.updateReadyButton(isReady: isReady)
        
        // TODO: Replace the below: make API call to get players and update playerList
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.isLoading = false
            let player1 = ConnectedPlayer(name: "Dave", color: UIColor.red)
            player1.isReady = true
            let player2 = ConnectedPlayer(name: "George", color: UIColor.red)
            player2.isReady = true
            let player3 = ConnectedPlayer(name: "Neil", color: UIColor.red)
            player3.isReady = true
            let player4 = ConnectedPlayer(name: "Tree", color: UIColor.red)
            player4.isReady = true
            self.delegate?.updatePlayersList(playerList: [player1, player2, player3, player4])
        }
    }
    
    func toggleReady() {
        // Do API Call
        
        isReady = !isReady
        delegate?.updateReadyButton(isReady: isReady)
    }
    
    func startGame() {
        // TODO: Make API call to exit game
    }
    
    func exitLobby() {
        // TODO: Make API call to exit game
    }
}
