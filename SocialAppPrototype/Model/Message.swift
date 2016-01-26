import Foundation
import UIKit

class Message {
    enum MessageType: Int {
        case InText
        case InImage
        case OutText
        case OutImage
    }
    
    var id: UInt
    var messageType: MessageType?
    var date: NSDate?
    var text: String?
    var imageUrl: String?
    var sender: User?
    
    init(messageId: UInt, messageType: MessageType, date: NSDate, text: String?, imageUrl: String?, sender: User?) {
        self.id = messageId
        self.messageType = messageType
        self.date = date
        self.text = text
        self.imageUrl = imageUrl
        self.sender = sender
    }
}