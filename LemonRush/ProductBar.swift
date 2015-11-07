//
//  ProductView.swift
//  Lemon Rush
//
//  Created by Christopher Scalcucci on 11/5/15.
//  Copyright © 2015 Christopher Scalcucci. All rights reserved.
//

import UIKit
import SpriteKit

@IBDesignable class ProductBar : UIView {

    @IBInspectable var counter: CGFloat = 0 {
        didSet {
            if counter <=  capacity {
                //the view needs to be refreshed
                setNeedsDisplay()
            }
        }
    }

    @IBInspectable var fillColor: UIColor = UIColor.greenColor()
    @IBInspectable var borderColor: UIColor = UIColor.redColor()
    @IBInspectable var borderWidth: CGFloat = 4

    var capacity : CGFloat = 100

    override func drawRect(rect: CGRect) {

        let path = UIBezierPath(rect: rect)
        path.lineWidth = borderWidth
        borderColor.setStroke()
        path.stroke()

        //    let rectX = borderWidth
        //    let rectY : CGFloat = (bounds.height - borderWidth) - (bounds.height - borderWidth) * (counter / capacity)
        //    let rectWidth = bounds.width - (borderWidth * 2)
        //    let rectHeight : CGFloat = (bounds.height * (counter / capacity)) - borderWidth
        //    let rectangle = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
        //
        //
        //    let fillRect = UIBezierPath(rect: rectangle)
        //    fillColor.setStroke()
        //    fillRect.stroke()

        let fillHeight: CGFloat = (bounds.height - (bounds.height * (counter / capacity)))
        let fillWidth: CGFloat = (bounds.width - (borderWidth * 2))

        let fillPath = UIBezierPath()

        fillPath.moveToPoint(CGPoint(
            x: (bounds.width / 2),
            y: bounds.height - borderWidth))

        fillPath.addLineToPoint(CGPoint(x: bounds.width / 2, y: fillHeight))

        fillColor.setStroke()
        fillPath.lineWidth = fillWidth
        fillPath.stroke()
    }
}
