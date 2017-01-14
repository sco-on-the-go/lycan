//
//  ReadyViewController.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {

    let toRoleSegue = "toRoleSegue"
    
    @IBOutlet var readyButton: UIButton!
    @IBOutlet var noPlayersLabel: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!

    var viewModel: LobbyViewModel!
    var playerList = [ConnectedPlayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pollServer()
    }
    
    @IBAction func ready() {
        viewModel?.toggleReady()
    }
    
    @IBAction func back() {
        _ = self.navigationController?.popViewController(animated: true)
        viewModel?.exitLobby()
    }
    
    func pollServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pollIsReady()
        }
    }
    
    func pollIsReady() {
        Networking.isReady(playerId: viewModel.playerId!,isReadied:viewModel.isReady , success: { (response) in
            
            self.updatePlayersList(playerList: response.players)

            if response.gameState == GameState.playing {
                self.showCoolNumbersAnimation(completion: {
                    self.performSegue(withIdentifier: self.toRoleSegue, sender: self)
                })
            } else {
                self.pollServer()
            }
        }, failure: { (error) in
            
        })
    }
    
    func showCoolNumbersAnimation(completion: @escaping () -> ()) {
        // Numbers count down: 3, 2, 1, G0!, but they swish in in a fancy style. Starting of big, they scale down to small before disappearing
        zoomInLabel(text: "3", completion: {
            self.zoomInLabel(text: "2", completion: {
                self.zoomInLabel(text: "1", completion: {
                    self.zoomInLabel(text: "GO!", completion: {
                        completion()
                    })
                })
            })
        })
    }
    
    func zoomInLabel(text: String, completion: @escaping () -> ()) {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 48.0)
        label.text = text
        label.textColor = UIColor.darkText
        label.shadowColor = UIColor.red
        label.shadowOffset = CGSize(width: 2, height: 1)
        label.center = self.view.center
        self.view.addSubview(label)
        let centerXConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(centerXConstraint)
        let centerYConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(centerYConstraint)
        let widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0)
        label.addConstraint(widthConstraint)
        let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0)
        label.addConstraint(heightConstraint)
        self.view.layoutIfNeeded()

        label.transform = CGAffineTransform(scaleX: 50, y: 50)
        UIView.animate(withDuration: 0.5, animations: {
            label.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { (finished) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                label.removeFromSuperview()
                completion()
            }
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
            //cell.containerView.backgroundColor = player.color.withAlphaComponent(0.6)
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
