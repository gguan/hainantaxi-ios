//
//  WebImageView.swift
//  HNTaxi
//
//  Created by Tbxark on 25/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import YYWebImage

typealias HTImageDownloadComplete = (UIImage?, Error?) -> Void
typealias HTImageDownloadProgress = (Int, Int) -> Void
typealias HTImageTransform = (UIImage, URL) -> UIImage?


extension UIImageView {
    
    
    func setImageWithAnimate(_ image: UIImage?, duration: TimeInterval = 0.1) {
        UIView.transition(with: self,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.image = image
        }, completion: nil)
    }
    
    func ht_setImageWithURL(_ url: URL?, placeholderImage: UIImage? = nil, complete: HTImageDownloadComplete? = nil) {
        guard let imgUrl = url else {
            image = placeholderImage
            return
        }
        if let c = complete {
            yy_setImage(with: imgUrl,
                        placeholder: placeholderImage,
                        options: .setImageWithFadeAnimation,
                        completion: { c($0, $4) })
        } else {
            yy_setImage(with: imgUrl,
                        placeholder: placeholderImage,
                        options: .setImageWithFadeAnimation,
                        completion: nil)
        }
        
        
    }
    
    func ht_cancelRequest() {
        yy_cancelCurrentImageRequest()
    }
    
}
