//
//  GameController+Savage.swift
//  Switches
//
//  Created by Eric Kunz on 6/24/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation

extension GameController {
    
    func pregameSavageGame() {
        gameState = .inProgress
        setLevelLabel(to: "Savage")
        focusLevelLabels()
    }
    
    func startSavageGame() {
        self.turnOnRandomSwitches(1, animated: true)
        self.gameState = .inProgress
        self.gameStart = Date()
        self.startStopwatch()
        self.advanceSavageGame()
    }
    
    func advanceSavageGame() {
        savageTimer?.invalidate()
        savageTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { timer in
            guard self.gameState == .inProgress else { return }
            
            let secondsSinceStart = Date().timeIntervalSince(self.gameStart)
            let numberOfSwitches = Int(max(1, min(4, secondsSinceStart * 0.06)))
            self.turnOnRandomSwitches(numberOfSwitches, animated: true)
            self.advanceSavageGame()
        })
    }
    
    func endSavageGame() {
        stopStopwatch()
        savageTimer?.invalidate()
        gameState = .finished
        
        let gameTime = Date().timeIntervalSince(gameStart)
        
        let d = Date(timeIntervalSince1970: gameTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss.SSS"
        let timeString = dateFormatter.string(from: d)
        
        setLevelLabel(to: "You lasted \(timeString) \n that's alright")
        focusLevelLabels()
    }
    
}
