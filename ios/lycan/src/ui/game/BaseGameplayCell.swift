//
//  BaseGameplayCell.swift
//  lycan
//
//  Created by Tristan Warner-Smith on 14/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class BaseGameplayCell : UICollectionViewCell {
    @IBOutlet weak var roleLabel: UILabel!
    weak var interactionDelegate : GameplayAction?
    var player:ConnectedPlayer?
    
    func populate(_ player:ConnectedPlayer, interactionDelegate:GameplayAction) {
        self.layer.cornerRadius = 50
        
        self.player = player
        self.interactionDelegate = interactionDelegate
    }
    
    @IBAction func interact() {
        if let delegate = interactionDelegate,
            let player = player {
            if delegate.canPerformActionForPlayer(player) {
                //TODO: Figure out if it should be possible to do something now by asking
                //TODO: Animate the things you know here
                delegate.playActionForPlayer(player)
            }
        }
    }
}
