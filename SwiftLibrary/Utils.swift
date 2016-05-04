//
//  Utils.swift
//  Library
//
//  Created by Mindvalley on 3/24/16.
//

import Foundation
import UIKit
import CoreData

class Utils {
    
}

extension Utils {
    static func jsonStringToDict(src: NSString) -> NSDictionary? {
        // convert String to NSData
        let data = src.dataUsingEncoding(NSUTF8StringEncoding)
        var error: NSError?
        
        // convert NSData to a serialized 'AnyObject'
        let anyObj: AnyObject?
        
        do {
            anyObj = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
        } catch let error1 as NSError {
            error = error1
            anyObj = nil
        }
        
        if(error != nil) {
            // If there is an error parsing JSON, print it to the console
            print("JSON Error \(error!.localizedDescription)")
            //self.showError()
            return nil
        } else {
            return anyObj as? NSDictionary
        }
    }
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

extension UIViewController {
    var managedObjectContext:NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
            showAlertViewController("Could not save object")
        }
        
    }
    
    func showAlertViewController(message:String) {
        let alertController = UIAlertController(title: "SwiftLibrary", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
