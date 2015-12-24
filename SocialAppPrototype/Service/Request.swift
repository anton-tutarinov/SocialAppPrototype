import Foundation

class Request {
    let url: String?
    var request: NSURLRequest?
    
    init(url: String) {
        self.url = url
    }
    
    func createRequest(params params: [String: String]?) {
        request = HttpService.createRequest(url: url!, params: params, method: HttpService.HttpMethod.Post)
    }
    
    func execute(completion: ([String: AnyObject]) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request!,
            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                let result = self.processResponse(data, response: response, error: error)
                completion(result)
        })
        task.resume()
    }
    
//    func executeSync(completion: ([String: AnyObject]) -> Void) {
//        let session = NSURLSession.sharedSession()
//        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
//        let task = session.dataTaskWithRequest(request!,
//            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//                let result = self.processResponse(data, response: response, error: error)
//                completion(result)
//        })
//        task.resume()
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//    }
    
    func processResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> [String: AnyObject] {
        var result = [String: AnyObject]()
        
        if (error != nil) {
            result["status"] = "error"
            result["errorString"] = error?.localizedDescription
        } else if let resp = response as? NSHTTPURLResponse {
            if (data != nil) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
                    
                    if (resp.statusCode == 200) || (resp.statusCode == 201) {
                        result["status"] = "ok"
                        
                        for (key, value) in json {
                            result[key] = value
                        }
                    } else if (resp.statusCode == 400) {
                        result["status"] = "error"
                        
                        //????????
                        let message = json["message"] as? [AnyObject]
                        result["errorString"] = ""
                        
                    } else if (resp.statusCode == 405) {
                        result["status"] = "error"
                        result["errorString"] = json["message"]
                    } else {
                        result["status"] = "error"
                        result["errorString"] = json["unknows error"]
                    }
                } catch let err as NSError {
                    result["status"] = "error"
                    result["errorString"] = err.localizedDescription
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