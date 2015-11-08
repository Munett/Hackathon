//
//  AppDelegate.swift
//  MyPass
//
//  Created by Alejandro De la Rosa Cortés on 08/11/15.
//

import UIKit
import CoreData

class ResultsTableViewController: UITableViewController
{
  // Retreive the managedObjectContext from AppDelegate
  let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  var arrPassports = Array<Passport>()
  
  //-------------------------------------------------------------------------------------------------
  override func viewDidLoad()
  {
    super.viewDidLoad()
    fetchLog()
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
  
  //-------------------------------------------------------------------------------------------------
  func fetchLog()
  {
    let fetchRequest = NSFetchRequest(entityName: "Passport")
    
    // Create a sort descriptor object that sorts on the "title"
    // property of the Core Data object
    let sortDescriptor = NSSortDescriptor(key: "givenName", ascending: true)
    
    // Set the list of sort descriptors in the fetch request,
    // so it includes the sort descriptor
    fetchRequest.sortDescriptors = [sortDescriptor]
    
      if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Passport]
      {
        for passport in fetchResults
        {
          print(passport.givenName, separator: " ", terminator: "\n")
        }
        arrPassports = fetchResults
      }
  }
  // MARK: - Table view data source
  
  //-------------------------------------------------------------------------------------------------
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int
  {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return arrPassports.count
  }
  
  //-------------------------------------------------------------------------------------------------
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell")!

    let passport = arrPassports[indexPath.row]
    
    // Set the title of the cell to be the title of the logItem
    cell.textLabel?.text = passport.givenName! + " " + passport.surName!
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    let passport = arrPassports[indexPath.row]
    print(passport.passportNumber)
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
  {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath)
  {
    if(editingStyle == .Delete )
    {
      // Find the LogItem object the user is trying to delete
      let passportToDelete = arrPassports[indexPath.row]
      
      // Delete it from the managedObjectContext
      managedObjectContext.deleteObject(passportToDelete)
      
      // Refresh the table view to indicate that it's deleted
      self.fetchLog()
      
      // Tell the table view to animate out that row
      self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
  }
}
