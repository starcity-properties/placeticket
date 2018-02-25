//
//  Ticket.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/24/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import Foundation

class Ticket {
  
  var id: String
  var content: String
  var x: Float
  var y: Float
  var z: Float
  var mapId: String
  var status: Status
  
  enum Status: String {
    case Pending = "pending"
    case InProgress = "in-progress"
    case Resolved = "resolved"
  }
  
  init(id: String, content: String, x: Float, y: Float, z: Float, mapId: String, status: Status = .Pending) {
    self.id = id
    self.content = content
    self.x = x
    self.y = y
    self.z = z
    self.mapId = mapId
    self.status = status
  }
  
  static func observe(map: Map, cb: @escaping (Ticket) -> ()) {
    DatabaseManager.instance.ref.child("map-tickets/\(map.id)").observe(.childAdded) { (snapshot) in
      let value = snapshot.value as? NSDictionary
      let content = value!["content"] as? String ?? ""
      let x = value!["x"] as? Float ?? 0
      let y = value!["y"] as? Float ?? 0
      let z = value!["z"] as? Float ?? 0
      let status = Status(rawValue: value!["status"] as? String ?? "pending")!
      cb(Ticket(id: snapshot.key, content: content, x: x, y: y, z: z, mapId: map.id, status: status))
    }
  }
  
  static func create(map: Map, content: String, x: Float, y: Float, z: Float) {
    let key = DatabaseManager.instance.ref.child("tickets").childByAutoId().key
    let ticket = Ticket(id: key, content: content, x: x, y: y, z: z, mapId: (map.id))
    let updates = ["/tickets/\(key)": ticket.createData(),
                   "/map-tickets/\(map.id)/\(key)": ticket.createData()]
    DatabaseManager.instance.ref.updateChildValues(updates)
  }
  
  func statusColor() -> UIColor {
    switch status {
    case .Pending:
      return blueColor()
    case .InProgress:
      return yellowColor()
    case .Resolved:
      return UIColor.green
    }
  }
  
  private func createData() -> [String: Any] {
    return [
      "id": self.id,
      "content": self.content,
      "x": self.x,
      "y": self.y,
      "z": self.z,
      "mapId": self.mapId,
      "status": self.status.rawValue
    ]
  }
  
}

