//
//  TextBubbleView.swift
//  HNTaxi
//
//  Created by Tbxark on 15/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class TextBubbleView: UIView {
    private let textLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.darkGray
        $0.textAlignment = .center
    }
    
    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }

    func shareInit() {
        backgroundColor = UIColor.clear
        addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
        }
        textLabel.text = "在这上车"
    }

    func setText(_ string: String) -> CGFloat {
        textLabel.text = string
        let width = (string as NSString).size(attributes: [NSFontAttributeName: textLabel.font]).width + R.Margin.large * 2
        return width
    }

    override func draw(_ rect: CGRect) {
        let color = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let lineWidth: CGFloat = 1
        let arrowSize  = CGSize(width: 8, height: 10)
        let w = rect.width
        let h = rect.height
    
        let bgPathPath = UIBezierPath()
        bgPathPath.move(to: CGPoint(x: lineWidth, y: lineWidth))
        bgPathPath.addLine(to: CGPoint(x: w - lineWidth, y: 1))
        bgPathPath.addLine(to: CGPoint(x: w - lineWidth, y: h - lineWidth - arrowSize.height))
        
        bgPathPath.addLine(to: CGPoint(x: w/2 + arrowSize.width, y: h - lineWidth - arrowSize.height))
        bgPathPath.addLine(to: CGPoint(x: w/2, y: h - lineWidth))
        bgPathPath.addLine(to: CGPoint(x: w/2 - arrowSize.width, y: h - lineWidth - arrowSize.height))
        
        bgPathPath.addLine(to: CGPoint(x: lineWidth, y: h - lineWidth - arrowSize.height))
        bgPathPath.addLine(to: CGPoint(x: lineWidth, y: lineWidth))
        bgPathPath.close()
        color.setFill()
        bgPathPath.fill()
        UIColor(white: 0.95, alpha: 1).setStroke()
        bgPathPath.lineWidth = 0.5
        bgPathPath.lineJoinStyle = .round
        bgPathPath.stroke()
    }
}
