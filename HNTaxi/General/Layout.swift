//
//  Layout.swift
//  wenovel
//
//  Created by Tbxark on 27/04/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit


extension CGRect {
    init(width: CGFloat, height: CGFloat) {
        self.origin = CGPoint.zero
        self.size = CGSize(width: width, height: height)
    }
}

extension R {
    struct Width {
        static let screen = UIScreen.main.bounds.width
    }
    
    struct Height {
        static let screen = UIScreen.main.bounds.height
        static let toolBar: CGFloat = 44
        static let statusBar: CGFloat = 20
        static let navigationBar: CGFloat = 44
        static let tabBar: CGFloat = 49
        static let fullNavigationBar = statusBar + navigationBar
    }
    
    struct Rect {
        static let `default` = CGRect(width: R.Width.screen, height: R.Height.screen - R.Height.fullNavigationBar)
    }
    
    struct Margin {
        static let small: CGFloat = 8
        static let medium: CGFloat = 10
        static let large: CGFloat = 14
    }

}


struct Color {
    static let orange    = UIColor(red:1.000, green:0.694, blue:0.180, alpha:1.000)
    static let blue      = UIColor(red:0.153, green:0.576, blue:0.976, alpha:1.000)
    static let bgGay     = UIColor(white: 0.9, alpha: 1)
    static let textBlack = UIColor(white: 0.1, alpha: 1)
    static let textDarkGray = UIColor(white: 0.3, alpha: 1)

}



