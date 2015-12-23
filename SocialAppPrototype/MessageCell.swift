import Foundation
import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
}