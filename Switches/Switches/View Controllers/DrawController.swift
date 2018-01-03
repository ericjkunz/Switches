//
//  DrawController.swift
//  Switches
//
//  Created by Eric Kunz on 6/12/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation
import UIKit

class DrawController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let switchesController = SwitchesViewController()
    
    private let closeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(closeButton)
        closeButton.setTitle("Close".uppercased(), for: .normal)
        closeButton.autoPinEdge(.top, to: .top, of: view)
        closeButton.autoPinEdge(.right, to: .right, of: view, withOffset: -4)
        closeButton.titleLabel?.textAlignment = .right
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        addChildViewController(switchesController)
        view.addSubview(switchesController.view)
        switchesController.view.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        switchesController.view.autoPinEdge(.top, to: .bottom, of: closeButton)
        switchesController.didMove(toParentViewController: self)
        
        switchesController.isDrawingModeEnabled = true
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
}
