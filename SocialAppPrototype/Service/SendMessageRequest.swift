import Foundation

class SendMessageRequest: Request {
    private var session: String
    private var text: String?
    private var imageUrl: String?
    private var completion: (error: String?) -> Void
    
    init(url: String, text: String, session: String, completion: (error: String?) -> Void) {
        self.text = text
        self.imageUrl = nil
        self.session = session
        self.completion = completion
        
        super.init(url: url)
    }
    
    init(url: String, imageUrl: String, session: String, completion: (error: String?) -> Void) {
        self.text = nil
        self.imageUrl = imageUrl
        self.session = session
        self.completion = completion
        
        super.init(url: url)
    }
    
    override func execute() {
        var headers = [String: String]()
        headers["Content-Type"] = "application/json"
        
        var body: String?
        
        if (text != nil) {
            body = "{ \"session\": \"\(session)\", \"message\": { \"text\": \"\(text!)\" } }"
        } else {
            body = "{ \"session\": \"\(session)\", \"message\": { \"image_url\": \"\(imageUrl!)\" } }"
        }
        
        createPostRequest(body: body!, headers: headers)
        super.execute()
    }
    
    override func processResult(result result: [String: AnyObject]) {
        if ((result["status"] as! String) == "ok") {
            self.completion(error: nil)
        } else {
            self.completion(error: result["errorString"] as? String)
        }
    }
}