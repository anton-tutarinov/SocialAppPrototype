import UIKit

class MessageTextField: UITextField {
    private let borderColor = UIColor(colorLiteralRed: 240.0 / 255.0, green: 240.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0).CGColor
    private let sideBorderSize: CGFloat = 9.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height:  frame.size.height))
        leftViewMode = UITextFieldViewMode.Always
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height:  frame.size.height))
        leftViewMode = UITextFieldViewMode.Always
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: frame.size.height - 2.0, width:  frame.size.width, height: 2.0)
        bottomBorder.backgroundColor = borderColor
        
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0.0, y: frame.size.height - sideBorderSize, width:  1, height: sideBorderSize)
        leftBorder.backgroundColor = borderColor
        
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: frame.size.width - 1.0, y: frame.size.height - sideBorderSize, width:  1.0, height: sideBorderSize)
        rightBorder.backgroundColor = borderColor
        
        layer.addSublayer(bottomBorder)
        layer.addSublayer(leftBorder)
        layer.addSublayer(rightBorder)
    }
}