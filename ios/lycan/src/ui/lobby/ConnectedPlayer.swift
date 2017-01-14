//
//  ConnectedPlayer.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class ConnectedPlayer {
    private(set) var color: UIColor!
    
    var name: String!
    var id: String!
    var isReady: Bool!
    var isNPC: Bool!
    var playerType: PlayerType!
    
    var colourHue: CGFloat!
    var colourSaturation: CGFloat!
    var colourBrightness: CGFloat!
    
    init() {
    }
    
    func uodateColour() {
        color = UIColor(hue: self.colourHue, saturation: self.colourSaturation, brightness: self.colourBrightness, alpha: 1.0)
    }
    
}
