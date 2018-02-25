//
//  ShapeManager.swift
//  Shape Dropper (Placenote SDK iOS Sample)
//
//  Created by Prasenjit Mukherjee on 2017-10-20.
//  Copyright © 2017 Vertical AI. All rights reserved.
//

import Foundation
import SceneKit

extension String {
  func appendLineToURL(fileURL: URL) throws {
    try (self + "\n").appendToURL(fileURL: fileURL)
  }
  
  func appendToURL(fileURL: URL) throws {
    let data = self.data(using: String.Encoding.utf8)!
    try data.append(fileURL: fileURL)
  }
}


extension Data {
  func append(fileURL: URL) throws {
    if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
      defer {
        fileHandle.closeFile()
      }
      fileHandle.seekToEndOfFile()
      fileHandle.write(self)
    }
    else {
      try write(to: fileURL, options: .atomic)
    }
  }
}

func blueColor() -> UIColor {
//  let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
//  let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.3 // from 0.3 to 1.0 to stay away from white
//  let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.3 // from 0.3 to 1.0 to stay away from black
  
//  return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    return UIColor.blue
}

func yellowColor() -> UIColor {
    return UIColor.yellow
}

func redColor() -> UIColor {
    return UIColor.red
}



//Class to manage a list of shapes to be view in Augmented Reality including spawning, managing a list and saving/retrieving from persistent memory using JSON
class ShapeManager {
  
  private var scnScene: SCNScene!
  private var scnView: SCNView!
  private var map: Map!
  
  private var shapePositions: [SCNVector3] = []
  private var maxShapes: Int = 1
  private var shapeTypes: [ShapeType] = []
  var shapeNodes: [SCNNode] = []
  
  public var shapesDrawn: Bool! = false
  
  
  init(map: Map, scene: SCNScene, view: SCNView) {
    self.map = map
    self.scnScene = scene
    self.scnView = view
  }
  
  func setMaxShapes(max: Int) {
    self.maxShapes = max
  }
  
  func saveShapes() {
    if (shapePositions.count > 0) {
      for i in 0...(shapePositions.count-1) {
        Ticket.create(map: self.map, content: "this is a ticket", x: shapePositions[i].x, y: shapePositions[i].y, z: shapePositions[i].z)
      }
    }
    
  }
  
  //Save JSON File of Shapes with MapID as its name
  func saveFile (filename: String?) {
    guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    var fileUrl: URL
    if let inputFileName = filename {
      fileUrl = documentDirectoryUrl.appendingPathComponent(inputFileName + ".json")
    }
    else {
      fileUrl = documentDirectoryUrl.appendingPathComponent("Shapes.json")
    }
    
    
    var shapeArray: [[String: [String: String]]] = []
    if (shapePositions.count > 0) {
      for i in 0...(shapePositions.count-1) {
        shapeArray.append(["shape": ["style": "\(shapeTypes[i].rawValue)", "x": "\(shapePositions[i].x)",  "y": "\(shapePositions[i].y)",  "z": "\(shapePositions[i].z)" ]])
      }
    }
    
    do {
      let dataOut = try JSONSerialization.data(withJSONObject: shapeArray, options: [])
      try dataOut.write(to: fileUrl, options: [])
    } catch {
      print (error)
      return;
    }
    
  }
  
  func loadShapes(tickets: [Ticket]) {
    clearShapes()
    print ("~~~~~~~~~~~~~~~~~~~~~~~~Loading shapes...\(tickets)~~~~~~~~~~~~~~~~~~~~")
    for ticket in tickets {
      let position: SCNVector3 = SCNVector3(x: ticket.x, y: ticket.y, z: ticket.z)
      shapePositions.append(position)
      print ("Position of \(ticket.id): \(position)")
      shapeNodes.append(createIcon(position: position, color: ticket.statusColor()))
    }
  }
  
  //Retrieve JSON file with a certain mapid name
  func retrieveFromFile(filename: String?) -> Bool {
    guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
    clearShapes() //clear currently viewing shapes and delete any record of them.
    
    var fileUrl: URL
    if let inputFileName = filename {
      fileUrl = documentDirectoryUrl.appendingPathComponent(inputFileName + ".json")
    }
    else {
      fileUrl = documentDirectoryUrl.appendingPathComponent("Shapes.json")
    }
    
    // Read data from .json file and transform data into an array
    do {
      let data = try Data(contentsOf: fileUrl, options: [])
      guard let shapeArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: [String: String]]] else { return false }
      for item in shapeArray {
        
        let x_string: String = item["shape"]!["x"]!
        let y_string: String = item["shape"]!["y"]!
        let z_string: String = item["shape"]!["z"]!
        let position: SCNVector3 = SCNVector3(x: Float(x_string)!, y: Float(y_string)!, z: Float(z_string)!)
        let type: ShapeType = ShapeType(rawValue: Int(item["shape"]!["style"]!)!)!
        shapePositions.append(position)
        shapeNodes.append(createIcon(position: position, color: blueColor()))
        
        print ("Shape Manager: Retrieved " + String(describing: type) + " type at position" + String (describing: position))
      }
    } catch {
      print ("Could not retrieve shape json file")
      print(error)
      return false
    }
    print ("Shape Manager: retrieved " + String(shapePositions.count) + "shapes")
    return true
  }
  
  //Delete JSON File
  func deleteFile (filename: String) {
    let fileManager = FileManager.default
    do {
      try fileManager.removeItem(atPath: filename + ".json")
    }
    catch let error as NSError {
      print("Shape Manager: Couldn't delete \(filename).json because: \(error)")
    }
  }
  
  func clearView() { //clear shapes from view
    for shape in shapeNodes {
      shape.removeFromParentNode()
    }
    shapesDrawn = false
  }
  
  func drawView(parent: SCNNode) {
    print ("~~~~~~~~~~~~~~~~~~~~~~~~~Drawing view...are shapes drawn?\(shapesDrawn)~~~~~~~~~~~~~~~")
    guard !shapesDrawn else {return}
    for shape in shapeNodes {
      parent.addChildNode(shape)
    }
    shapesDrawn = true
  }
  
  func clearShapes() { //delete all nodes and record of all shapes
    clearView()
    for node in shapeNodes {
      node.geometry!.firstMaterial!.normal.contents = nil
      node.geometry!.firstMaterial!.diffuse.contents = nil
    }
    shapeNodes.removeAll()
    shapePositions.removeAll()
    shapeTypes.removeAll()
  }
  

  func placeIcon (position: SCNVector3, color: UIColor = blueColor()) {
    
    if shapeNodes.count < maxShapes {
      let geometryNode: SCNNode = createIcon(position: position, color: color)
      
      //    let camera = self.scnView.pointOfView!
      //    let position = SCNVector3(x: 0, y: 0, z: -1)
      //    geometryNode.position = camera.convertPosition(position, to: nil)
      //    geometryNode.rotation = camera.rotation
      
      //    camera.addChildNode(geometryNode)
      
      //    let cameraNode = self.scnView.pointOfView
      //    print(cameraNode?.position)
      //    geometryNode.eulerAngles.z = 1.5087
      //    let action = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 10)
      //    let repAction = SCNAction.repeatForever(action)
      //    geometryNode.runAction(repAction, forKey: "myrotate")
      
      
      shapePositions.append(position)
      shapeNodes.append(geometryNode)
      
      scnScene.rootNode.addChildNode(geometryNode)
      shapesDrawn = true

    }
  }

  
  func createIcon (position: SCNVector3, color: UIColor) -> SCNNode {
    let exclShape = SCNText(string: "!", extrusionDepth: 0.2)
//    let exclShape2 = SCNTorus(ringRadius: 1.0, pipeRadius: 0.1)
    exclShape.font = UIFont(name: "Helvetica", size: 2)

    
    let exclGeometry:SCNGeometry = exclShape
    exclGeometry.materials.first?.diffuse.contents = color
    
    let exclNode = SCNNode(geometry: exclGeometry)
    exclNode.position = position
    exclNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
  
    return exclNode
  }
  
}
