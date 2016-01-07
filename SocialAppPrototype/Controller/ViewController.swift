import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomPanel: UIView!
    
    @IBOutlet weak var keyboardSpaceConstraint: NSLayoutConstraint!
    
    private var topOffset: CGFloat = 0.0
    private var messages = [Message]()
    
    private var imageList = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        view.addGestureRecognizer(tapGesture)
        
        chatTableView.estimatedRowHeight = 128.0
        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        ChatService.sharedInstance.login()
        
        //TEST
//        imageList["Test"] = UIImage(named: "Test")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        imageList.removeAll()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: Selector("loginResultNotification:"), name: ChatService.loginResultNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("sendMessageResultNotification:"), name: ChatService.sendMessageResultNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("loadMessageListResultNotification:"), name: ChatService.loadMessageListResultNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: Selector("imageDownloaderSuccessNotification:"), name: ImageDownloader.successNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("imageDownloaderFailureNotification:"), name: ImageDownloader.failureNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        topOffset = chatTableView.frame.size.height
        
        // TEST
//        addNewMessage(Message(messageId: 1, messageType: Message.MessageType.InText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit.", imageUrl: nil))
//        addNewMessage(Message(messageId: 2, messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet.", imageUrl: nil))
//        addNewMessage(Message(messageId: 3, messageType: Message.MessageType.InText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit.", imageUrl: nil))
//        addNewMessage(Message(messageId: 4, messageType: Message.MessageType.OutImage, date: NSDate(), text: nil, imageUrl: "Test"))
        
//        addNewMessage(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
//        addNewMessage(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
//        addNewMessage(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        if (ChatService.sharedInstance.isLogin()) {
            let message: String = messageTextField.text!
            
            if (message.characters.count > 0) {
                ChatService.sharedInstance.sendMessage(message: message)
                
                messageTextField.text = ""
                messageTextField.resignFirstResponder()
            }
        } else {
            showAlert(title: "Send message error", message: "You must login first!")
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardSpaceConstraint?.constant = keyboardRect.height
                view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        keyboardSpaceConstraint?.constant = 0.0
        view.layoutIfNeeded()
    }
    
    func loginResultNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let result = userInfo["result"] as? Bool {
            if result == true {
                var oldestId: UInt = 0
                
                if messages.count > 0 {
                    oldestId = messages[0].id
                }
                
                ChatService.sharedInstance.loadMessageList(oldestId: oldestId, pageSize: 20)
            } else if let error = userInfo["error"] as? String {
                showAlert(title: "Login error", message: error)
            }
        }
    }
    
    func sendMessageResultNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let result = userInfo["result"] as? Bool {
            if result == true {
                ChatService.sharedInstance.loadMessageList(oldestId: 0, pageSize: 1)
            } else if let error = userInfo["error"] as? String {
                showAlert(title: "Send message error", message: error)
            }
        } else if let error = userInfo["error"] as? String {
            showAlert(title: "Send message error", message: error)
        }
    }
    
    func loadMessageListResultNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let messageList = userInfo["messageList"] as? [Message] {
            if (messageList.count > 0) {
                addMessageList(messageList)
            }
        } else if let error = userInfo["error"] as? String {
            showAlert(title: "Load old messages error", message: error)
        }
    }
    
    func imageDownloaderSuccessNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if /*let _ = userInfo["object"] as? MessageCell,*/ let imageUrl = userInfo["imageUrl"] as? String {
            imageList[imageUrl] = UIImage.loadFromDisk(imageUrl)
            chatTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }
    
    func imageDownloaderFailureNotification(notification: NSNotification) {
        debugLog("image download failed")
    }
    
    func hideKeyboard(recognizer: UITapGestureRecognizer) {
        messageTextField.resignFirstResponder()
    }
    
    private func requestMessageList() {
        if (ChatService.sharedInstance.isLogin()) {
            let oldestId = (messages.count > 0) ? messages[0].id : 1
            ChatService.sharedInstance.loadMessageList(oldestId: oldestId, pageSize: 20)
        }
    }
    
//    private func addNewMessage(message: Message) {
//        let cell = chatTableView.dequeueReusableCellWithIdentifier(getCellIdForMessage(message)) as! MessageCell
//        
//        fillCellWithMessage(cell: cell, message: message)
//        
//        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//        topOffset -= size.height
//        
//        messages.append(message)
//        chatTableView.reloadData()
//        chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
//    }
    
    private func addMessageList(messageList: [Message]) {
        if (topOffset > 0) {
            for msg in messageList {
                let cell = chatTableView.dequeueReusableCellWithIdentifier(getCellIdForMessage(msg)) as! MessageCell
                fillCellWithMessage(cell: cell, message: msg)
                let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                topOffset -= size.height
                
                if (topOffset < 0) {
                    break
                }
            }
        }
        
        var newMessageList = [Message]()
        newMessageList.appendContentsOf(messageList)
        newMessageList.appendContentsOf(messages)
        messages = newMessageList
        
        messages.sortInPlace({ ( left, right) -> Bool in
            return left.date!.compare(right.date!) == NSComparisonResult.OrderedAscending
        })
        
        chatTableView.reloadData()
        chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
    }
    
    private func getCellIdForMessage(message: Message) -> String {
        switch (message.messageType!) {
        case Message.MessageType.InText:
            return "IncomingTextMessageCell"
            
        case Message.MessageType.InImage:
            return "IncomingImageMessageCell"
            
        case Message.MessageType.OutText:
            return "OutgoingTextMessageCell"
            
        case Message.MessageType.OutImage:
            return "OutgoingImageMessageCell"
        }
    }
    
    private func fillCellWithMessage(cell cell: MessageCell, message: Message) {
        cell.setDate(message.date!)
        
        switch (message.messageType!) {
        case Message.MessageType.InText:
            cell.messageTextView.text = message.text!
            cell.userNameLabel.text = message.sender?.name
            break
            
        case Message.MessageType.InImage:
            cell.userNameLabel.text = message.sender?.name
            
            if let image = imageList[message.imageUrl!] {
                cell.pictureImageView.image = image
            } else {
                ImageDownloader.sharedInstance.download(url: message.imageUrl!, object: cell)
            }
            
            break
            
        case Message.MessageType.OutText:
            cell.messageTextView.text = message.text!
            break
            
        case Message.MessageType.OutImage:
            if let image = imageList[message.imageUrl!] {
                cell.pictureImageView.image = image
            } else {
                ImageDownloader.sharedInstance.download(url: message.imageUrl!, object: cell)
            }
            
            break
        }
    }
    
    private func showAlert(title title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            // empty
        }
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion:nil)
    }
    
//    private func scrollToBottom() {
//        let delay = 0.1 * Double(NSEC_PER_SEC)
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        
//        dispatch_after(time, dispatch_get_main_queue(), {
//            
//            let numberOfSections = self.chatTableView.numberOfSections
//            let numberOfRows = self.chatTableView.numberOfRowsInSection(numberOfSections - 1)
//            
//            if numberOfRows > 0 {
//                let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: (numberOfSections - 1))
//                self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
//            }
//        })
//    }
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
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        fillCellWithMessage(cell: cell, message: message)
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (topOffset > 0.0 ? topOffset : 0.0)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == 0) {
            requestMessageList()
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let width = pickedImage.size.width
            let height = pickedImage.size.height
            
            if (width <= 200 && height <= 200) {
                
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}