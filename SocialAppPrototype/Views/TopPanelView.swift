import UIKit

class TopPanelView: UIView {
    private let borderColor = UIColor(colorLiteralRed: 240.0 / 255.0, green: 240.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0).CGColor
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let border = CALayer()
        border.frame = CGRect(x: 0.0, y: frame.size.height - 2.0, width:  frame.size.width, height: 2.0)
        border.backgroundColor = borderColor
        
        layer.addSublayer(border)
    }
}