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
    @IBOutlet var startButton: UIButton!
    @IBOutlet var noPlayersLabel: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!

    var viewModel: LobbyViewModel!
    var playerList = [ConnectedPlayer]()
    var readyTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readyTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            self.pollIsReady()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readyTimer.fire()
    }

    @IBAction func ready() {
        viewModel?.toggleReady()
        
    }
    
    @IBAction func start() {
        viewModel?.startGame()
    }
    
    @IBAction func back() {
        _ = self.navigationController?.popViewController(animated: true)
        viewModel?.exitLobby()
    }
    
    func pollIsReady() {
        Networking.isReady(playerId: viewModel.playerId!,isReadied:viewModel.isReady , success: { (response) in
            
            if response.gameState == .ready {
                //TODO: Segue to game play view controller
            } else {
                self.updatePlayersList(playerList: response.players)
            }
        }, failure: { (error) in
            
        })
    }
}

extension LobbyViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConnectedPlayerTableViewCell.reuseId, for: indexPath) as? ConnectedPlayerTableViewCell {
            let player = playerList[indexPath.row]
            cell.nameLabel.text = player.name
            cell.readyImageView.isHidden = !player.isReady
            cell.containerView.backgroundColor = player.color.withAlphaComponent(0.6)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension LobbyViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3 // hack
        return CGSize(width: width, height: width)
    }
}

extension LobbyViewController: LobbyViewModelDelegate {
    
    func updatePlayersList(playerList: [ConnectedPlayer]) {
        spinner.stopAnimating()
        noPlayersLabel.isHidden = playerList.count > 0
        self.playerList = playerList
        collectionView.reloadData()
        startButton.isEnabled = playerList.filter({ $0.isReady }).count == playerList.count
    }
    
    func updateReadyButton(isReady: Bool) {
        if isViewLoaded {
            if isReady {
                readyButton.setBackgroundImage(#imageLiteral(resourceName: "background-green"), for: .normal)
                readyButton.setTitle("Unready", for: .normal)
            } else {
                readyButton.setBackgroundImage(#imageLiteral(resourceName: "background-grey"), for: .normal)
                readyButton.setTitle("Ready", for: .normal)
            }
        }
    }
}
