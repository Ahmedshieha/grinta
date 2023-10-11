//
//  UiView.swift
//  GrintaTask
//
//  Created by Ahmed Reda on 11/10/2023.
//

import Foundation
import UIKit
extension UIView {
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        centerXAnchor.constraint(equalTo: superview!.centerXAnchor).isActive = true
        
        centerYAnchor.constraint(equalTo: superview!.centerYAnchor).isActive = true
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}

