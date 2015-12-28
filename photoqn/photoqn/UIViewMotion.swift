//
//  UIViewMotion.swift
//  photoqn
//
//  Created by 梅基史篤 on 2015/12/27.
//  Copyright © 2015年 ume. All rights reserved.
//

import Foundation
import UIKit

enum FadeType: NSTimeInterval {
    case
    Normal = 0.2,
    Slow = 0.8
}

extension UIView {
    func fadeIn(type: FadeType = .Normal, completed: (() -> ())? = nil) {
        fadeIn(type.rawValue, completed: completed)
    }
    
    /** For typical purpose, use "public func fadeIn(type: FadeType = .Normal, completed: (() -> ())? = nil)" instead of this */
    func fadeIn(duration: NSTimeInterval = FadeType.Slow.rawValue, completed: (() -> ())? = nil) {
        alpha = 0
        hidden = false
        UIView.animateWithDuration(duration,
            animations: {
                self.alpha = 1
            }) { finished in
                completed?()
        }
    }
    func fadeOut(type: FadeType = .Normal, completed: (() -> ())? = nil) {
        fadeOut(type.rawValue, completed: completed)
    }
    /** For typical purpose, use "public func fadeOut(type: FadeType = .Normal, completed: (() -> ())? = nil)" instead of this */
    func fadeOut(duration: NSTimeInterval = FadeType.Slow.rawValue, completed: (() -> ())? = nil) {
        UIView.animateWithDuration(duration
            , animations: {
                self.alpha = 0
            }) { [weak self] finished in
                self?.hidden = true
                self?.alpha = 1
                completed?()
        }
    }
}