//
//  JoinViewController.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var gameTextField: UITextField!
    @IBOutlet var hostButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func nameValueChanged() {
        guard let nameText = nameTextField.text else {
            return
        }
        
        hostButton.isEnabled = nameText.characters.count > 0
        
        guard let gameText = gameTextField.text else {
            return
        }
        
        joinButton.isEnabled = nameText.characters.count > 0 && gameText.characters.count > 0
    }
    
    @IBAction func gameValueChanged() {
        guard let nameText = nameTextField.text else {
            return
        }
        guard let gameText = gameTextField.text else {
            return
        }
                
        joinButton.isEnabled = nameText.characters.count > 0 && gameText.characters.count > 0
    }
    
    @IBAction func host() {
        // Call API
        Networking.hostGame(gameName: gameTextField.text!,playerName: nameTextField.text!, success: {(response) in
            PersistenceHelper.get.playerId = response.playerId
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LobbyViewController") as? LobbyViewController {
                vc.viewModel = LobbyViewModel(delegate: vc,playerId: response.playerId)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }, failure: {(error) in
            
        })
    }

    @IBAction func join() {
        // Call API
        Networking.joinGame(playerName: nameTextField.text!, gameName: gameTextField.text!, success: { (response) in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LobbyViewController") as? LobbyViewController {
                vc.viewModel = LobbyViewModel(delegate: vc,playerId: response.playerId)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }, failure:{ (error) in
            
        })
    }
}
