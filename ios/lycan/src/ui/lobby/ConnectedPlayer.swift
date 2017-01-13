//
//  ConnectedPlayer.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class ConnectedPlayer {
    private(set) var name: String
    private(set) var color: UIColor
    var isReady: Bool = false

    init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
}
