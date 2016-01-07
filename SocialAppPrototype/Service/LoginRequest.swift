import Foundation

class LoginRequest: Request {
    private var completion: (session: String?, error: String?) -> Void
    
    init(url: String, completion: (session: String?, error: String?) -> Void) {
        self.completion = completion
        
        super.init(url: url)
    }
    
    override func execute() {
        createPostRequest(params: nil, headers: nil)
        super.execute()
    }
    
    override func processResult(result result: [String: AnyObject]) {
        if ((result["status"] as! String) == "ok") {
            completion(session: result["session"] as? String, error: nil)
        } else {
            completion(session: nil, error: result["errorString"] as? String)
        }
    }
}