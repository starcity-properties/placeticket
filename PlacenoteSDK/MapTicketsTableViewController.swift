//
//  MapTicketsTableViewController.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/24/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import UIKit

class MapTicketsTableViewController: UITableViewController, CreateTicketViewControllerDelegate {
  
  var map: Map?
  
  private var tickets: [Ticket] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = (map!.name)
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    Ticket.observe(map: self.map!) { (ticket: Ticket) in
      DispatchQueue.main.async {
        self.tickets.append(ticket)
        self.tableView.reloadData()
      }
    }
  }
  
  @IBAction func back(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func newTicket(_ sender: Any) {
    performSegue(withIdentifier: "createTicketSegue", sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.tickets.count
  }
  

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell", for: indexPath)
    let ticket = tickets[indexPath.row]
    cell.textLabel?.text = ticket.content
    // Configure the cell...
    
    return cell
    
  }
  
  func createTicketDidCancel(viewController: CreateTicketViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }

  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "createTicketSegue" {
      let navigationController = segue.destination as! UINavigationController
      let vc = navigationController.topViewController as! CreateTicketViewController
      vc.delegate = self
      vc.map = self.map
    }
  }
  
  
}
