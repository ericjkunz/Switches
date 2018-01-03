//
//  SwitchesViewControllerDelegate.swift
//  Switches
//
//  Created by Eric Kunz on 6/12/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation

protocol SwitchesViewControllerDelegate: class {
    func levelCleared(switchesViewController: SwitchesViewController)
    func allSwitchesAreOn(switchesViewController: SwitchesViewController)
}
