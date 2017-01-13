//
//  ReadyViewController.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {

    @IBOutlet var readyButton: UIButton!
    
    var viewModel: LobbyViewModel?
    var playerList = [ConnectedPlayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = LobbyViewModel(delegate: self)
    }

    @IBAction func ready() {
        viewModel?.toggleReady()
    }
}

extension LobbyViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension LobbyViewController: LobbyViewModelDelegate {
    
    func updatePlayersList(playerList: [ConnectedPlayer]) {
        
    }
    
    func updateReadyButton(isReady: Bool) {
        if isReady {
            readyButton.setBackgroundImage(#imageLiteral(resourceName: "background-green"), for: .normal)
            readyButton.setTitle("Unready", for: .normal)
        } else {
            readyButton.setBackgroundImage(#imageLiteral(resourceName: "background-grey"), for: .normal)
            readyButton.setTitle("Ready", for: .normal)
        }
    }
}
