//
//  ConnectedPlayer.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class ConnectedPlayer {
    private(set) var color: UIColor
    
    var name: String!
    var id: String!
    var isReady: Bool!
    var isNPC: Bool!
    var playerType: PlayerType!
    
    init(color: UIColor) {
        self.color = color
    }
}
