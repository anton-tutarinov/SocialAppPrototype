import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomPanel: UIView!
    
    @IBOutlet weak var keyboardSpaceConstraint: NSLayoutConstraint!
    
    private var verticalOffset: CGFloat = 0.0
    private var messages = [Message]()
    
    private var imageList = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        view.addGestureRecognizer(tapGesture)
        
        chatTableView.estimatedRowHeight = 102.0
        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        ChatService.sharedInstance.login()
        
        //TEST
        imageList["Test"] = UIImage(named: "Test")
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
        notificationCenter.addObserver(self, selector: Selector("loadOldMessageListResultNotification:"), name: ChatService.loadOldMessageListResultNotification, object: nil)
        
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
        verticalOffset = chatTableView.frame.size.height
        
        // TEST
        addNewMessage(Message(messageId: 1, messageType: Message.MessageType.InText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit.", imageUrl: nil))
        addNewMessage(Message(messageId: 2, messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet.", imageUrl: nil))
        addNewMessage(Message(messageId: 3, messageType: Message.MessageType.InText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit.", imageUrl: nil))
        addNewMessage(Message(messageId: 4, messageType: Message.MessageType.OutImage, date: NSDate(), text: nil, imageUrl: "Test"))
        
//        addNewMessage(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
//        addNewMessage(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
//        addNewMessage(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit. Lorem ipsum dolor sit amet, consect adipiscing elit.", image: nil))
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        
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
            if result == false, let error = userInfo["error"] as? String {
                showAlert(title: "Login error", message: error)
            }
        }
    }
    
    func sendMessageResultNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let message = userInfo["message"] as? String {
            
            // TEST
            var lastId = 0
            
            if messages.count > 0 {
                lastId = messages[messages.count - 1].id
            }
            
            addNewMessage(Message(messageId: lastId + 1, messageType: Message.MessageType.OutText, date: NSDate(), text: message, imageUrl: nil))
        } else if let error = userInfo["error"] as? String {
            showAlert(title: "Send message error", message: error)
        }
    }
    
    func loadOldMessageListResultNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let messageList = userInfo["messageList"] as? [Message]? {
            addOldMessageList(messageList!)
        } else if let error = userInfo["error"] as? String {
            showAlert(title: "Load old messages error", message: error)
        }
    }
    
    func imageDownloaderSuccessNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let _ = userInfo["object"] as? MessageCell, let imageUrl = userInfo["imageUrl"] as? String {
            imageList[imageUrl] = UIImage.loadFromSDCard(imageUrl)
            chatTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }
    
    func imageDownloaderFailureNotification(notification: NSNotification) {
        
    }
    
    func hideKeyboard(recognizer: UITapGestureRecognizer) {
        messageTextField.resignFirstResponder()
    }
    
    private func requestOldMessageList() {
        if (ChatService.sharedInstance.isLogin()) {
            let oldestId = (messages.count > 0) ? messages[0].id : 1
            ChatService.sharedInstance.loadOldMessageList(oldestId: oldestId, pageSize: 20)
        }
    }
    
    private func addNewMessage(message: Message) {
        let cell = chatTableView.dequeueReusableCellWithIdentifier(getCellIdForMessage(message)) as! MessageCell
        
        fillCellWithMessage(cell: cell, message: message)
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        verticalOffset -= size.height
        
        messages.append(message)
        chatTableView.reloadData()
        chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
    }
    
    private func addOldMessageList(messageList: [Message]) {
        for msg in messageList {
            let cell = chatTableView.dequeueReusableCellWithIdentifier(getCellIdForMessage(msg)) as! MessageCell
            fillCellWithMessage(cell: cell, message: msg)
            let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            verticalOffset -= size.height
        }
        
        var newMessageList = [Message]()
        newMessageList.appendContentsOf(messageList)
        newMessageList.appendContentsOf(messages)
        messages = newMessageList
        
        messages.sortInPlace({ ( left, right) -> Bool in
            return left.id < right.id
        })
        
        chatTableView.reloadData()
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
    
    private func fillCellWithMessage(cell cell: MessageCell, message: Message) {
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
        return (verticalOffset > 0.0 ? verticalOffset : 0.0)
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
            requestOldMessageList()
        }
    }
}