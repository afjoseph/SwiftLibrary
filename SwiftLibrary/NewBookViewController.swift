//
//  NewBookViewController.swift
//  SwiftLibrary
//
//  Created by Abdullah on 4/13/16.
//

import UIKit
import CoreData

class NewBookViewController: UIViewController {
    @IBOutlet weak var text_isbn: UITextField!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_author: UILabel!
    @IBOutlet weak var label_publish_date: UILabel!
    @IBOutlet weak var text_desc: UITextView!
    @IBOutlet weak var img_thumbnail: UIImageView!
    @IBOutlet weak var btn_add_to_library: UIButton!
    @IBOutlet weak var btn_isbn_search: UIButton!
    @IBOutlet weak var view_details: UIView!
    
    var processedBook: Book?
    let progressHUD = ProgressHUD(text: "Pulling data")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_details.hidden = true
        btn_add_to_library.enabled = false
        
        self.view.addSubview(progressHUD)
        progressHUD.hide()
    }
    
    func showProgressLoading() {
        self.progressHUD.show()
        self.text_isbn.userInteractionEnabled = false
        self.text_isbn.alpha = 0.3
        
        self.btn_isbn_search.userInteractionEnabled = false
        self.btn_isbn_search.alpha = 0.3
    }
    
    func hideProgressLoading() {
        self.progressHUD.hide()
        self.text_isbn.userInteractionEnabled = true
        self.text_isbn.alpha = 1.0
        
        self.btn_isbn_search.userInteractionEnabled = true
        self.btn_isbn_search.alpha = 1.0
    }
    
    @IBAction func onClick_btn_search(sender: AnyObject) {
        guard
            let isbn = text_isbn.text,
            let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let apiUri = dict["Google Books Search ISBN"] as? String
            else {
                fatalError("Couldn't create search URI from isbn code")
        }
        
        self.showProgressLoading()
        
        //Do the HTTPS request
        //https://www.googleapis.com/books/v1/volumes?q=isbn:12345
        let url = NSURL(string: apiUri + isbn)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data:NSData?, response:NSURLResponse?, error:NSError?) in
            
            guard
                let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding),
                let dict = Utils.jsonStringToDict(jsonString)
                else {
                    //Show alert view controller
                    self.showAlertViewController("Couldn't find results for code: \(url)")
                    return
            }
            
            //Parse the JSON file
            guard
                let items           = dict["items"] as? NSArray,
                let firstItem      = items[0] as? NSDictionary,
                let identifier      = firstItem["id"] as? String,
                let volumeInfo      = firstItem["volumeInfo"] as? NSDictionary
                else {
                    fatalError("Couldn't process dict file")
            }
            
            let title           = volumeInfo["title"] as? String ?? ""
            let description     = volumeInfo["description"] as? String ?? ""
            let publishDate     = volumeInfo["publishedDate"] as? String ?? ""
            let infoLink        = volumeInfo["infoLink"] as? String ?? ""
            
            var smallThumbnail = ""
            if let imageLinks   = volumeInfo["imageLinks"] as? NSDictionary {
                smallThumbnail = imageLinks["smallThumbnail"] as? String ?? ""
            }
            
            var mainAuthor = ""
            if let authors  = volumeInfo["authors"] as? NSArray {
                mainAuthor = authors[0] as? String ?? ""
            }
            
            //Add objects to CoreData
            let entity =  NSEntityDescription.entityForName("Book",
                inManagedObjectContext: self.managedObjectContext)
            
            self.processedBook = Book(entity: entity!,
                insertIntoManagedObjectContext: self.managedObjectContext)
            self.processedBook!.id = identifier
            self.processedBook!.title = title
            self.processedBook!.author = mainAuthor
            self.processedBook!.publishDate = publishDate
            self.processedBook!.desc = description
            self.processedBook!.descUri = infoLink
            self.processedBook!.imageURi = smallThumbnail
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.loadBookDetails(self.processedBook!)
                self.btn_add_to_library.enabled = true
                self.view_details.hidden = false
                
                self.hideProgressLoading()
            }
        }
        
        task.resume()
    }
    
    @IBAction func onClick_btn_add_to_library(sender: AnyObject) {
        saveManagedObjectContext()
        showAlertViewController("Book successfully added")
    }
    
    private func loadBookDetails(book: Book) {
        if  let url = NSURL(string: book.imageURi!),
            let data = NSData(contentsOfURL: url) {
                img_thumbnail.image = UIImage(data: data)
        }
        
        label_title.text = book.title
        label_author.text = book.author
        label_publish_date.text = book.publishDate
        text_desc.text = book.desc
    }

}
