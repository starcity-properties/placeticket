//
//  TicketDetailViewController.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/25/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

protocol TicketDetailViewControllerDelegate {
  func ticketDetailDone(viewController: TicketDetailViewController)
  func ticketDetailTickets(viewController: TicketDetailViewController) -> [Ticket]
}

class TicketDetailViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, PNDelegate, ShowExistingTicketViewControllerDelegate {
  
  @IBOutlet weak var scnView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  
  var map: Map?
  var selectedTicket: Ticket?
  //  var tickets: [Ticket] = []
  
  // Delegate
  var delegate: TicketDetailViewControllerDelegate?
  
  // AR Scene
  private var scnScene: SCNScene!
  private var actualScnView: SCNView!
  
  //Status variables to track the state of the app with respect to libPlacenote
  private var trackingStarted: Bool = false;
  private var mappingStarted: Bool = false;
  private var mappingComplete: Bool = false;
  private var localizationStarted: Bool = false;
  
  
  private var shapeManager: ShapeManager!
  private var tapRecognizer: UITapGestureRecognizer? //initialized after view is loaded
  private var tapRec: UITapGestureRecognizer? //initialized after view is loaded
  
  
  // PlacenoteSDK features & helpers
  private var camManager: CameraManager? = nil;
  private var ptViz: FeaturePointVisualizer? = nil;
  private var showFeatures: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    setupScene()
    
    shapeManager = ShapeManager(map: map!, scene: scnScene, view: scnView)
    // start tap gestures disabled to wait for placenote to warm up
    tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    tapRecognizer!.numberOfTapsRequired = 1
    tapRecognizer!.isEnabled = false
    scnView.addGestureRecognizer(tapRecognizer!)
    tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
    actualScnView.addGestureRecognizer(tapRec!)
    
    // set Placenote delegate
    LibPlacenote.instance.multiDelegate.addDelegate(delegate: self)
    
    statusLabel.text = "Retrieving mapId: " + map!.placenoteId
    
  }
  
  @IBAction func reloadMap(_ sender: Any) {
    loadMap(map: self.map!, tickets: self.delegate!.ticketDetailTickets(viewController: self))
  }
  
  func loadMap(map: Map, tickets: [Ticket]) {
    if LibPlacenote.instance.getMappingStatus() == .running {
      LibPlacenote.instance.stopSession()
    }
    print ("LOADING MAP", tickets, map)
    LibPlacenote.instance.loadMap(
      mapId: map.placenoteId,
      downloadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
        print (completed, faulted, percentage)
        if (completed) {
          self.mappingStarted = false
          self.mappingComplete = false
          self.localizationStarted = true
          self.statusLabel.text = "Map Loaded. Look Around"
          self.shapeManager.loadShapes(tickets: tickets)
          LibPlacenote.instance.startSession()
          self.tapRecognizer?.isEnabled = true
        } else if (faulted) {
          print ("Couldnt load map: " + self.map!.id)
          self.statusLabel.text = "Load error Map Id: " +  self.map!.id
        } else {
          print ("Progress: " + percentage.description)
        }
    }
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = ARWorldTrackingConfiguration.WorldAlignment.gravity //TODO: Maybe not heading?
    
    // Run the view's session
    scnView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    scnView.session.pause()
  }
  
  //Function to setup the view and setup the AR Scene including options
  func setupView() {
    actualScnView = self.scnView as! SCNView
    scnView.showsStatistics = true
    scnView.autoenablesDefaultLighting = true
    scnView.delegate = self
    scnView.session.delegate = self
    scnView.isPlaying = true
    scnView.debugOptions = []
    
    //    scnView.debugOptions = ARSCNDebugOptions.showFeaturePoints
    //    scnView.debugOptions = ARSCNDebugOptions.showWorldOrigin
  }
  
  //Function to setup AR Scene
  func setupScene() {
    scnScene = SCNScene()
    scnView.scene = scnScene
    ptViz = FeaturePointVisualizer(inputScene: scnScene);
    ptViz?.enableFeaturePoints()
    
    if let camera: SCNNode = scnView?.pointOfView {
      camManager = CameraManager(scene: scnScene, cam: camera)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scnView.frame = view.bounds
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - ShowExistingViewControllerTicketWhatverDlglags
  
  func showExistingTicketDidCancel(viewController: ShowExistingTicketViewController) {
    viewController.dismiss(animated: true, completion: nil)
    loadMap(map: self.map!, tickets: self.delegate!.ticketDetailTickets(viewController: self))
  }
  
  // MARK: - PNDelegate functions
  
  //Receive a pose update when a new pose is calculated
  func onPose(_ outputPose: matrix_float4x4, _ arkitPose: matrix_float4x4) -> Void {
    
  }
  
  //Receive a status update when the status changes
  func onStatusChange(_ prevStatus: LibPlacenote.MappingStatus, _ currStatus: LibPlacenote.MappingStatus) {
    print ("Previous status: \(prevStatus), current Status: \(currStatus)")
    if prevStatus != LibPlacenote.MappingStatus.running && currStatus == LibPlacenote.MappingStatus.running {
      print ("Just localized, drawing view")
      shapeManager.drawView(parent: scnScene.rootNode) // just localized, redraw shapes
      
      if mappingStarted {
        statusLabel.text = "Tap to add a marker, move slowly"
      } else if localizationStarted {
        statusLabel.text = "map found!"
      }
      tapRecognizer?.isEnabled = true
    }
    
    if prevStatus == LibPlacenote.MappingStatus.running && currStatus != LibPlacenote.MappingStatus.running { //just lost localization
      print ("Just lost localization")
      if mappingStarted {
        statusLabel.text = "Moved too fast. Map Lost"
      }
      tapRecognizer?.isEnabled = false
    }
  }
  
  // MARK: - ARSCNViewDelegate
  
  // Override to create and configure nodes for anchors added to the view's session.
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    let node = SCNNode()
    return node
  }
  
  
  // MARK: - ARSessionDelegate
  
  //Provides a newly captured camera image and accompanying AR information to the delegate.
  func session(_ session: ARSession, didUpdate: ARFrame) {
    let image: CVPixelBuffer = didUpdate.capturedImage
    let pose: matrix_float4x4 = didUpdate.camera.transform
    
    if (!LibPlacenote.instance.initialized()) {
      print("SDK is not initialized")
      return
    }
    
    if (mappingStarted || localizationStarted) {
      LibPlacenote.instance.setFrame(image: image, pose: pose)
    }
  }
  
  
  //Informs the delegate of changes to the quality of ARKit's device position tracking.
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    var status = "Loading.."
    switch camera.trackingState {
    case ARCamera.TrackingState.notAvailable:
      status = "Not available"
    case ARCamera.TrackingState.limited(_):
      status = "Initializing ARKit.."
    case ARCamera.TrackingState.normal:
      if (!trackingStarted) {
        print ("Tracking started")
        trackingStarted = true
        if (!mappingStarted) {
          print ("Mapping started")
          mappingStarted = true
          loadMap(map: self.map!, tickets: self.delegate!.ticketDetailTickets(viewController: self))
        }
      }
      status = "Ready"
    }
    statusLabel.text = status
  }
  
  // MARK: - UI Control Handlers
  
  @IBAction func done(_ sender: Any) {
    LibPlacenote.instance.stopSession()
    LibPlacenote.instance.multiDelegate.removeDelegate(delegate: self)
    self.delegate?.ticketDetailDone(viewController: self)
  }
  
  @objc func handleTap(sender: UITapGestureRecognizer) {
    
    // let tapLocation = sender.location(in: scnView)
    // let hitTestResults = scnView.hitTest(tapLocation, types: .featurePoint)
    
    
    // if let result = hitTestResults.first {
    //   let pose = LibPlacenote.instance.processPose(pose: result.worldTransform)
    //   shapeManager.placeIcon(position: pose.position())
    
    //   for shapeNode in shapeManager.shapeNodes {
    //     if (detectCollision(first: shapeNode.position, second: pose.position())) {
    //       print ("PRINT ---------------------------------------------- collision!")
    //     }
    //   }
    
    if sender.state == .ended {
      let location = sender.location(in: actualScnView)
      let hits = actualScnView.hitTest(location, options: nil)
      
      if !hits.isEmpty && hits.first?.node.geometry?.materials != nil {
        if let tappedNode = hits.first?.node {
          if let ticket = shapeManager.getTicket(position: tappedNode.position) {
            selectedTicket = ticket
            LibPlacenote.instance.stopSession()
            performSegue(withIdentifier: "showExistingTicket", sender: self)
          } else {
            print ("Ticket not found.")
          }
        }
      }
    }
  }
  
  //  @objc func handleTap(sender: UITapGestureRecognizer) {
  //    if sender.state == .ended {
  //      let tapLocation = sender.location(in: scnView)
  //      let hitTestResults = scnView.hitTest(tapLocation, types: .featurePoint)
  //
  //      if let result = hitTestResults.first {
  //        let pose = LibPlacenote.instance.processPose(pose: result.worldTransform)
  //        shapeManager.placeIcon(position: pose.position())
  //      }
  //    }
  //  }
  
  //  @IBAction func done(_ sender: Any) {
  //    //    self.dismiss(animated: true, completion: nil)
  //    LibPlacenote.instance.saveMap(savedCb: { (mapId: String?) in
  //      if (mapId != nil) {
  //        LibPlacenote.instance.stopSession()
  ////        self.delegate?.scanPlaceViewControllerDidFinish(viewController: self, mapId: mapId!)
  //      } else {
  //        NSLog("Failed to save map")
  //      }
  //    }) { (completed, faulted, percentage) in
  //      if (completed) {
  //        print ("Uploaded!")
  //      } else if (faulted) {
  //        print ("Couldnt upload map")
  //      } else {
  //        print ("Progress: " + percentage.description)
  //      }
  //    }
  //
  //  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "showExistingTicket" {
      let navigationController = segue.destination as! UINavigationController
      let vc = navigationController.topViewController as! ShowExistingTicketViewController
      vc.delegate = self
      vc.ticket = self.selectedTicket
      //      vc.map = self.map
    }
  }
  
  
}
