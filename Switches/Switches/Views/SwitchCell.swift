//
//  SwitchCell.swift
//  Switches
//
//  Created by Eric Kunz on 6/10/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class SwitchCell: UICollectionViewCell {
    
    // MARK: Public Properties
    
    weak var delegate: SwitchCellDelegate?
    
    var isOn: Bool {
        return switchControl.isOn
    }
    
    var color: UIColor? {
        get {
            return switchControl.onTintColor
        }
        set {
            switchControl.onTintColor = newValue
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return switchControl.intrinsicContentSize
    }
    
    var isDrawingModeEnabled = false {
        didSet {
            if isDrawingModeEnabled {
                if touchBlocker == nil {
                    let blocker = TouchBlocker()
                    contentView.addSubview(blocker)
                    blocker.autoPinEdgesToSuperviewEdges()
                }
            }
            else {
                touchBlocker?.removeFromSuperview()
                touchBlocker = nil
            }
        }
    }
    
    // MARK: Private Properties
    
    private let switchControl = UISwitch()
    
    private var touchBlocker: TouchBlocker?
    
    // MARK: Initialization
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(switchControl)
        switchControl.autoPinEdgesToSuperviewEdges()
        
        switchControl.addTarget(self, action: #selector(switchSwitched), for: .valueChanged)
    }
    
    func setOn(_ on: Bool, animated: Bool = false) {
        switchControl.setOn(on, animated: animated)
        switchSwitched()
    }
    
    @objc private func switchSwitched() {
        delegate?.switchCellSwitched(to: isOn)
    }
    
}
