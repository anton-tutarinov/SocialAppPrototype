import Foundation

class ChatService {
    static let sharedInstance = ChatService()
    
    private let apiHost: String = "http://52.192.101.131"
    
    private var session: String?
    
    private init() {
        
    }
    
    func isLogin() -> Bool {
        return (session != nil)
    }
    
    func login(completion: (success: Bool, error: String?) -> Void) {
        let request = LoginRequest(url: "\(apiHost)/signup")
        request.perform { (session, error) -> Void in
            if (session != nil) {
                self.session = session
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    func updateSession() {
        let request = UpdateSessionRequest(url: "\(apiHost)/messages/message", session: session!)
        request.perform { (session: String?, error: String?) -> Void in
            if (session != nil) {
                self.session = session
            } else {
                //?????
            }
        }
    }
    
    func loadOldMessages(oldestId: Int, pageSize: Int, completion: (messageList: [Message]?, error: String?) -> Void) {
        let request = MessageListRequest(url: "\(apiHost)/messages", oldestMessageId: oldestId, pageSize: pageSize, session: session!)
        request.perform(completion)
    }
    
    func sendMessage(message message: String, completion: (message: String?, error: String?) -> Void) {
        let request = SendMessageRequest(url: "\(apiHost)/messages/message", message: message, session: session!)
        request.perform { (session: String?, message: String?, error: String?) -> Void in
            if (session != nil) && (message != nil) {
                self.session = session
                completion(message: message, error: nil)
            } else {
                completion(message: nil, error: error)
            }
        }
    }
}