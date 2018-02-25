//
//  CreateTicketViewController.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/25/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import UIKit

protocol CreateTicketViewControllerDelegate {
  func createTicketDidCancel(viewController: CreateTicketViewController)
  func createTicketDidFinish(viewController: CreateTicketViewController)
}

class CreateTicketViewController: UIViewController, PlaceTicketLocationViewControllerDelegate {
  
  @IBOutlet weak var textView: UITextView!
  
  var map: Map!
  var delegate: CreateTicketViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - PlaceTicketLocationViewController
  
  func placeTicketDidCancel(viewController: PlaceTicketLocationViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
  
  func placeTicketDidFinish(viewController: PlaceTicketLocationViewController) {
    // TODO: Save text?
    viewController.dismiss(animated: true, completion: nil)
    self.delegate?.createTicketDidFinish(viewController: self)
  }

   // MARK: - Navigation
   
  @IBAction func cancelCreateTicket(_ sender: Any) {
    self.delegate?.createTicketDidCancel(viewController: self)
  }
  
  @IBAction func addLocation(_ sender: Any) {
    performSegue(withIdentifier: "showPlaceTicketLocationSegue", sender: self)
  }

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "showPlaceTicketLocationSegue" {
      let navigationController = segue.destination as! UINavigationController
      let vc = navigationController.topViewController as! PlaceTicketLocationViewController
      vc.delegate = self
      vc.map = self.map
      vc.content = self.textView.text
    }
  }
  
  
}
