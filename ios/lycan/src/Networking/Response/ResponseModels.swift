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
    var players: [ConnectedPlayer]! = []
    var playerType: PlayerType!
}

enum GameState: Int {
    case lobby = 1
    case ready = 2
}

enum PlayerType: Int {
    case werewolf = 1
    case seer = 2
    case troublemaker = 3
    case robber = 4
    case villager = 5
}

