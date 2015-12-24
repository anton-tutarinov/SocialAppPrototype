import Foundation

class SendMessageRequest: Request {
    private var message: String?
    private var session: String?
    
    init(url: String,  message: String, session: String) {
        super.init(url: url)
        
        self.message = message
        self.session = session
    }
    
    func perform(completion: (session: String?, message: String?, error: String?) -> Void) {
        var params = [String: String]()
        params["session"] = session
        params["message.text"] = message
        
        createRequest(params: params)
        execute({ (result: [String : AnyObject]) -> Void in
            if ((result["status"] as! String) == "ok") {
                let session = result["status"] as! String
                let message = result["status"] as! String
                completion(session: session, message: message, error: result["errorString"] as? String)
            } else {
                completion(session: nil, message: nil, error: result["errorString"] as? String)
            }
        })
    }
}

//{
//    "session": "485fc381-e790-47a3-9794-1337c0a8fe68",
//    "message": {
//        "text": "Some message text"
//    }
//}