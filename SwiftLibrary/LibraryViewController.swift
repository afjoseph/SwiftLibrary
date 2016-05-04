//
//  ViewController.swift
//  SwiftLibrary
//
//  Created by Abdullah on 4/10/16.
//

import UIKit
import CoreData

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var books = [Book]()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        let fetchRequest = NSFetchRequest(entityName: "Book")
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            books = results as! [Book]
        } catch let error as NSError {
            self.showAlertViewController("Couldn't load library data")
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "BookTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            as! BookTableViewCell
        
        let targetBook = books[indexPath.row]
        cell.label_title.text = targetBook.title
        cell.label_author.text = targetBook.author
        
        if  let url = NSURL(string: targetBook.imageURi!),
            let data = NSData(contentsOfURL: url) {
                cell.img_thumbnail.image = UIImage(data: data)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // remove the deleted item from the model
            managedObjectContext.deleteObject(books[indexPath.row])
            
            books.removeAtIndex(indexPath.row)
            
            saveManagedObjectContext()
            
            // remove the deleted item from the `UITableView`
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentBookDetail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let bookDetailViewController = navigationController.topViewController
                as! BookDetailViewController
            
            // Get the cell that generated this segue.
            if let selectedBookCell = sender as? BookTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedBookCell)!
                let selectedBook = books[indexPath.row]
                
                bookDetailViewController.selectedBook = selectedBook
            }
        }
    }
}
