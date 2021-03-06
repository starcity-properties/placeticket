//
//  PlacesViewControllerTableViewController.swift
//  PlacenoteSDK
//
//  Created by Josh Lehman on 2/24/18.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import UIKit

class PlacesViewControllerTableViewController: UITableViewController {
  
  var maps: [Map] = []
  
  private var selectedMap: Map?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
//    Map.fetch(id: "-L69TJ2Pxr0NBKzojqEf") { (map) in
//      print ("The map name is: \(map.name)")
//    }
//
    Map.observe { (map) in
      DispatchQueue.main.async {
        self.maps.append(map)
        self.tableView.reloadData()
      }
    }
    
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
    return self.maps.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath)
    let map = maps[indexPath.row]
    cell.textLabel?.text = map.name
    // Configure the cell...
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath)
    selectedMap = self.maps[indexPath.row]
    performSegue(withIdentifier: "showMapDetailSegue", sender: self)
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
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "showMapDetailSegue" {
      let navigationController = segue.destination as! UINavigationController
      (navigationController.topViewController as! MapTicketsTableViewController).map = selectedMap
    }
  }
  
  
}
