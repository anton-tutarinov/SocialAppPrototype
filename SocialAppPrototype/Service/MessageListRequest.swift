import Foundation

class MessageListRequest: Request {
    private var session: String?
    private var pageSize: Int = 0
    private var oldestMessageId = 0
    
    init(url: String, oldestMessageId: Int, pageSize: Int, session: String) {
        super.init(url: url)
        
        self.oldestMessageId = oldestMessageId
        self.pageSize = pageSize
        self.session = session
    }
    
    func perform(completion: (messageList: [Message]?, error: String?) -> Void) {
        var params = [String: String]()
        params["session"] = session
        params["paging_size"] = String(pageSize)
        params["oldest_message_id"] = String(oldestMessageId)
        
        createRequest(params: params)
        execute({ (result: [String : AnyObject]) -> Void in
            if ((result["status"] as! String) == "ok") {
                if let messages = result["messages"] as? [String: AnyObject] {
                    var messageList = [Message]()
                    
                    for (_, value) in messages {
                        let msg = self.parseMessage(value as? [String: AnyObject])
                        
                        if (msg != nil) {
                            messageList.append(msg!)
                        }
                    }
                    
                    completion(messageList: messageList, error: nil)
                } else {
                    completion(messageList: nil, error: "Invalid response format")
                }
            } else {
                completion(messageList: nil, error: result["errorString"] as? String)
            }
        })
    }
    
    private func parseMessage(dic: [String: AnyObject]?) -> Message? {
        if (dic == nil) {
            return nil
        }
        
        let id = dic!["id"] as? Int
        let text = dic!["text"] as? String
        let imageUrl = dic!["image_url"] as? String
        let date = dateFromString((dic!["updated_at"] as? String)!)
        
        return Message(messageId: id!, messageType: Message.MessageType.InText, date: date, text: text, imageUrl: imageUrl)
    }
    
    private func dateFromString(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.dateFromString(dateString)!
    }
}

//{
//    "messages": [
//    {
//    "Message":
//    {
//    "id": 1,
//    "text": "Project name",
//    "image_url": NULL,
//    "updated_at": "2015-01-01 01:01:01",
//    }
//    },
//    {
//    "Message":
//    {
//    "id": 1,
//    "text": NULL,
//    "image_url": "http://example.com/image.png",
//    "updated_at": "2015-01-01 01:01:01",
//    }
//    }
//    ]
//}