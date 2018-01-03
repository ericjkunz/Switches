//
//  TouchBlocker.swift
//  Switches
//
//  Created by Eric Kunz on 6/10/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation
import UIKit

class TouchBlocker: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
