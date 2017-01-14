//
//  GameplayViewModel.swift
//  lycan
//
//  Created by Tristan Warner-Smith on 14/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import Foundation

protocol GameplayStateChanged : class {
    func phaseChangedTo(phase:GameState, success:Bool?)
    func stateChanged()
}

protocol GameplayAction : class {
    func canPerformActionForPlayer(_ player:ConnectedPlayer) -> Bool
    func playActionForPlayer(_ player:ConnectedPlayer)
}

enum GameplayActionType {
    case Nothing
}

class GameplayViewModel {
    static let get = GameplayViewModel()
    
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
        let currentPlayerId = PersistenceHelper.get.playerId
        Networking.isReady(playerId: currentPlayerId, isReadied:true , success: { (response) in
            self.gameState = response
        }, failure: { (error) in })
    }
}

extension GameplayViewModel : GameplayAction {
    func canPerformActionForPlayer(_ player: ConnectedPlayer) -> Bool {
        //TODO: Control the logic of whether it's your turn, the player isn't you, if you've already done the thing and whether you're deselecting (if part of a multiselect operation)
        return true
    }
    
    func playActionForPlayer(_ player: ConnectedPlayer) {
        //TODO: Determine valid state changes, network calls required, UI changes etc.
        voteForPlayer(playerId: player.id)
    }
    
    private func voteForPlayer(playerId:String) {
        let currentPlayerId = PersistenceHelper.get.playerId
        if let currentPlayer = gameState?.findPlayer(currentPlayerId) {
            Networking.voteForPlayer(playerId: currentPlayerId, voteForPlayerId: playerId, success: { (result) in
                if (!result.everyoneVoted) {
                    self.voteForPlayer(playerId: playerId)
                } else {
                    let youWon = result.werewolvesWon == (currentPlayer.playerType == PlayerType.werewolf)
                    self.stateNotifyDelegate?.phaseChangedTo(phase: GameState.gameover, success: youWon)
                }
            }, failure: {(error) in
                //TODO: Handle errors?
            })
        }
    }
}

extension GameplayViewModel {
    func numberOfPlayers() -> Int {
        if let state = self.gameState {
            return state.players.count
        }
        return 0
    }
    
    func playerAtIndex(_ index:Int) -> ConnectedPlayer {
        if let state = self.gameState {
            return state.players[index]
        } else {
            //NOTE: Never gonna happen, right?
            return ConnectedPlayer()
        }
    }
}
