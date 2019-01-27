//
//  LoadingView.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/27/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//
//  --
//
//  charLoadingView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    fileprivate var shouldContinue = false
    fileprivate var exemptFrames: [CGRect]?
    var charColor: UIColor! {
        didSet {
            self.charColorSet = [self.charColor]
        }
    }
    var charColorSet: [UIColor]!
    
    var charRepeatInterval: TimeInterval = 0.3
    var charFadeDuration: TimeInterval = 0.5
    
    init(frame: CGRect, exemptFrames: CGRect...) {
        super.init(frame: frame)
        self.exemptFrames = exemptFrames
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.charColor = Constants.beige
    }
    
    func addExemptFrames(_ exemptFrames: CGRect...) {
        if self.exemptFrames != nil {
            self.exemptFrames!.append(contentsOf: exemptFrames)
        } else {
            self.exemptFrames = exemptFrames
        }
        
        if let frames = self.exemptFrames {
            print("EXEMPT FRAMES:", frames)
        }
    }
    
    func startAnimating() {
        self.isHidden = false
        self.shouldContinue = true
        self.animateChars()
    }
    
    func stopAnimating() {
        self.shouldContinue = false
    }
}


// MARK: - Helpers

extension LoadingView {
    
    // TODO: SILENCE WARNING vv
    
    fileprivate func animateChars() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            var colorIndex = 0
            while self.shouldContinue {
                DispatchQueue.main.async(execute: {
                    self.addcharLabel(color: self.charColorSet[colorIndex])
                })
                // let interval = 0.4 + Double(arc4random()) / Double(UInt32.max) * 0.1
                Thread.sleep(forTimeInterval: self.charRepeatInterval)
                colorIndex = colorIndex % self.charColorSet.count
            }
        }
    }
    
    fileprivate func addcharLabel(color: UIColor) {
        
        print("ADD CHAR LABEL")
        
        let char = self.charLabel(color: color)
        char.alpha = 0
        self.addSubview(char)
        let fadeDuration: TimeInterval = self.charFadeDuration
        UIView.animate(withDuration: fadeDuration, animations: {
            char.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: fadeDuration, animations: {
                char.alpha = 0
            }, completion: { _ in
                char.removeFromSuperview()
            })
        })
    }
    
    // Returns label containing a single unicode character with random origin within this view's bounds.
    fileprivate func charLabel(color: UIColor) -> UILabel {
        let charLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        charLabel.text = "•"
        charLabel.textColor = color
        charLabel.font = UIFont.systemFont(ofSize: 42)
        charLabel.sizeToFit()
        charLabel.frame = self.randomFrameWithSize(charLabel.bounds.size)
        return charLabel
    }
    
    fileprivate func randomFrameWithSize(_ size: CGSize) -> CGRect {
        var randomFrame: CGRect!
        if let exemptFrames = self.exemptFrames {
            var intersectsExemptFrame = false
            repeat {
                randomFrame = self.generateRandomFrameWithSize(size)
                exemptFrames.forEach({ intersectsExemptFrame = $0.intersects(randomFrame) })
            } while intersectsExemptFrame
        } else {
            randomFrame = self.generateRandomFrameWithSize(size)
        }
        return randomFrame
    }
    
    fileprivate func generateRandomFrameWithSize(_ size: CGSize) -> CGRect {
        let maxWidth = self.frame.width - size.width
        let maxHeight = self.frame.height - size.height
        let randomX = CGFloat(arc4random()) / CGFloat(UInt32.max) * maxWidth
        let randomY = CGFloat(arc4random()) / CGFloat(UInt32.max) * maxHeight
        return CGRect(x: randomX, y: randomY, width: size.width, height: size.height)
    }
}

