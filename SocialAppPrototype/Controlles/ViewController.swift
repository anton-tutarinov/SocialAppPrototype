import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
//    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomPanel: UIView!
    
    @IBOutlet weak var keyboardSpaceConstraint: NSLayoutConstraint!
    
    private var emptySpace: CGFloat = 0.0
    private var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        self.view.addGestureRecognizer(tapGesture)
        
        chatTableView.estimatedRowHeight = 102.0
        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        ChatService.sharedInstance.login({ (success: Bool, error: String?) -> Void in
            if !success {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.showAlert("Login error", message: error!)
                })
            }
        })
        
        
        
        
        // TEST
        messages.append(Message(messageType: Message.MessageType.InText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
        messages.append(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet.", image: nil))
        messages.append(Message(messageType: Message.MessageType.InText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
        messages.append(Message(messageType: Message.MessageType.OutImage, date: NSDate(), text: nil, image: UIImage(named: "Test.png")))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func addButtonHandler(sender: AnyObject) {
        
    }
    
    @IBAction func sendButtonHandler(sender: AnyObject) {
        if (ChatService.sharedInstance.isLogin()) {
            let message: String = messageTextField.text!
            
            if (message.characters.count > 0) {
                ChatService.sharedInstance.sendMessage(message: message, completion: { (message: String?, error: String?) -> Void in
                    if (message != nil) {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.addNewMessage(message!)
                        })
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showAlert("Send message error", message: error!)
                        })
                    }
                })
                
                messageTextField.text = ""
            }
        } else {
            self.showAlert("Send message error", message: "You must login first!")
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                self.keyboardSpaceConstraint?.constant = keyboardRect.height
                self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.keyboardSpaceConstraint?.constant = 0.0
        self.view.layoutIfNeeded()
    }
    
    func hideKeyboard(recognizer: UITapGestureRecognizer) {
        messageTextField.resignFirstResponder()
    }
    
    private func requestOldMessageList() {
        if (ChatService.sharedInstance.isLogin()) {
            let oldestId = (messages.count > 0) ? messages[0].id : 1
            
            ChatService.sharedInstance.loadOldMessages(oldestId, pageSize: 20, completion: { (messageList: [Message]?, error: String?) -> Void in
                if (messageList != nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.addOldMessages(messageList!)
                    })
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.showAlert("Load old messages error", message: error!)
                    })
                }
            })
        }
    }
    
    private func addNewMessage(message: String) {
        
        
//        chatTableView.reloadData()
    }
    
    private func addOldMessages(messageList: [Message]) {
        var newMessageList = [Message]()
        newMessageList.appendContentsOf(messageList)
        newMessageList.appendContentsOf(messages)
        messages = newMessageList
        
        messages.sortInPlace({ ( left, right) -> Bool in
            return left.id < right.id
        })
        
        chatTableView.reloadData()
    }
    
    private func scrollToBottom() {
        let offsetY = chatTableView.contentSize.height - chatTableView.frame.size.height + chatTableView.contentInset.bottom
        UIView.animateWithDuration(0.1, delay: 0.0, options: [.CurveEaseOut, .AllowUserInteraction], animations: { () -> Void in
            self.chatTableView.setContentOffset(CGPoint(x: 0.0, y: offsetY), animated: false)
            }, completion: nil)
    }
    
    private func getCellIdForMessage(message: Message) -> String {
        switch (message.messageType!) {
        case Message.MessageType.InText:
            return "IncomingTextMessageCell"
            
        case Message.MessageType.OutText:
            return "OutgoingTextMessageCell"
            
        case Message.MessageType.OutImage:
            return "OutgoingImageMessageCell"
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            // empty
        }
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion:nil)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(getCellIdForMessage(message), forIndexPath: indexPath) as! MessageCell
        
        cell.setDate(message.date!)
        
        switch (message.messageType!) {
        case Message.MessageType.InText:
            cell.messageTextView.text = message.text!
            cell.userNameLabel.text = "Username"
            break
            
        case Message.MessageType.OutText:
            cell.messageTextView.text = message.text!
            break
            
        case Message.MessageType.OutImage:
            cell.pictureImageView.image = message.image!
            break
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return emptySpace
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == 0) {
            requestOldMessageList()
        }
    }
}





//let textViewMaxSize: CGFloat = 300.0
//
//extension ViewController: UITextViewDelegate {
//    func textViewDidChange(textView: UITextView) {
//        
//        let size = textView.bounds.size
//        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
//        
////        if (size.height != newSize.height) && (newSize.height < textViewMaxSize) {
////            UIView.setAnimationsEnabled(false)
////            messageTextView?.beginUpdates()
////            messageTextView?.endUpdates()
////            UIView.setAnimationsEnabled(true)
////            
////            if let thisIndexPath = tableView?.indexPathForCell(self) {
////                tableView?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
////            }
////        }
//    }
//}