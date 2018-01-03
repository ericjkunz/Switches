//
//  ViewController.swift
//  Switches
//
//  Created by Eric Kunz on 6/9/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func startPlaying(_ sender: UIButton) {
        let game = GameController(mode: .levels)
        present(game, animated: true, completion: nil)
    }
    
    @IBAction func startDrawing(_ sender: UIButton) {
        let draw = DrawController()
        present(draw, animated: true, completion: nil)
    }
    
    @IBAction func startSavage(_ sender: UIButton) {
        let game = GameController(mode: .savage)
        present(game, animated: true, completion: nil)
    }
    
}

