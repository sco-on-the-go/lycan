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
    
    convenience init() { self.init(name: "", id: "", isReady: true, isNPC: false, playerType: PlayerType.villager) }
    
    init(name:String, id:String, isReady:Bool, isNPC:Bool, playerType:PlayerType) {
        self.name = name
        self.id = id
        self.isReady = isReady
        self.isNPC = isNPC
        self.playerType = playerType
    }
}
