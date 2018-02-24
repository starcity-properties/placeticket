//
//  Map.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/24/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import Foundation

class Map {

  var id: String
  var placenoteId: String
  var name: String
  var tickets: [Ticket]
  
  init(id: String, placenoteId: String, name: String, tickets: [Ticket] = []) {
    self.id = id
    self.placenoteId = placenoteId
    self.name = name
    self.tickets = tickets
  }
  
  static func create(id: String, placenoteId: String, name: String) -> Map {
    let key = DatabaseManager.instance.ref.child("maps").childByAutoId().key
    let map = Map(id: key, placenoteId: placenoteId, name: name)
    let updates = ["/maps/\(key)": map.createData()]
    DatabaseManager.instance.ref.updateChildValues(updates)
    return map
  }
  
  static func fetch(id: String, cb: @escaping (Map) -> ()) {
    DatabaseManager.instance.ref.child("maps").observeSingleEvent(of: .value) { (snapshot) in
      var value = snapshot.value as? NSDictionary
      value = value![id] as? NSDictionary
      let placenoteId = value!["placenoteId"] as? String ?? "unknown"
      let name = value!["name"] as? String ?? "unknown"
      // TODO: create tickets
      cb(Map(id: id, placenoteId: placenoteId, name: name))
    }
  }
  
  private func createData() -> [String: Any] {
    return ["placenoteId": self.placenoteId,
            "name": self.name]
  }
  
}
