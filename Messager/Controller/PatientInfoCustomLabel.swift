//
//  PatientInfoCustomLabel.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/11.
//

import UIKit

//实现label文字从左上角开始显示
class PatientInfoCustomLabel: UILabel {

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
            var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
            textRect.origin.y = bounds.origin.y
            return textRect
        }
        
        override func drawText(in rect: CGRect) {
            let actualRect = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
            super.drawText(in: actualRect)
        }

}
