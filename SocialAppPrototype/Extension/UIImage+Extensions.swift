import UIKit

extension UIImage {
    static func existsOnDisk(imagePath imagePath: String) -> Bool {
        let folder = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = folder.stringByAppendingPathComponent(imagePath.getMD5)
        return NSFileManager.defaultManager().fileExistsAtPath(filePath)
    }
    
    static func loadFromDisk(name: String) -> UIImage? {
        let folder = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = folder.stringByAppendingPathComponent(name.getMD5)
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            let data = NSData(contentsOfFile: filePath)!
            let image = UIImage(data: data)
            
            return image!
        }
        
        return nil
    }
    
    func saveToDisk(name: String) {
        let folder = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = folder.stringByAppendingPathComponent(name.getMD5)
        
        if let data = UIImagePNGRepresentation(self) {
            data.writeToFile(filePath, atomically: false)
        }
    }
}