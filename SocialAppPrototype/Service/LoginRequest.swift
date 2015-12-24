import Foundation

class LoginRequest: Request {
    func perform(completion: (session: String?, error: String?) -> Void) {
        createRequest(params: nil)
        execute({ (result: [String : AnyObject]) -> Void in
            if ((result["status"] as! String) == "ok") {
                completion(session: result["session"] as? String, error: nil)
            } else {
                completion(session: nil, error: result["errorString"] as? String)
            }
        })
    }
}