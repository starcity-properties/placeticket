//
//  DatabaseManager.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/24/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DatabaseManager {
  
  static let instance = DatabaseManager()
  
  let ref: DatabaseReference!
  
  private init() {
    self.ref = Database.database().reference()
  }
}
