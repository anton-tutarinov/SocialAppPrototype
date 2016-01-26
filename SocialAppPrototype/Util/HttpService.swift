import Foundation

class HttpService {
    static func post(url url: String, body: String, headers: [String: String]?,
        completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
            let request = createPostRequest(url: url, body: body, headers: headers)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request,
                completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    completionHandler(data: data, response: response, error: error)
            })
            task.resume()
    }
    
    static func post(url url: String, params: [String: String]?, headers: [String: String]?,
        completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
            let request = createPostRequest(url: url, params: params, headers: headers)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request,
                completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    completionHandler(data: data, response: response, error: error)
            })
            task.resume()
    }
    
    static func get(url url: String, params: [String: String]?, headers: [String: String]?,
        completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
            let request = createGetRequest(url: url, params: params, headers: headers)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request,
                completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    completionHandler(data: data, response: response, error: error)
            })
            task.resume()
    }
    
//    static func requestSync(url url: String, params: [String: String]?, headers: [String: String]?, method: HttpMethod,
//        completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
//            let request = createRequest(url: url, params: params, headers: headers, method: method)
//            let session = NSURLSession.sharedSession()
//            let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
//            let task = session.dataTaskWithRequest(request,
//                completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//                    completionHandler(data: data, response: response, error: error)
//                    dispatch_semaphore_signal(semaphore);
//            })
//            task.resume()
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//    }
    
    static func createPostRequest(url url: String, params: [String: String]?, headers: [String: String]?) -> NSURLRequest {
        let urlString = "\(url)"
        let requestURL = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: requestURL)
        
        if (headers != nil) {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if (params != nil) {
            let paramsString = paramsToString(params: params!)
            request.HTTPBody = paramsString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        request.HTTPMethod = "POST"
        return request
    }
    
    static func createPostRequest(url url: String, body: String, headers: [String: String]?) -> NSURLRequest {
        let urlString = "\(url)"
        let requestURL = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: requestURL)
        
        if (headers != nil) {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        return request
    }
    
    static func createGetRequest(url url: String, params: [String: String]?, headers: [String: String]?) -> NSURLRequest {
        var urlString = "\(url)"
        
        if (params != nil) {
            let paramsString = paramsToString(params: params!)
            urlString += "?\(paramsString)"
        }
        
        let requestURL = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: requestURL)
        
        if (headers != nil) {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.HTTPMethod = "GET"
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
