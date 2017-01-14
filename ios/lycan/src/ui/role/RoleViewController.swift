//
//  RoleViewController.swift
//  lycan
//
//  Created by David Taylor on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import UIKit

class RoleViewController: UIViewController {

    @IBOutlet var cardContainerView: UIView!
    @IBOutlet var cardBackButton: UIButton!
    @IBOutlet var cardFrontButton: UIButton!
    @IBOutlet var cardFrontView: UIView!
    @IBOutlet var playerRole: UILabel!
    
    var isShowingRole: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardContainerView.layer.cornerRadius = 20
        cardContainerView.layer.masksToBounds = true
    }
    
    @IBAction func flipCard() {
        cardBackButton.isEnabled = false
        cardFrontButton.isEnabled = false
        if !isShowingRole {
            isShowingRole = true
            UIView.transition(from: cardBackButton, to: cardFrontView, duration: 0.5, options: .transitionFlipFromLeft, completion: { (finished) in
                self.cardContainerView.bringSubview(toFront: self.cardFrontView)
                self.cardBackButton.isEnabled = true
                self.cardFrontButton.isEnabled = true
                print(self.cardBackButton.frame)
            })
        } else {
            isShowingRole = false
            UIView.transition(from: cardFrontView, to: cardBackButton, duration: 0.5, options: .transitionFlipFromLeft, completion: { (finished) in
                self.cardContainerView.bringSubview(toFront: self.cardBackButton)
                self.cardBackButton.isEnabled = true
                self.cardFrontButton.isEnabled = true
                print(self.cardBackButton.frame)
            })
        }
    }
}
