//
//  MarkerView.swift
//  Education
//
//  Created by Andrey Medvedev on 03/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import UIKit

class MarkerView: UIView {
    var flagInset = CGFloat.leastNormalMagnitude
    var flagColor = UIColor.clear

    private var coloredLayer = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutMask()
    }

    private func layoutMask() {
        if self.coloredLayer.superlayer == nil {
            self.layer.insertSublayer(self.coloredLayer, at: 0)
        }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX - self.flagInset,
                                 y: bounds.maxY / 2))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        path.closeSubpath()
        self.coloredLayer.path = path
        self.coloredLayer.fillColor = self.flagColor.cgColor
    }
}
