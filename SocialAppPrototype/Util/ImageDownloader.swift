import Foundation
import UIKit

class ImageDownloader {
    static let successNotification: String = "ImageDownloader_SuccessNotification"
    static let failureNotification: String = "ImageDownloader_FailureNotification"
    
    static let sharedInstance = ImageDownloader()
    
    private var clientQueue = NSMutableArray()
    private var operationQueue = NSOperationQueue()
    
    private init() {
        
    }
    
    func download(url imageUrl: String, object: AnyObject) {
        let predicate = NSPredicate(format: "imageUrl == %@", imageUrl)
        let array = clientQueue.filteredArrayUsingPredicate(predicate) as [AnyObject]
        
        if array.count > 0 {
            return
        }
        
        clientQueue.addObject(["imageUrl": imageUrl, "object": object])
        operationQueue.addOperationWithBlock({
            if let data = NSData(contentsOfURL: NSURL(string: imageUrl)!) {
                let image = UIImage(data: data)!
                image.saveOnSDCard(imageUrl)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    let array = self.clientQueue.filteredArrayUsingPredicate(predicate) as [AnyObject]
                    
                    for entity in array {
                        NSNotificationCenter.defaultCenter().postNotificationName(ImageDownloader.successNotification,
                            object: (entity as! NSDictionary)["object"], userInfo: ["imageUrl": (entity as! NSDictionary)["imageUrl"] as! String])
                    }
                    
                    self.clientQueue.removeObjectsInArray(array)
                })
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    let array = self.clientQueue.filteredArrayUsingPredicate(predicate) as [AnyObject]
                    
                    for entity in array {
                        NSNotificationCenter.defaultCenter().postNotificationName(ImageDownloader.failureNotification,
                            object: (entity as! NSDictionary)["object"], userInfo: ["imageUrl": (entity as! NSDictionary)["imageUrl"] as! String])
                    }
                    
                    self.clientQueue.removeObjectsInArray(array)
                })
            }
        })
    }
    
    func clear() {
        operationQueue.cancelAllOperations()
        clientQueue.removeAllObjects()
    }
}