import Foundation

class UpdateSessionRequest: Request {
    private var session: String
    private var completion: (userData: [String: String]?, error: String?) -> Void
    
    init(url: String, session: String, completion: (userData: [String: String]?, error: String?) -> Void) {
        self.session = session
        self.completion = completion
        
        super.init(url: url)
    }
    
    override func execute() {
        var headers = [String: String]()
        headers["Content-Type"] = "application/json"
        
        let body = "{ \"session\": \"\(session)\" }"
        
        createPostRequest(body: body, headers: headers)
        super.execute()
    }
    
    override func processResult(result result: [String: AnyObject]) {
        if ((result["status"] as! String) == "ok") {
            let user = result["User"] as? [String: String]
            self.completion(userData: user, error: nil)
        } else {
            self.completion(userData: nil, error: result["errorString"] as? String)
        }
    }
}