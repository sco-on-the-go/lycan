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
    
    init(json:[String:Any]) {
        
        if let playerId = json["PlayerId"] as? String {
            self.id = playerId
        }
        if let name = json["Name"] as? String {
            self.name = name
        }
        if let ready = json["IsReady"] as? Bool {
            self.isReady = ready
        }
        if let npc = json["IsNPC"] as? Bool {
            self.isNPC = npc
        }
        if let type = json["PlayerType"] as? Int {
            self.playerType = PlayerType(rawValue: type)
        }
        if let colourSat = json["ColourSaturation"] as? Double {
            self.colourSaturation = CGFloat(colourSat)
        }
        if let colourHue = json["ColourHue"] as? Double {
            self.colourHue = CGFloat(colourHue)
        }
        if let colourBright = json["ColourBrightness"] as? Double {
            self.colourBrightness = CGFloat(colourBright)
        }
    }
    
    func updateColour() {
        color = UIColor(hue: self.colourHue, saturation: self.colourSaturation, brightness: self.colourBrightness, alpha: 1.0)
    }
    
    
}
