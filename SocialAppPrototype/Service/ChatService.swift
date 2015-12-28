import Foundation

class ChatService {
    static let LoginResultNotification = "ChatService_LoginResult"
    static let SendMessageResultNotification = "ChatService_SendMessageResult"
    static let LoadOldMessageListResultNotification = "ChatService_LoadOldMessageList"
    
    static let sharedInstance = ChatService()
    
    private let apiHost: String = "http://52.192.101.131"
    
    private var session: String?
    
    private init() {
        
    }
    
    func isLogin() -> Bool {
        return (session != nil)
    }
    
    func login() {
        if loadSession() {
            let request = UpdateSessionRequest(url: "\(apiHost)/session", session: session!)
            request.perform { (session: String?, error: String?) -> Void in
                var userInfo = [String: AnyObject]()
                
                if (session != nil) {
                    self.session = session
                    self.saveSession()
                    userInfo["result"] = true
                } else {
                    userInfo["result"] = false
                    userInfo["error"] = error
                }
                
                self.postNotification(name: ChatService.LoginResultNotification, userInfo: userInfo)
            }
        } else {
            let request = LoginRequest(url: "\(apiHost)/signup")
            request.perform { (session, error) -> Void in
                var userInfo = [String: AnyObject]()
                
                if (session != nil) {
                    self.session = session
                    self.saveSession()
                    userInfo["result"] = true
                } else {
                    userInfo["result"] = false
                    userInfo["error"] = error
                }
                
                self.postNotification(name: ChatService.LoginResultNotification, userInfo: userInfo)
            }
        }
    }
    
    func loadOldMessageList(oldestId oldestId: Int, pageSize: Int) {
        let request = MessageListRequest(url: "\(apiHost)/messages", oldestMessageId: oldestId, pageSize: pageSize, session: session!)
        request.perform( { (messageList, error) -> Void in
            var userInfo = [String: AnyObject]()
            
            if (messageList != nil) {
                userInfo["messageList"] = messageList
            } else {
                userInfo["error"] = error
            }
            
            self.postNotification(name: ChatService.LoadOldMessageListResultNotification, userInfo: userInfo)
        })
    }
    
    func sendMessage(message message: String) {
        let request = SendMessageRequest(url: "\(apiHost)/messages/message", message: message, session: session!)
        request.perform { (session: String?, message: String?, error: String?) -> Void in
            var userInfo = [String: AnyObject]()
            
            if (session != nil) && (message != nil) {
                self.session = session
                self.saveSession()
                userInfo["message"] = message
            } else {
                userInfo["error"] = error
            }
            
            self.postNotification(name: ChatService.SendMessageResultNotification, userInfo: userInfo)
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