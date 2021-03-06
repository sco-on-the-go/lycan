//
//  JoinGameResponse.swift
//  lycan
//
//  Created by George Smith on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//
import Foundation



class JoinGameResponse {
    var gameId: String!
    var playerId: String!
}

class HostGameResponseModel {
    var gameId: String!
}

class GameStateResponse {
    var gameState: GameState!
    var players: [ConnectedPlayer] = []
    var playerType: PlayerType!
    
    func findPlayer(_ playerId:String) -> ConnectedPlayer? {
        return players.filter({ $0.id == playerId }).first
    }
}

class VoteResponse {
    var werewolvesWon: Bool!
    var everyoneVoted: Bool!
    var players: [ConnectedPlayer]! = []
}

enum GameState: Int {
    case lobby = 1
    case playing = 2
    case vote = 3
    case gameover = 4
    
    func name() -> String {
        if self == .lobby {
            return "Waiting..."
        } else if self == .playing {
            return "The Game is afoot!"
        } else if self == .vote {
            return "Time to vote!"
        } else {
            return "Game over!"
        }
    }
}

enum PlayerType: Int {
    case werewolf = 1
    case seer = 2
    case troublemaker = 3
    case robber = 4
    case villager = 5
}
