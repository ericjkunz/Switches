//
//  CalloutLabel.swift
//  Switches
//
//  Created by Eric Kunz on 6/27/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

@IBDesignable
class CalloutLabel: UIView {
    
    @IBInspectable var text: String = "New".uppercased() {
        didSet {
            label.text = text
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            imageView.tintColor = tintColor
        }
    }
    
    private let label = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(label)
        label.text = text
        label.textAlignment = .center
        label.autoPinEdgesToSuperviewEdges()
        label.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightBold)
        
        addSubview(imageView)
        imageView.tintColor = tintColor
        imageView.autoPinEdgesToSuperviewEdges()
        imageView.contentMode = .scaleAspectFit
//        imageView.autoMatch(.width, to: .width, of: label, withOffset: -20, relation: .equal)
//        imageView.autoMatch(.height, to: .height, of: label, withOffset: -20, relation: .equal)
        imageView.image = #imageLiteral(resourceName: "callout").withRenderingMode(.alwaysTemplate)
        
        bringSubview(toFront: label)
    }
    
}
