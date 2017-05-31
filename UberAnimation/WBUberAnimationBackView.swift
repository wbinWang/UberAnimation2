//
//  WBUberAnimationBackView.swift
//  UberAnimation
//
//  Created by wenbin on 2017/5/27.
//  Copyright © 2017年 beautyWang. All rights reserved.
//

import UIKit
import Contacts
class WBUberAnimationBackView: UIView {
    
    fileprivate var containerView: UIView!
    fileprivate var modelTileView: WBTileImgView!
    fileprivate var centerTileView: WBTileImgView? = nil
    fileprivate var numberOfRows = 0
    fileprivate var numberOfColumns = 0
    
    fileprivate var logoLabel: UILabel!
    fileprivate var tileViewRows: [[WBTileImgView]] = []
    fileprivate var beginTime: CFTimeInterval = 0
    fileprivate let kRippleDelayMultiplier: TimeInterval = 0.0006666
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.center = center
        modelTileView.center = containerView.center
        if let centerTileView = centerTileView {
            // Custom offset needed for UILabel font
            let center = CGPoint(x: centerTileView.bounds.midX + 31, y: centerTileView.bounds.midY)
            logoLabel.center = center
        }
    }
    
    override init(frame: CGRect) {
        modelTileView = WBTileImgView.init(tileImgName: "Chimes")
        super.init(frame: frame)
        clipsToBounds = true
        layer.masksToBounds = true
        
        containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 630.0, height: 990.0))
        containerView.backgroundColor = UIColor.theme()
        containerView.clipsToBounds = false
        containerView.layer.masksToBounds = false
        addSubview(containerView)
        
        renderTileViews()
        
        logoLabel = generateLogoLabel()
        centerTileView?.addSubview(logoLabel)
        layoutIfNeeded()
    }

    func startAnimating() {
        beginTime = CACurrentMediaTime()
        startAnimatingWithBeginTime(beginTime)
    }
}
    
extension WBUberAnimationBackView {
    
    fileprivate func generateLogoLabel()->UILabel {
        let label = UILabel()
        label.text = "F         BER"
        label.font = UIFont.systemFont(ofSize: 50)
        label.textColor = UIColor.white
        label.sizeToFit()
        label.center = CGPoint(x: bounds.midX, y: bounds.midY)
        return label
    }
    
    fileprivate func renderTileViews() {
        let width = containerView.bounds.width
        let height = containerView.bounds.height
        
        let modelImageWidth = modelTileView.bounds.width
        let modelImageHeight = modelTileView.bounds.height
        
        numberOfColumns = Int(ceil((width - modelTileView.bounds.size.width / 2.0) / modelTileView.bounds.size.width))
        numberOfRows = Int(ceil((height - modelTileView.bounds.size.height / 2.0) / modelTileView.bounds.size.height))
        
        for y in 0..<numberOfRows {
            
            var tileRows: [WBTileImgView] = []
            for x in 0..<numberOfColumns {
                
                let view = WBTileImgView()
                view.frame = CGRect(x: CGFloat(x) * modelImageWidth, y:CGFloat(y) * modelImageHeight, width: modelImageWidth, height: modelImageHeight)
                
                if view.center == containerView.center {
                    centerTileView = view
                }
                
                containerView.addSubview(view)
                tileRows.append(view)
                
                if y != 0 && y != numberOfRows - 1 && x != 0 && x != numberOfColumns - 1 {
                    view.shouldEnableRipple = true
                }
            }
            
            tileViewRows.append(tileRows)
        }
        
        if let centerTileView = centerTileView {
            containerView.bringSubview(toFront: centerTileView)
        }
    }
    
    fileprivate func startAnimatingWithBeginTime(_ beginTime: TimeInterval) {
        
        let linearTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        let keyframe = CAKeyframeAnimation(keyPath: "transform.scale")
        keyframe.timingFunctions = [linearTimingFunction, CAMediaTimingFunction(controlPoints: 0.6, 0.0, 0.15, 1.0), linearTimingFunction]
        keyframe.repeatCount = Float.infinity;
        keyframe.duration = kAnimationDuration
        keyframe.isRemovedOnCompletion = false
        keyframe.keyTimes = [0.0, 0.45, 0.887, 1.0]
        keyframe.values = [0.75, 0.75, 1.0, 1.0]
        keyframe.beginTime = beginTime
        keyframe.timeOffset = kAnimationTimeOffset
        
        containerView.layer.add(keyframe, forKey: "scale")
        
        for tileRows in tileViewRows {
            for view in tileRows {
                
                let distance = distanceFromCenterViewWithView(view)
                var vector = normalizedVectorFromCenterViewToView(view)
                
                vector = CGPoint(x: vector.x * kRippleMagnitudeMultiplier * distance, y: vector.y * kRippleMagnitudeMultiplier * distance)
                
                view.startAnimationWithDuration(kAnimationDuration, beginTime: beginTime, rippleDelay: kRippleDelayMultiplier * TimeInterval(distance), rippleOffset: vector)
            }
        }
    }
    
    fileprivate func distanceFromCenterViewWithView(_ view: UIView)->CGFloat {
        guard let centerTileView = centerTileView else { return 0.0 }
        
        let normalizedX = (view.center.x - centerTileView.center.x)
        let normalizedY = (view.center.y - centerTileView.center.y)
        return sqrt(normalizedX * normalizedX + normalizedY * normalizedY)
    }
    
    fileprivate func normalizedVectorFromCenterViewToView(_ view: UIView)->CGPoint {
        let length = distanceFromCenterViewWithView(view)
        guard let centerTileView = centerTileView , length != 0 else { return CGPoint.zero }
        
        let deltaX = view.center.x - centerTileView.center.x
        let deltaY = view.center.y - centerTileView.center.y
        return CGPoint(x: deltaX / length, y: deltaY / length)
    }
}

