//
//  ConnectedPlayer.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class ConnectedPlayer {
    let name: String
    let id: String
    var isReady: Bool
    let isNPC: Bool
    let playerType: PlayerType
    
    convenience init?(json:[String:Any]) {
        guard let playerName = json["Name"] as? String,
            let playerId = json["PlayerId"] as? String,
            let playerIsReady = json["IsReady"] as? Bool,
            let playerIsNPC = json["IsNPC"] as? Bool,
            let type = json["PlayerType"] as? Int,
            let playerType = PlayerType(rawValue: type) else {
            return nil
        }
        
        self.init(name: playerName, id: playerId, isReady: playerIsReady, isNPC: playerIsNPC, playerType: playerType)
    }
    
    convenience init() { self.init(name: "", id: "", isReady: true, isNPC: false, playerType: PlayerType.villager) }
    
    init(name:String, id:String, isReady:Bool, isNPC:Bool, playerType:PlayerType) {
        self.name = name
        self.id = id
        self.isReady = isReady
        self.isNPC = isNPC
        self.playerType = playerType
    }
}
