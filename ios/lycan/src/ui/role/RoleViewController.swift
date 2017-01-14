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
        
        cardFrontView.layer.cornerRadius = 20
        cardFrontView.layer.masksToBounds = true
        cardBackButton.layer.cornerRadius = 20
        cardBackButton.layer.masksToBounds = true
    }
    
    @IBAction func flipCard() {
        cardBackButton.isEnabled = false
        cardFrontButton.isEnabled = false
        if !isShowingRole {
            isShowingRole = true
            UIView.transition(from: cardBackButton, to: cardFrontView, duration: 0.7, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: { (finished) in
                self.cardContainerView.bringSubview(toFront: self.cardFrontView)
                self.cardBackButton.isEnabled = true
                self.cardFrontButton.isEnabled = true
            })
        } else {
            isShowingRole = false
            UIView.transition(from: cardFrontView, to: cardBackButton, duration: 0.4, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: { (finished) in
                self.cardContainerView.bringSubview(toFront: self.cardBackButton)
                self.cardBackButton.isEnabled = true
                self.cardFrontButton.isEnabled = true
            })
        }
    }
}
