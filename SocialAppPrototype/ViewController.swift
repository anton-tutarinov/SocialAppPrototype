import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var keyboardSpaceConstraint: NSLayoutConstraint!
    
    private var emptySpace: CGFloat = 0.0
    private var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        self.view.addGestureRecognizer(tapGesture)
        
//        chatTableView.rowHeight = UITableViewAutomaticDimension
        
//        messages.append(Message(messageType: Message.MessageType.InText, date: NSDate(), text: "incoming", image: nil, sender: nil))
        messages.append(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "", image: nil, sender: nil))
//        messages.append(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "", image: nil, sender: nil))
//        messages.append(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "", image: nil, sender: nil))
//        messages.append(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "", image: nil, sender: nil))
//        messages.append(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "", image: nil, sender: nil))
//        messages.append(Message(messageType: Message.MessageType.OutText, date: NSDate(), text: "", image: nil, sender: nil))
        
        chatTableView.reloadData()
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
        let message: String = messageTextField.text!
        debugLog("message: \(message)")
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
    
    private func addNewMessage() {
        
    }
    
    private func addOldMessage() {
        
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
            cell.textLabel?.text = message.text!
            break
            
        case Message.MessageType.OutText:
            cell.textLabel?.text = message.text!
            break
            
        case Message.MessageType.OutImage:
            
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