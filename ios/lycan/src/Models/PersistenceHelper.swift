//
//  PersistenceHelper.swift
//  lycan
//
//  Created by Tristan Warner-Smith on 14/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

import Foundation

class PersistenceHelper {
    static let get = PersistenceHelper()
    
    private init() {}
    
    var playerId : String = "" {
        didSet {
            let defaults = UserDefaults()
            defaults.set(playerId, forKey:"PlayerId")
        }
    }
}
