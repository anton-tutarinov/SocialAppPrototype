import UIKit

class IncomingImageHolderView: UIView {
    private let leftOffset: CGFloat = 5.0
    private let cornerOffset: CGFloat = 2.0
    private let cornerOffset2: CGFloat = 4.0
    
    private let borderColor = UIColor(colorLiteralRed: 228.0 / 255.0, green: 229.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
    private let backColor = UIColor.whiteColor()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let width = layer.frame.size.width - 1.0
        let height = layer.frame.size.height - 1.0
        let path = UIBezierPath()
        path.lineWidth = 1.0
        
        path.moveToPoint(CGPoint(x: leftOffset + cornerOffset, y: cornerOffset2))
        path.addLineToPoint(CGPoint(x: leftOffset + cornerOffset2, y: cornerOffset))
        path.addLineToPoint(CGPoint(x: width - cornerOffset, y: cornerOffset))
        path.addLineToPoint(CGPoint(x: width, y: cornerOffset2))
        path.addLineToPoint(CGPoint(x: width, y: height - cornerOffset))
        path.addLineToPoint(CGPoint(x: width - cornerOffset, y: height))
        path.addLineToPoint(CGPoint(x: leftOffset + cornerOffset2, y: height))
        path.addLineToPoint(CGPoint(x: leftOffset + cornerOffset, y: height - cornerOffset))
        path.addLineToPoint(CGPoint(x: leftOffset + cornerOffset, y: ((height / 2.0) + leftOffset)))
        path.addLineToPoint(CGPoint(x: cornerOffset, y: height / 2.0))
        path.addLineToPoint(CGPoint(x: leftOffset + cornerOffset, y: ((height / 2.0) - leftOffset)))
        path.addLineToPoint(CGPoint(x: leftOffset + cornerOffset, y: cornerOffset2))
        
        backColor.setFill()
        path.fill()
        
        borderColor.setStroke()
        path.stroke()
    }
}