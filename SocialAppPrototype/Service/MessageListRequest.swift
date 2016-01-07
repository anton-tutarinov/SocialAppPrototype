import Foundation

class MessageListRequest: Request {
    private var session: String?
    private var pageSize: UInt
    private var oldestMessageId: UInt
    private var completion: (totalCount: Int, messageList: [Message]?, error: String?) -> Void
    
    init(url: String, oldestMessageId: UInt, pageSize: UInt, session: String, completion: (totalCount: Int, messageList: [Message]?, error: String?) -> Void) {
        self.oldestMessageId = oldestMessageId
        self.pageSize = pageSize
        self.session = session
        self.completion = completion
        
        super.init(url: url)
    }
    
    override func execute() {
        var params = [String: String]()
        params["session"] = session
        params["paging_size"] = String(pageSize)
        params["oldest_message_id"] = String(oldestMessageId)
        
        createGetRequest(params: params, headers: nil)
        super.execute()
    }
    
    override func processResult(result result: [String: AnyObject]) {
        if ((result["status"] as! String) == "ok") {
            if let messages = result["messages"] as? [AnyObject] {
                var messageList = [Message]()
                
                for (item) in messages {
                    let msg = self.parseMessage(item as? [String: AnyObject])
                    
                    if (msg != nil) {
                        messageList.append(msg!)
                    }
                }
            
                let totalMessageCount = Int(result["total_items_count"] as! String)!
                
                self.completion(totalCount: totalMessageCount, messageList: messageList, error: nil)
            } else {
                self.completion(totalCount: 0, messageList: nil, error: "Invalid response format")
            }
        } else {
            self.completion(totalCount: 0, messageList: nil, error: result["errorString"] as? String)
        }
    }
    
    private func parseMessage(dic: [String: AnyObject]?) -> Message? {
        if (dic == nil) {
            return nil
        }
        
//        {"Message":{"id":"12","text":"wwww","image_url":null,"updated_at":"2016-01-07 20:15:04"},"User":{"id":"11","nickname":"o8h4za","avatar_url":null}}
        
        if let messageData = dic!["Message"] as? [String: AnyObject],
            let userData = dic!["User"] as? [String: AnyObject] {
                let senderId = UInt(userData["id"]! as! String)!
                let senderName = userData["nickname"] as? String
                var senderAvatarUrl: String?
                
                if let url = userData["avatar_url"] as? String {
                    senderAvatarUrl = url
                }
                
                let sender = User(id: senderId, name: senderName, imageUrl: senderAvatarUrl)
                
                let messageId = UInt(messageData["id"]! as! String)!
                let messageDate = dateFromString(messageData["updated_at"]! as! String)
                var messageText: String?
                var messageImageUrl: String?
                
                if let text = messageData["text"] as? String {
                    messageText = text
                }
                
                if let url = messageData["image_url"] as? String {
                    messageImageUrl = url
                }
                
                var messageType: Message.MessageType?
                
                if (ChatService.sharedInstance.user?.id == senderId) {
                    if (messageImageUrl != nil) {
                        messageType = Message.MessageType.OutImage
                    } else {
                        messageType = Message.MessageType.OutText
                    }
                } else {
                    if (messageImageUrl != nil) {
                        messageType = Message.MessageType.InImage
                    } else {
                        messageType = Message.MessageType.InText
                    }
                }
                
                return Message(messageId: messageId, messageType: messageType!, date: messageDate, text: messageText, imageUrl: messageImageUrl, sender: sender)
        } else {
            return nil;
        }
    }
    
    private func dateFromString(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.dateFromString(dateString)!
    }
}