import Foundation

class Request {
    private let url: String
    private var request: NSURLRequest?
    
    init(url: String) {
        self.url = url
    }
    
    func createPostRequest(params params: [String: String]?, headers: [String: String]?) {
        request = HttpService.createPostRequest(url: url, params: params, headers: headers)
    }
    
    func createPostRequest(body body: String, headers: [String: String]?) {
        request = HttpService.createPostRequest(url: url, body: body, headers: headers)
    }

    func createGetRequest(params params: [String: String]?, headers: [String: String]?) {
        request = HttpService.createGetRequest(url: url, params: params, headers: headers)
    }
    
    func execute() {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request!,
            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                let result = self.processResponse(data, response: response, error: error)
                self.processResult(result: result)
        })
        task.resume()
    }
    
    func processResult(result result: [String: AnyObject]) {
        
    }
    
//    func executeSync(completion: ([String: AnyObject]) -> Void) {
//        let session = NSURLSession.sharedSession()
//        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
//        let task = session.dataTaskWithRequest(request!,
//            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//                let result = self.processResponse(data, response: response, error: error)
//                completion(result)
//                
//                dispatch_semaphore_signal(semaphore);
//        })
//        task.resume()
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//    }
    
    private func processResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> [String: AnyObject] {
        var result = [String: AnyObject]()
        
        if (error != nil) {
            result["status"] = "error"
            result["errorString"] = error?.localizedDescription
        } else if let resp = response as? NSHTTPURLResponse {
            if (data != nil) {
                do {
                    debugLog(String(data: data!, encoding: NSUTF8StringEncoding)!)
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
                    
                    if (resp.statusCode == 200) || (resp.statusCode == 201) {
                        result["status"] = "ok"
                        
                        for (key, value) in json {
                            result[key] = value
                        }
                    } else if (resp.statusCode == 400) {
                        result["status"] = "error"
                        result["errorString"] = String(json["message"])
                    } else if (resp.statusCode == 405) {
                        result["status"] = "error"
                        result["errorString"] = String(json["message"])
                    } else {
                        result["status"] = "error"
                        result["errorString"] = String(json["unknows error"])
                    }
                } catch let err as NSError {
                    result["status"] = "error"
                    result["errorString"] = String(err.localizedDescription)
                }
            } else {
                result["status"] = "error"
                result["errorString"] = "data is nil"
            }
        } else {
            result["status"] = "error"
            result["errorString"] = "response as? NSHTTPURLResponse retruned nil"
        }
        
        return result
    }
}