import Foundation

class UpdateSessionRequest: Request {
    private var session: String?
    
    init(url: String, session: String) {
        super.init(url: url)
        
        self.session = session
    }
    
    func perform(completion: (session: String?, error: String?) -> Void) {
        var params = [String: String]()
        params["session"] = session
        
        createRequest(params: params)
        execute({ (result: [String : AnyObject]) -> Void in
            if ((result["status"] as! String) == "ok") {
                completion(session: result["session"] as? String, error: result["errorString"] as? String)
            } else {
                completion(session: nil, error: result["errorString"] as? String)
            }
        })
    }
}