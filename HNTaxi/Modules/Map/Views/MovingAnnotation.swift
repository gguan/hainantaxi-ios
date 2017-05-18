//
//  MovingAnnotation.swift
//  HNTaxi
//
//  Created by Tbxark on 18/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

class MovingAnnotation: MAAnimatedAnnotation {
    var stepCallback: (()-> Void)?
    override func step(_ timeDelta: CGFloat) {
        super.step(timeDelta)
        stepCallback?()
    }
    override func rotateDegree() -> CLLocationDirection {
        return 0
    }
    
}
