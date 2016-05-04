//
//  BookDetailViewController.swift
//  SwiftLibrary
//
//  Created by Abdullah on 4/16/16.
//

import UIKit
import SafariServices

class BookDetailViewController: UIViewController {
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_author: UILabel!
    @IBOutlet weak var label_publish_date: UILabel!
    @IBOutlet weak var text_desc: UITextView!
    @IBOutlet weak var img_thumbnail: UIImageView!
    @IBOutlet weak var btn_view_info_page: UIButton!
    
    var selectedBook:Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let book = selectedBook
            else {
                fatalError("Couldn't find selectedBook property")
        }
        
        //Load book details
        if let url = NSURL(string: book.imageURi!),
            let data = NSData(contentsOfURL: url) {
                img_thumbnail.image = UIImage(data: data)
        }
        
        label_title.text = book.title
        label_author.text = book.author
        label_publish_date.text = book.publishDate
        text_desc.text = book.desc
        
        self.navigationItem.title = book.title
        
        //Check if selectedBook has descUri
        if let descUri = book.descUri {
            btn_view_info_page.enabled = true
        } else {
            btn_view_info_page.enabled = false
        }
    }
    
    @IBAction func onClick_btn_cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClick_btn_view_info_page(sender: AnyObject) {
        guard
            let nsUrl = NSURL(string: selectedBook!.descUri!)
            else {
                fatalError("Couldn't parse url to NSURL: \(selectedBook!.descUri!)")
        }
        
        let svc = SFSafariViewController(URL: nsUrl)
        self.presentViewController(svc, animated: true, completion: nil)
    }

}
