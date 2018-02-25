//
//  CreatePlaceViewController.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/24/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import UIKit

class CreatePlaceViewController: UIViewController, ScanPlaceViewControllerDelegate {
  
  @IBOutlet weak var placeNameField: UITextField!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var scanPlaceButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    scanPlaceButton.isEnabled = false
    placeNameField.addTarget(self, action: #selector(textValueChanged), for: UIControlEvents.editingChanged)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @objc func textValueChanged(_ sender: UITextField) {
    if (sender.text != nil && sender.text != "") {
      scanPlaceButton.isEnabled = true
    } else {
      scanPlaceButton.isEnabled = false
    }
  }
  
  @IBAction func cancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: Any) {
    print ("Save!")
  }
  
  // MARK: - ScanPlaceViewControllerDelegate
  
  func scanPlaceViewControllerDidFinish(viewController: ScanPlaceViewController, mapId: String) {
    Map.create(placenoteId: mapId, name: placeNameField.text!)
    viewController.dismiss(animated: true) {
      self.dismiss(animated: false, completion: nil)
    }
    
  }

  // MARK: - Navigation
   
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "scanPlaceSegue" {
      let navigationController = segue.destination as! UINavigationController
      (navigationController.topViewController as! ScanPlaceViewController).delegate = self
    }
    
  }
  
}
