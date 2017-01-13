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
    
    init(delegate: LobbyViewModelDelegate) {
        self.delegate = delegate
        
        delegate.updateReadyButton(isReady: isReady)
    }
    
    func toggleReady() {
        // Do API Call
        
        isReady = !isReady
        delegate?.updateReadyButton(isReady: isReady)
    }
}
