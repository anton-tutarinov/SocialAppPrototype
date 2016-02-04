import Foundation

class UploadImageRequest: Request {
    private var session: String
    private var imageData: NSData
    private var completion: (imageUrl: String?, error: String?) -> Void
    
    init(url: String, imageData: NSData, session: String, completion: (imageUrl: String?, error: String?) -> Void) {
        self.imageData = imageData
        self.session = session
        self.completion = completion
        
        super.init(url: url)
    }
    
    override func execute() {
        var headers = [String: String]()
        let boundary = String(format: "---------------------------14737809831466499882746641449")
        headers["Content-Type"] = String(format: "multipart/form-data; boundary=%@",boundary)
        
        var body = String()
        
        body.appendContentsOf(String(format: "\r\n--%@\r\n", boundary))
        body.appendContentsOf(String(format:"Content-Disposition: form-data; name=\"image\"; filename=\"img.jpg\"\\r\n"))
        body.appendContentsOf(String(format: "Content-Type: application/octet-stream\r\n\r\n"))
        body.appendContentsOf(imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        body.appendContentsOf(String(format: "\r\n--%@\r\n", boundary))
        
//        let body = NSMutableData()
        
//        body.appendData(String(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
//        body.appendData(String(format:"Content-Disposition: form-data; name=\"image\"; filename=\"img.jpg\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
//        body.appendData(String(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
//        body.appendData(imageData)
//        body.appendData(String(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        
//        let bodyStr = String(data: body, encoding:NSUTF8StringEncoding)
        
        createPostRequest(body: body, headers: headers)
        super.execute()
    }
    
    override func processResult(result result: [String: AnyObject]) {
        if ((result["status"] as! String) == "ok") {
            self.completion(imageUrl: result["image_url"] as? String, error: nil)
        } else {
            self.completion(imageUrl: nil, error: result["errorString"] as? String)
        }
    }
}