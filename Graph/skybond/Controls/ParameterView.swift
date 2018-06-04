//
//  ParameterView.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit

protocol ParameterViewDelegate: class {
    func parameterViewDidSelectYield()
    func parameterViewDidSelectPrice()
}

class ParameterView: UIView {
    
    weak var delegate: ParameterViewDelegate?
    
    @IBOutlet private var yieldButtonTop: NSLayoutConstraint!
    @IBOutlet private var priceButtonBottom: NSLayoutConstraint!
    @IBOutlet private var height: NSLayoutConstraint!
    
    private var isRevealed = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 22
        
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.8
        
    }
    
    private func reveal(_ animated: Bool = true) {
        height.isActive = false
        yieldButtonTop.isActive = true
        priceButtonBottom.isActive = true
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
        isRevealed = true
    }
    
    // MARK: actions
    @IBAction func yieldButtonDidTouchUpInside(_ sender: UIButton) {
        guard isRevealed else {
            reveal()
            return
        }
        priceButtonBottom.isActive = false
        unreveal()
        delegate?.parameterViewDidSelectYield()
    }
    
    @IBAction func priceButtonDidTouchUpInside(_ sender: UIButton) {
        guard isRevealed else {
            reveal()
            return
        }
        yieldButtonTop.isActive = false
        unreveal()
        delegate?.parameterViewDidSelectPrice()
    }
    
    private func unreveal(_ animated: Bool = true) {
        height.isActive = true
        isRevealed = false
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

}
