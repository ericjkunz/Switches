//
//  GameController.swift
//  Switches
//
//  Created by Eric Kunz on 6/11/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation
import UIKit

class GameController: UIViewController {
    
    // MARK: Types
    
    enum GameMode {
        case levels, savage
    }
    
    enum GameState {
        case pregame, inProgress, finished
    }
    
    // MARK: Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let timer = Timer()
    let switchesController = SwitchesViewController()
    var savageTimer: Timer?
    var gameStart = Date()
    
    let allLevels: [Level] = [
        Level(name: "Level 1", time: 5, numSwitches: 1),
        Level(name: "Level 2", time: 5, numSwitches: 2),
        Level(name: "Level 3", time: 5, numSwitches: 10),
        Level(name: "Level 4", time: 10, numSwitches: 15),
        Level(name: "Level 5", time: 10, numSwitches: 20),
        Level(name: "Level 6", time: 10, numSwitches: 25),
        Level(name: "Level 7", time: 10, numSwitches: 30),
        Level(name: "Level 8", time: 10, numSwitches: 35),
        Level(name: "Level 9", time: 15, numSwitches: 40),
        Level(name: "Level 10", time: 20, numSwitches: 60)
    ]
    
    var currentLevel = -1
    fileprivate var mode: GameMode = .levels
    var gameState: GameState = .pregame
    private let closeButton = UIButton()
    private let levelLabel = UILabel()
    private let countdownLabel = UILabel()
    fileprivate let largeLevelLabel = UILabel()
    private var levelEnd = Date()
    private let levelAdvanceButton = UIButton()
    
    // MARK: Initialization
    
    convenience init(mode: GameMode) {
        self.init(nibName: nil, bundle: nil)
        self.mode = mode
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Cycle
    
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
        switchesController.delegate = self
        
        levelAdvanceButton.isHidden = true
        view.addSubview(levelAdvanceButton)
        levelAdvanceButton.autoPinEdgesToSuperviewEdges()
        levelAdvanceButton.addTarget(self, action: #selector(advanceLevelTapped(sender:)), for: .touchUpInside)
        
        setupLabels()
    }
    
    private func setupLabels() {
        view.addSubview(levelLabel)
        levelLabel.text = "Level 1"
        levelLabel.frame = CGRect(x: 8,
                                  y: 8,
                                  width: levelLabel.intrinsicContentSize.width,
                                  height: levelLabel.intrinsicContentSize.height)
        levelLabel.font = UIFont.systemFont(ofSize: 12)
        levelLabel.numberOfLines = 0
        
        view.addSubview(countdownLabel)
        countdownLabel.text = "0:00:00"
        countdownLabel.frame = CGRect(x: (view.frame.width / 2) - (countdownLabel.intrinsicContentSize.width / 2),
                                      y: 8,
                                      width: countdownLabel.intrinsicContentSize.width,
                                      height: countdownLabel.intrinsicContentSize.height)
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: UIFontWeightBold)
        
        view.addSubview(largeLevelLabel)
        largeLevelLabel.text = "Level 1"
        largeLevelLabel.font = UIFont.boldSystemFont(ofSize: 80)
        largeLevelLabel.adjustsFontSizeToFitWidth = true
        largeLevelLabel.frame = CGRect(x: view.center.x - (largeLevelLabel.intrinsicContentSize.width / 2),
                                       y: view.center.y - (largeLevelLabel.intrinsicContentSize.height / 2),
                                       width: largeLevelLabel.intrinsicContentSize.width,
                                       height: largeLevelLabel.intrinsicContentSize.height)
        
        largeLevelLabel.alpha = 0
        largeLevelLabel.textAlignment = .center
        largeLevelLabel.textColor = .blue
        largeLevelLabel.numberOfLines = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch mode {
        case .levels:
            startALevel()
        case .savage:
            pregameSavageGame()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            countdownLabel.frame = CGRect(x: (view.frame.width / 2) - (countdownLabel.intrinsicContentSize.width / 2),
                                          y: view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 8,
                                          width: countdownLabel.intrinsicContentSize.width,
                                          height: countdownLabel.intrinsicContentSize.height)
        } else {
            countdownLabel.frame = CGRect(x: (view.frame.width / 2) - (countdownLabel.intrinsicContentSize.width / 2),
                                          y: 8,
                                          width: countdownLabel.intrinsicContentSize.width,
                                          height: countdownLabel.intrinsicContentSize.height)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func advanceLevelTapped(sender: UIButton) {
        shrinkLevelLabels {
            self.levelAdvanceButton.isHidden = true
            
            switch self.mode {
            case .levels:
                let level = self.allLevels[self.currentLevel]
                self.startTimer(withDuration: level.time)
            case .savage:
                switch self.gameState {
                case .pregame, .finished:
                    self.switchesController.switchAllOff()
                    self.pregameSavageGame()
                case .inProgress:
                    self.startSavageGame()
                }
            }
        }
    }
    
    // MARK: Level Label
    
    func setLevelLabel(to levelName: String) {
        levelLabel.text = levelName
        largeLevelLabel.text = levelName
    }
    
    func focusLevelLabels() {
        switchesController.view.isUserInteractionEnabled = false
        
        view.bringSubview(toFront: levelLabel)
        view.bringSubview(toFront: largeLevelLabel)
        
        let smallLevelSize = levelLabel.intrinsicContentSize
        let largeLevelSize = largeLevelLabel.intrinsicContentSize
        let shrinkTransform = CGAffineTransform(scaleX: smallLevelSize.width / largeLevelSize.width, y: smallLevelSize.height / largeLevelSize.height)
        let growTransform = shrinkTransform.inverted()
        
        levelLabel.transform = growTransform
        
        let levelStartOrigin = levelLabel.frame.origin
        let levelEndOrigin = CGPoint(x: view.frame.midX - (largeLevelSize.width / 2), y: view.center.y - (largeLevelSize.height / 2))
        
        let translation =  CGAffineTransform(translationX: levelEndOrigin.x - levelStartOrigin.x, y: levelEndOrigin.y - levelStartOrigin.y)
        
        largeLevelLabel.transform = shrinkTransform.concatenating(translation.inverted())
        levelLabel.transform = .identity
        
        let animator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.8) {
            self.switchesController.view.alpha = 0.2
            self.largeLevelLabel.alpha = 1
            self.levelLabel.alpha = 0
            
            self.largeLevelLabel.transform = .identity
            self.levelLabel.transform = growTransform.concatenating(translation)
        }
        
        animator.addCompletion { _ in
            self.levelAdvanceButton.isHidden = false
            self.view.bringSubview(toFront: self.levelAdvanceButton)
            self.switchesController.view.isUserInteractionEnabled = true
        }
        
        animator.startAnimation()
    }
    
    private func shrinkLevelLabels(completion: (() -> Void)?) {
        view.bringSubview(toFront: levelLabel)
        view.bringSubview(toFront: largeLevelLabel)
        
        let smallLevelSize = levelLabel.intrinsicContentSize
        let largeLevelSize = largeLevelLabel.intrinsicContentSize
        let shrinkTransform = CGAffineTransform(scaleX: smallLevelSize.width / largeLevelSize.width, y: smallLevelSize.height / largeLevelSize.height)
        
        largeLevelLabel.transform = shrinkTransform
        
        let levelStartOrigin = CGPoint(x: 8, y: 8)
        let levelEndOrigin = largeLevelLabel.frame.origin
        
        let translation =  CGAffineTransform(translationX: levelEndOrigin.x - levelStartOrigin.x, y: levelEndOrigin.y - levelStartOrigin.y)
        
        largeLevelLabel.transform = .identity
        
        let animator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.8) {
            self.switchesController.view.alpha = 1
            self.largeLevelLabel.alpha = 0
            self.levelLabel.alpha = 1
            
            self.largeLevelLabel.transform = shrinkTransform.concatenating(translation.inverted())
            self.levelLabel.transform = .identity
        }
        
        animator.addCompletion { _ in
            completion?()
        }
        
        animator.startAnimation()
    }
    
    // MARK: Timer
    
    fileprivate var displayLink: CADisplayLink?
    
    func startTimer(withDuration d: TimeInterval) {
        displayLink?.invalidate()
        levelEnd = Date(timeIntervalSinceNow: d)
        let dl = CADisplayLink(target: self, selector: #selector(updateTimerLabel(displayLink:)))
        dl.add(to: .current, forMode: .defaultRunLoopMode)
        displayLink = dl
    }
    
    func startStopwatch() {
        displayLink?.invalidate()
        let dl = CADisplayLink(target: self, selector: #selector(updateStopwatch))
        dl.add(to: .current, forMode: .defaultRunLoopMode)
        displayLink = dl
    }
    
    func setTimerLabel(withTime time: TimeInterval) {
        let minutes = Int((time) / 60) % 60
        let seconds = Int(time) % 60
        let fractionMinute = Int((time - TimeInterval(seconds)) * 100.0)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.maximumIntegerDigits = 2
        
        let txt = "\(numberFormatter.string(from: NSNumber(value: minutes)) ?? "00"):\(numberFormatter.string(from: NSNumber(value: seconds)) ?? "00").\(numberFormatter.string(from: NSNumber(value: fractionMinute)) ?? "00")"
        
        countdownLabel.text = txt
    }
    
    @objc
    func updateTimerLabel(displayLink: CADisplayLink) {
        let timeLeft = levelEnd.timeIntervalSince(Date())
        setTimerLabel(withTime: timeLeft)
        
        if timeLeft <= 0 {
            displayLink.invalidate()
            setTimerLabel(withTime: 0)
            largeLevelLabel.textColor = UIColor.red
            startALevel()
        }
        
        countdownLabel.frame = CGRect(x: (view.frame.width / 2) - (countdownLabel.intrinsicContentSize.width / 2),
                                      y: 8,
                                      width: countdownLabel.intrinsicContentSize.width,
                                      height: countdownLabel.intrinsicContentSize.height)
    }
    
    @objc
    func updateStopwatch() {
        let gameDuration = Date().timeIntervalSince(gameStart)
        setTimerLabel(withTime: gameDuration)
        
        countdownLabel.frame = CGRect(x: (view.frame.width / 2) - (countdownLabel.intrinsicContentSize.width / 2),
                                      y: 8,
                                      width: countdownLabel.intrinsicContentSize.width,
                                      height: countdownLabel.intrinsicContentSize.height)
    }
    
    func stopStopwatch() {
        displayLink?.invalidate()
    }
    
    // MARK: Switch Control
    
    func turnOnRandomSwitches(_ count: Int, animated: Bool = false) {
        switchesController.turnOnRandomSwitches(count: count, animated: animated)
    }
    
}

extension GameController: SwitchesViewControllerDelegate {
    
    func levelCleared(switchesViewController: SwitchesViewController) {
        guard mode == .levels else { return }
        guard gameState == .inProgress else { return }
        
        largeLevelLabel.textColor = UIColor.green
        displayLink?.invalidate()
        startALevel()
    }
    
    func allSwitchesAreOn(switchesViewController: SwitchesViewController) {
        endSavageGame()
    }
    
}
