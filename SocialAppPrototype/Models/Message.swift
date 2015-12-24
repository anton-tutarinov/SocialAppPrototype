import Foundation
import UIKit

class Message {
    enum MessageType: Int {
        case InText
        case OutText
        case OutImage
    }
    
    var id: Int = 0
    var messageType: MessageType?
    var date: NSDate?
    var text: String?
    var image: UIImage?
    var imageUrl: String?
    
//    var sender: User?
    
    init(messageId: Int, messageType: MessageType, date: NSDate, text: String?, imageUrl: String?) {
        self.id = messageId
        self.messageType = messageType
        self.date = date
        self.text = text
        self.imageUrl = imageUrl
    }
    
    // TEST
    init(messageType: MessageType, date: NSDate, text: String?, image: UIImage?) {
        self.messageType = messageType
        self.date = date
        self.text = text
        self.image = image
    }
}