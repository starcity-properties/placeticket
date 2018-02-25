//
//  ShowExistingTicketViewController.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/25/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import UIKit

protocol ShowExistingTicketViewControllerDelegate {
  func showExistingTicketDidCancel(viewController: ShowExistingTicketViewController)
}

class ShowExistingTicketViewController: UIViewController {
  
  @IBOutlet weak var ticketContentLabepo: UILabel!
  
  var ticket: Ticket!
  var delegate: ShowExistingTicketViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ticketContentLabepo.text = ticket.content
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func done(_ sender: Any) {
    self.delegate?.showExistingTicketDidCancel(viewController: self)
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
