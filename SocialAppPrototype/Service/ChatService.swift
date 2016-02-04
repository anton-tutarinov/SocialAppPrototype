import Foundation

class ChatService {
    static let loginResultNotification = "ChatService_LoginResult"
    static let sendMessageResultNotification = "ChatService_SendMessageResult"
    static let loadMessageListResultNotification = "ChatService_LoadMessageList"
    
    static let sharedInstance = ChatService()
    
    var user: User?
    
//    private let apiHost: String = "http://localhost/socialapp"
    private let apiHost: String = "http://ec2-54-191-142-152.us-west-2.compute.amazonaws.com"
    private var session: String?

    private var opQueue = NSOperationQueue()
    
    private init() {
        
    }
    
    func isLogin() -> Bool {
        return (user != nil)
    }
    
    func login() {
        if loadSession() {
            let request = UpdateSessionRequest(url: "\(apiHost)/session", session: session!,
                completion: { (userData: [String: String]?, error: String?) -> Void in
                var userInfo = [String: AnyObject]()
                
                if (userData != nil) {
                    let id = UInt(userData!["id"]!)
                    self.user = User(id: id!, name: nil, imageUrl: nil)
                    userInfo["result"] = true
                } else {
                    userInfo["result"] = false
                    userInfo["error"] = error
                }
                
                self.postNotification(name: ChatService.loginResultNotification, userInfo: userInfo)
            })
            request.execute()
        } else {
            let request = LoginRequest(url: "\(apiHost)/signup", completion: { (session, error) -> Void in
                if (session != nil) {
                    self.session = session
                    self.saveSession()
                    
                    let request = UpdateSessionRequest(url: "\(self.apiHost)/session", session: session!,
                        completion: { (userData: [String: String]?, error: String?) -> Void in
                            var userInfo = [String: AnyObject]()
                            
                            if (userData != nil) {
                                let id = UInt(userData!["id"]!)
                                self.user = User(id: id!, name: nil, imageUrl: nil)
                                userInfo["result"] = true
                            } else {
                                userInfo["result"] = false
                                userInfo["error"] = error
                            }
                            
                            self.postNotification(name: ChatService.loginResultNotification, userInfo: userInfo)
                    })
                    request.execute()
                } else {
                    var userInfo = [String: AnyObject]()
                    
                    userInfo["result"] = false
                    userInfo["error"] = error
                    
                    self.postNotification(name: ChatService.loginResultNotification, userInfo: userInfo)
                }
            })
            request.execute()
        }
    }
    
    func loadMessageList(oldestId oldestId: UInt, newestId: UInt, pageSize: UInt) {
        let request = MessageListRequest(url: "\(apiHost)/messages", oldestMessageId: oldestId, newestMessageId: newestId, pageSize: pageSize, session: session!,
            completion: { (totalCount, messageList, error) -> Void in
            var userInfo = [String: AnyObject]()
            
            if (messageList != nil) {
                userInfo["result"] = true
                userInfo["messageList"] = messageList
                userInfo["totalCount"] = totalCount
            } else {
                userInfo["result"] = false
                userInfo["error"] = error
            }
            
            self.postNotification(name: ChatService.loadMessageListResultNotification, userInfo: userInfo)
        })
        request.execute()
    }
    
    func sendTextMessage(text: String) {
        let request = SendMessageRequest(url: "\(apiHost)/messages/message", text: text, session: session!,
            completion: { (error: String?) -> Void in
            var userInfo = [String: AnyObject]()
            
            if (error == nil) {
                userInfo["result"] = true
            } else {
                userInfo["result"] = false
                userInfo["error"] = error
            }
            
            self.postNotification(name: ChatService.sendMessageResultNotification, userInfo: userInfo)
        })
        request.execute()
    }
    
    func sendImageMessage(imageData: NSData) {
        let uploadRequest = UploadImageRequest(url: "\(apiHost)/image", imageData: imageData, session: session!) { (imageUrl, error) -> Void in
            if (error == nil) {
                let messageRequest = SendMessageRequest(url: "\(self.apiHost)/messages/message", imageUrl: imageUrl!, session: self.session!, completion: { (error) -> Void in
                    var userInfo = [String: AnyObject]()
                    
                    if (error == nil) {
                        userInfo["result"] = true
                    } else {
                        userInfo["result"] = false
                        userInfo["error"] = error
                    }
                    
                    self.postNotification(name: ChatService.sendMessageResultNotification, userInfo: userInfo)
                })
                messageRequest.execute()
            } else {
                var userInfo = [String: AnyObject]()
                
                userInfo["result"] = false
                userInfo["error"] = error
                
                self.postNotification(name: ChatService.sendMessageResultNotification, userInfo: userInfo)
            }
        }
        uploadRequest.execute()
    }
    
    private func updateSessionAndRepeat(prevRequest prevRequest: Request) {
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        
        opQueue.addOperationWithBlock { () -> Void in
            let request = UpdateSessionRequest(url: "\(self.apiHost)/session", session: self.session!,
                completion: { (userData: [String: String]?, error: String?) -> Void in
                    var userInfo = [String: AnyObject]()
                    
                    if (userData != nil) {
                        let id = UInt(userData!["id"]!)
                        self.user = User(id: id!, name: nil, imageUrl: nil)
                        userInfo["result"] = true
                    } else {
                        userInfo["result"] = false
                        userInfo["error"] = error
                    }
                    
                    dispatch_semaphore_signal(semaphore);
            })
            request.execute()
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            prevRequest.execute()
        }
    }
    
    private func loadSession() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let session = defaults.objectForKey("session") as? String {
            self.session = session
            return true
        }
        
        return false
    }
    
    private func saveSession() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(session, forKey: "session")
    }
    
    private func postNotification(name name: String, userInfo: [String: AnyObject]? = nil) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(name, object: self, userInfo: userInfo)
        }
    }
}