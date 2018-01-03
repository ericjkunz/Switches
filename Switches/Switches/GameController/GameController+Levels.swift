//
//  GameController+Levels.swift
//  Switches
//
//  Created by Eric Kunz on 6/25/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation

extension GameController {
    
    func startALevel() {
        gameState = .pregame
        
        currentLevel += 1
        
        if currentLevel == allLevels.count {
            currentLevel = 0
        }
        
        let level = allLevels[currentLevel]
        
        setLevelLabel(to: level.name)
        setTimerLabel(withTime: level.time)
        
        focusLevelLabels()
        
        switchesController.switchAllOff(animated: false)
        
        turnOnRandomSwitches(level.numSwitches)
        
        gameState = .inProgress
    }
    
}
