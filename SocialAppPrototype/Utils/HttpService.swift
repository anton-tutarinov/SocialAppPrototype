import Foundation

class HttpService {
    enum HttpMethod: String {
        case Get = "GET"
        case Post = "POST"
    }
    
    static func request(url url: String, params: [String: String]?, method: HttpMethod,
        completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
            let request = createRequest(url: url, params: params, method: method)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request,
                completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    completionHandler(data: data, response: response, error: error)
            })
            task.resume()
    }
    
    static func requestSync(url url: String, params: [String: String]?, method: HttpMethod,
        completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
            let request = createRequest(url: url, params: params, method: method)
            let session = NSURLSession.sharedSession()
            let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
            let task = session.dataTaskWithRequest(request,
                completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    completionHandler(data: data, response: response, error: error)
                    dispatch_semaphore_signal(semaphore);
            })
            task.resume()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    static func createRequest(url url: String, params: [String: String]?, method: HttpMethod) -> NSURLRequest {
        var urlString = "\(url)"
        let request: NSMutableURLRequest
        
        if method == HttpMethod.Post {
            let requestURL = NSURL(string: urlString)!
            request = NSMutableURLRequest(URL: requestURL)
            
            if (params != nil) {
                let paramsString = paramsToString(params: params!)
                request.HTTPBody = paramsString.dataUsingEncoding(NSUTF8StringEncoding)
            }
        } else {
            if (params != nil) {
                let paramsString = paramsToString(params: params!)
                urlString += "?\(paramsString)"
            }
            
            let requestURL = NSURL(string: urlString)!
            request = NSMutableURLRequest(URL: requestURL)
        }
        
        request.HTTPMethod = method.rawValue
        return request
    }
    
    private static func paramsToString(params params: [String: String]) -> String {
        var paramsString = String()
        for (key, value) in params {
            if paramsString.characters.count > 0 {
                paramsString += "&"
            }
            
            paramsString += "\(key)=\(value)";
        }
        
        return paramsString
    }
}
