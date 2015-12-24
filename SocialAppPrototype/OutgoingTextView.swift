import UIKit

class OutgoingTextView: UITextView {
    private let rightOffset: CGFloat = 3.0
    private let cornerOffset: CGFloat = 2.0
    private let cornerOffset2: CGFloat = 4.0
    
    private var borderColor = UIColor(colorLiteralRed: 228.0 / 255.0, green: 229.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
    private var backColor = UIColor(colorLiteralRed: 241.0 / 255.0, green: 241.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let width = layer.frame.size.width - 1.0
        let height = layer.frame.size.height - 1.0
        let path = UIBezierPath()
        path.lineWidth = 1.0
        
        path.moveToPoint(CGPoint(x: cornerOffset, y: cornerOffset2))
        path.addLineToPoint(CGPoint(x: cornerOffset2, y: cornerOffset))
        path.addLineToPoint(CGPoint(x: width - rightOffset - cornerOffset2, y: cornerOffset))
        path.addLineToPoint(CGPoint(x: width - rightOffset - cornerOffset, y: cornerOffset2))
        path.addLineToPoint(CGPoint(x: width - rightOffset - cornerOffset, y: (height / 2.0) - rightOffset - 2.0))
        path.addLineToPoint(CGPoint(x: width, y: height / 2.0))
        path.addLineToPoint(CGPoint(x: width - rightOffset - cornerOffset, y: (height / 2.0) + rightOffset + 2.0))
        path.addLineToPoint(CGPoint(x: width - rightOffset - cornerOffset, y: height - cornerOffset))
        path.addLineToPoint(CGPoint(x: width - rightOffset - cornerOffset2, y: height))
        path.addLineToPoint(CGPoint(x: cornerOffset2, y: height))
        path.addLineToPoint(CGPoint(x: cornerOffset, y: height - cornerOffset))
        path.addLineToPoint(CGPoint(x: cornerOffset, y: cornerOffset2))
        
        backColor.setFill()
        path.fill()
        
        borderColor.setStroke()
        path.stroke()
    }
}