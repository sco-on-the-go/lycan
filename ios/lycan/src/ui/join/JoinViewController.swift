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
    @IBOutlet var joinButton: UIButton!
    
    @IBAction func nameValueChanged() {
        guard let text = nameTextField.text else {
            return
        }
        
        joinButton.isEnabled = text.characters.count > 0
    }
    
    @IBAction func join() {
        
    }
}
