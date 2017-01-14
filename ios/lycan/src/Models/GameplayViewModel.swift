//
//  GameplayViewModel.swift
//  lycan
//
//  Created by Tristan Warner-Smith on 14/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import Foundation

protocol GameplayStateChanged : class {
    func phaseChangedTo(phase:GameState)
    func stateChanged()
}

protocol GameplayAction : class {
    func canPerformActionForPlayer(_ player:Player) -> Bool
    func playActionForPlayer(_ player:Player)
}

enum GameplayActionType {
    case Nothing
}

class GameplayViewModel {
    static let get = GameplayViewModel()
    
    var currentPlayerId : String?
    var gameState : GameStateResponse? {
        didSet {
            if let delegate = stateNotifyDelegate {
                delegate.stateChanged()
            }
        }
    }
    weak var stateNotifyDelegate : GameplayStateChanged?
    
    private init() {
        refresh()
    }
    
    func refresh() {
        //TODO: Reload data via a network response. Probably needs a game Id and player Id?
        let fakeState = GameStateResponse()
        fakeState.gameState = GameState.playing
        fakeState.players = [
            Player(name:"George", id:UUID().uuidString, isReady:true, isNPC:false, playerType:PlayerType.robber),
            Player(name:"Dave", id:UUID().uuidString, isReady:true, isNPC:false, playerType:PlayerType.seer),
            Player(name:"Neil", id:UUID().uuidString, isReady:true, isNPC:false, playerType:PlayerType.werewolf),
            Player(name:"Tristan", id:UUID().uuidString, isReady:true, isNPC:false, playerType:PlayerType.troublemaker),
            Player(name:"Burf", id:UUID().uuidString, isReady:true, isNPC:false, playerType:PlayerType.villager),
            Player(name:"Card 1", id:UUID().uuidString, isReady:true, isNPC:true, playerType:PlayerType.villager),
            Player(name:"Card 2", id:UUID().uuidString, isReady:true, isNPC:true, playerType:PlayerType.villager),
            Player(name:"Card 3", id:UUID().uuidString, isReady:true, isNPC:true, playerType:PlayerType.werewolf),
        ]
        if let somePlayer = fakeState.players.first {
            fakeState.playerType = somePlayer.playerType
            self.currentPlayerId = somePlayer.id
        }
        
        gameState = fakeState
    }
}

extension GameplayViewModel : GameplayAction {
    func canPerformActionForPlayer(_ player: Player) -> Bool {
        //TODO: Control the logic of whether it's your turn, the player isn't you, if you've already done the thing and whether you're deselecting (if part of a multiselect operation)
        return true
    }
    
    func playActionForPlayer(_ player: Player) {
        //TODO: Determine valid state changes, network calls required, UI changes etc.
    }
}

extension GameplayViewModel {
    func numberOfPlayers() -> Int {
        if let state = self.gameState {
            return state.players.count
        }
        return 0
    }
    
    func playerAtIndex(_ index:Int) -> Player {
        if let state = self.gameState {
            return state.players[index]
        } else {
            //NOTE: Never gonna happen, right?
            return Player()
        }
    }
}
