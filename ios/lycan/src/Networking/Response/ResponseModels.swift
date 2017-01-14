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

class IsReadyResponse {
    var gameState: GameState!
    var players: [Player]! = []
    var playerType: PlayerType!
}

class GameStateResponse {
    var gameState: GameState!
    var players: [Player]! = []
    var playerType: PlayerType!
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

class Player {
    let name: String
    let id: String
    var isReady: Bool
    let isNPC: Bool
    let playerType: PlayerType
    
    convenience init() { self.init(name: "", id: "", isReady: true, isNPC: false, playerType: PlayerType.villager) }
    
    init(name:String, id:String, isReady:Bool, isNPC:Bool, playerType:PlayerType) {
        self.name = name
        self.id = id
        self.isReady = isReady
        self.isNPC = isNPC
        self.playerType = playerType
    }
}
