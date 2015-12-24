import Foundation
import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    private let avatarBorderColor = UIColor(colorLiteralRed: 223.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (userAvatarImageView != nil) {
            userAvatarImageView.layer.borderWidth = 1
            userAvatarImageView.layer.cornerRadius = 3
            userAvatarImageView.layer.borderColor = avatarBorderColor.CGColor
        }
        
        if (messageTextView != nil) {
            if (userAvatarImageView != nil) && (userNameLabel != nil) {
                messageTextView.textContainerInset = UIEdgeInsetsMake(12, 15, 12, 26)
            } else {
                messageTextView.textContainerInset = UIEdgeInsetsMake(18, 20, 14, 28)
            }
        }
        
        if (pictureImageView != nil) {
            pictureImageView.layer.cornerRadius = 3
        }
    }
    
    func setDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
}