//
//  ScrollViewProtocol.swift
//  SwiftDemo
//
//  Created by yMac on 2019/5/13.
//  Copyright © 2019 cs. All rights reserved.
//

import UIKit


protocol ReusableView {
    
}
extension ReusableView where Self: UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}


