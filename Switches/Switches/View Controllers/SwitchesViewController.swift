//
//  SwitchesViewController.swift
//  Switches
//
//  Created by Eric Kunz on 6/9/17.
//  Copyright © 2017 Eric Kunz. All rights reserved.
//

import Foundation
import UIKit
import CCHexagonFlowLayout

class SwitchesViewController: UIViewController {
    
    // MARK: Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    weak var delegate: SwitchesViewControllerDelegate?
    
    var isDrawingModeEnabled: Bool = false {
        didSet {
            if isDrawingModeEnabled {
                guard drawingGesture == nil else {
                    drawingGesture?.isEnabled = true
                    return
                }
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(drawing(sender:)))
                longPress.minimumPressDuration = 0
                view.addGestureRecognizer(longPress)
                longPress.delegate = self
                drawingGesture = longPress
                
                collectionView.reloadData()
            }
            else {
                drawingGesture?.isEnabled = false
            }
        }
    }
    
    var numberOfSwitches: Int {
        return collectionView.visibleCells.count
    }
    
    fileprivate static var cellSize: CGSize {
        return SwitchCell().intrinsicContentSize
    }
    
    fileprivate var collectionView: UICollectionView
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private var drawingGesture: UILongPressGestureRecognizer?
    private var lastDrawnSwitchCell: SwitchCell?    
    private var closeButtonRightConstraint: NSLayoutConstraint?
    private var closeButtonTopConstraint: NSLayoutConstraint?
    

    // MARK: Initialization
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        collectionView = SwitchesViewController.commonInit()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        collectionView = SwitchesViewController.commonInit()
        super.init(coder: aDecoder)
    }
    
    private static func commonInit() -> UICollectionView {
        let layout = CCHexagonFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = -1
        layout.minimumLineSpacing = 2
        layout.itemSize = cellSize
        layout.gap = cellSize.height * 0.5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(SwitchCell.self, forCellWithReuseIdentifier: "SwitchCell")
        cv.isScrollEnabled = false
        cv.backgroundColor = .white
        return cv
    }
    
    // MARK: View Cycle

    override func viewDidLoad() {
        view.backgroundColor = .white
        
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()        
    }
    
    // MARK: Actions
    
    @objc private func drawing(sender: UILongPressGestureRecognizer) {
        let touchLocation = sender.location(in: collectionView)
        for cell in collectionView.subviews {
            if let cell = cell as? SwitchCell, cell.frame.contains(touchLocation) {
                guard cell != lastDrawnSwitchCell else { return }
                cell.setOn(!cell.isOn, animated: true)
                lastDrawnSwitchCell = cell
            }
        }
    }
    
    func switchCell(atIndex index: Int, on: Bool, animated: Bool = false) {
        guard index < collectionView.visibleCells.count else { return }
        if let cell = collectionView.visibleCells[index] as? SwitchCell {
            cell.setOn(on, animated: animated)
        }
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let numRows = Int(collectionView.bounds.height / SwitchesViewController.cellSize.height)
        let numColumns = Int(collectionView.bounds.width / SwitchesViewController.cellSize.width)
        let leftRightSpace = (view.bounds.width - (CGFloat(numColumns) * SwitchesViewController.cellSize.width)) / 2
        let topBottomSpace = (view.bounds.height - (CGFloat(numRows) * SwitchesViewController.cellSize.height)) / 2
        collectionView.contentInset = UIEdgeInsets(top: topBottomSpace, left: leftRightSpace, bottom: topBottomSpace, right: leftRightSpace)
        closeButtonRightConstraint?.constant = -leftRightSpace
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            switchAllOff()
        }
    }
    
    func switchAllOff(animated: Bool = true) {
        for cell in collectionView.visibleCells as! [SwitchCell] {
            cell.setOn(false, animated: true)
        }
    }
    
    func turnOnRandomSwitches(count: Int, animated: Bool = true) {
        var offCells = (collectionView.visibleCells as! [SwitchCell]).filter { $0.isOn == false }
        guard offCells.isEmpty == false else { return }
        
        for _ in 0..<count {
            let randomIndex = Int(arc4random_uniform(UInt32(offCells.count)))
            offCells[randomIndex].setOn(true, animated: animated)
        }
    }
    
}

extension SwitchesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numRows = Int(collectionView.bounds.height / (SwitchesViewController.cellSize.height * 1.1))
        let numColumns = Int(collectionView.bounds.width / SwitchesViewController.cellSize.width)
        
        return numRows * numColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        cell.color = UIColor(hue: cell.frame.origin.y / collectionView.frame.height, saturation: 1, brightness: 1, alpha: 1)
        cell.isDrawingModeEnabled = isDrawingModeEnabled
        cell.delegate = self
        return cell
    }
    
}

extension SwitchesViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
    
}

extension SwitchesViewController: SwitchCellDelegate {
    
    func switchCellSwitched(to on: Bool) {
        var allCellsOn = true
        var allCellsOff = true
        
        guard let cells = collectionView.visibleCells as? [SwitchCell] else { return }
        for cell in cells {
            allCellsOn = cell.isOn && allCellsOn
            allCellsOff = !cell.isOn && allCellsOff
        }
        
        if allCellsOff {
            delegate?.levelCleared(switchesViewController: self)
        }
        else if allCellsOn {
            delegate?.allSwitchesAreOn(switchesViewController: self)
        }
    }
    
}

