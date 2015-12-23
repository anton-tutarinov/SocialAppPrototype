import Foundation
import UIKit

class Message {
    enum MessageType: Int {
        case InText
        case OutText
        case OutImage
    }
    
    var messageType: MessageType?
    var date: NSDate?
    var sender: User?
    var text: String?
    var image: UIImage?
    
    init(messageType: MessageType, date: NSDate, text: String?, image: UIImage?, sender: User?) {
        self.messageType = messageType
        self.date = date
        self.text = text
        self.image = image
        self.sender = sender
    }
}