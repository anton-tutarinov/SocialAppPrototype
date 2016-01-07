import Foundation

class SendMessageRequest: Request {
    private var message: String
    private var session: String
    private var completion: (error: String?) -> Void
    
    init(url: String,  message: String, session: String, completion: (error: String?) -> Void) {
        self.message = message
        self.session = session
        self.completion = completion
        
        super.init(url: url)
    }
    
    override func execute() {
        var headers = [String: String]()
        headers["Content-Type"] = "application/json"
        
        let body = "{ \"session\": \"\(session)\", \"message\": { \"text\": \"\(message)\" } }"
        
        createPostRequest(body: body, headers: headers)
        super.execute()
    }
    
    override func processResult(result result: [String: AnyObject]) {
        if ((result["status"] as! String) == "ok") {
            self.completion(error: nil)
        } else {
            self.completion(error: result["errorString"] as? String)
        }
    }
    
//    dataString	String?	"{\"Message\":{\"user_id\":\"9\",\"created_at\":\"2016-01-07 18:20:46\",\"updated_at\":\"2016-01-07 18:20:46\",\"text\":\"gg\"}}"	Some
}