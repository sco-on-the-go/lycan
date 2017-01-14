//
//  GameViewController.swift
//  lycan
//
//  Created by Tristan Warner-Smith on 14/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class GameViewController : UIViewController {
    @IBOutlet weak var gamePhaseLabel: UILabel!
    @IBOutlet weak var playersCollectionView: UICollectionView!
    @IBOutlet weak var actionButton: UIButton!
    
    var model = GameplayViewModel.get
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.stateNotifyDelegate = self
        
        model.refresh()
    }
}

extension GameViewController : GameplayStateChanged {
    func phaseChangedTo(phase: GameState, success:Bool? = nil) {
        if let result = success {
            self.gamePhaseLabel.text = phase.name() + (result ? " - You won!" : " - You lost")
        } else {
            self.gamePhaseLabel.text = phase.name()
        }
    }
    
    func stateChanged() {
        updatePhase()
        playersCollectionView.reloadData()
    }
    
    private func updatePhase() {
        if self.gamePhaseLabel.text != model.gameState?.gameState.name() {
            UIView.animate(withDuration: 0.25, animations: { 
                self.gamePhaseLabel.text = self.model.gameState?.gameState.name()
            })
        }
    }
}

extension GameViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfPlayers()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let player = model.playerAtIndex(indexPath.row)
        if (player.isNPC) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardView", for: indexPath) as! CardViewCell
            cell.populate(player, interactionDelegate:self.model)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerCardView", for: indexPath) as! PlayerViewCell
            cell.populate(player, interactionDelegate:self.model)
            
            return cell
        }
    }
}
