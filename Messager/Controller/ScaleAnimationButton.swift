//
//  ScaleAnimationButton.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/20.
//

import UIKit

class ScaleAnimationButton: UIButton{
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        //添加一个点击事件
        addTarget(self, action: #selector(toggleSelected), for: .touchUpInside)
    }
    
    @objc func toggleSelected() {
        isSelected.toggle()
    }
    
    override var isSelected: Bool{
        get{
            super.isSelected
        }
        set{
            super.transform = .init(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
                super.isSelected = newValue
                super.transform = .identity
            })
        }
    }
}
