//
//  File.swift
//  DigitalOceanTB
//
//  Created by Boris Chirino on 01/11/2018.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

/// Provide a spinner to indicate activity
class DOHUD : UIView{
    
    //MARK: - iVars
    
    fileprivate static let sharedView = DOHUD()
    
    fileprivate static let screenBounds : CGRect = UIScreen.main.bounds
    
    
    /// Future implementation
    fileprivate lazy var controlView : UIControl  = {
        let _controlView = UIControl(frame: DOHUD.screenBounds)
        _controlView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _controlView.backgroundColor = UIColor.clear
        _controlView.isUserInteractionEnabled = true
        _controlView.addTarget(self, action: #selector(controlViewDidReceiveTouchEvent(sender:)), for: .touchDown)
        return _controlView
    }()
    
    
    
    /// Activity / progress indicator
    fileprivate lazy var activityView : UIView = {
        let _ringView = UIActivityIndicatorView(style: .whiteLarge)
        _ringView.startAnimating()
        _ringView.translatesAutoresizingMaskIntoConstraints = false
        _ringView.hidesWhenStopped = true
        _ringView.color = .black
        return _ringView
    }()
    
    
    
    
    /// Square view wich contain the progress
    fileprivate lazy var hudView : UIVisualEffectView  = {
        let blur = UIBlurEffect(style: .light)
        let _hudView = UIVisualEffectView(effect: blur)
        _hudView.translatesAutoresizingMaskIntoConstraints = false
        _hudView.backgroundColor = .gray
        _hudView.layer.masksToBounds = true
        _hudView.layer.cornerRadius = 10
        return _hudView
    }()
    
    
    
    /// Used to interrogate windows top control
    fileprivate var frontWindow : UIWindow? {
        let _allWindows = UIApplication.shared.windows
        let reversedWindowOrders = _allWindows.reversed()
        
        var w :UIWindow? = nil
        reversedWindowOrders.forEach { (window) in
            let onMainScreen = window.screen == UIScreen.main
            let onVisible = !window.isHidden && window.alpha > 0
            let keyWindow = window.isKeyWindow
            
            if (onMainScreen && onVisible  && keyWindow) {
                w = window;
            }
        }
        return w
    }
    
    
    
    //MARK: - Lifecycle
    
    fileprivate init(){
        super.init(frame: DOHUD.screenBounds)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Actions
    @objc fileprivate func controlViewDidReceiveTouchEvent(sender :UIEvent) {
        
    }
    
    
    
    
    //MARK: Class methods
    
    class func show(){
        DispatchQueue.main.async {
            self.sharedView.show()
        }
    }
    
    
    class func hide(){
        self.sharedView.hide()
    }
    
    
    
    
    //MARK: Instance methods
    
    fileprivate func show() {
        self.assembleHirerarchy()
    }
    
    
    fileprivate func hide(){
        DispatchQueue.main.async {
            self.activityView.removeFromSuperview()
            self.hudView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    
    
    fileprivate func assembleHirerarchy(){
        if let controlSuperView = self.frontWindow {
            self.hudView.contentView.addSubview(self.activityView)
            
            if self.hudView.superview  == nil {
                self.addSubview(self.hudView)
            }
            
            
            controlSuperView.addSubview(self)
            
        }else {
            self.controlView.superview?.bringSubviewToFront(self.controlView)
        }
        
        if self.superview == nil {
            self.controlView.addSubview(self)
        }
        
        self.setNeedsUpdateConstraints()
    }
    
    
    
    
    override func updateConstraints() {
        
        self.hudView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.hudView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.hudView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.hudView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        self.activityView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.activityView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.activityView.centerXAnchor.constraint(equalTo: self.hudView.centerXAnchor).isActive = true
        self.activityView.centerYAnchor.constraint(equalTo: self.hudView.centerYAnchor).isActive = true
        super.updateConstraints()
    }
}
