//
//  FlickToDismissViewController.swift
//  Example
//
//  Created by Jake Lawson on 04/06/2016.
//  Copyright © 2016 Jake Lawson. All rights reserved.
//

import UIKit

/// Options used to customize the appearance and interaction.
public enum FlickToDismissOption {
    case backgroundColor(UIColor)
    case flickThreshold(CGFloat)
    case flickVelocityMultiplier(CGFloat)
    case snapDamping(CGFloat)
    case animation(AnimationType)
}

/// Different animation styles for presenting the flickable view.
public enum AnimationType: String {
    case none
    case scale
}

/// Presents a UIView which can dismissed by flicking it off the screen.
@IBDesignable
open class FlickToDismissViewController: UIViewController {

    // MARK:- Properties
    
    /// Flickable UIView.
    @IBOutlet open var flickableView: UIView!
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    /// Array of FlickToDismissOptions.
    fileprivate var options: [FlickToDismissOption]?
    /// Indicates how fast the view must be moving in order to have the view continue moving.
    @IBInspectable open var flickThreshold: CGFloat = 1000
    /// The amount of oscillation of the flickableView during the conclusion of a snap.
    @IBInspectable open var snapDamping: CGFloat = 0.5
    /// Affects how fast or slow the view is flicked off the screen.
    @IBInspectable open var flickVelocityMultiplier: CGFloat = 0.2
    /// Animation presentation type. See AnimationType for all possible values.
    @IBInspectable open var animationType: String = "none"
    /// The point for the flickable view to return to if the view was not flicked off the screen
    open var originalCenter: CGPoint?
    // UIKit Dynamics
    fileprivate var animator: UIDynamicAnimator!
    fileprivate var attachmentBehavior: UIAttachmentBehavior!
    fileprivate var snapBehaviour: UISnapBehavior!
    fileprivate var pushBehaviour: UIPushBehavior!
    
    // MARK:- Life Cycle
    
    public init(flickableView: UIView, options: [FlickToDismissOption]?) {
        super.init(nibName: nil, bundle: nil)
        self.flickableView = flickableView
        self.options = options
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Perform animation when view will appear
        switch AnimationType.init(rawValue: animationType) ?? .none {
        case .scale:
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5.0, options: UIViewAnimationOptions(), animations: ({
                self.flickableView.transform = CGAffineTransform.identity
                self.flickableView.alpha = 1.0
            }), completion: nil)
        default:
            break
        }
    }
    
    // MARK:- Setup

    fileprivate func setup() {
        // Setup pan gesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(FlickToDismissViewController.handleAttachmentGesture(_:)))
        // Setup animator
        animator = UIDynamicAnimator(referenceView: view)
        // Apply options
        if let options = options {
            for option in options {
                switch option {
                case .backgroundColor(let color):
                    view.backgroundColor = color
                case .flickThreshold(let threshold):
                    flickThreshold = threshold
                case .flickVelocityMultiplier(let multiplier):
                    flickVelocityMultiplier = multiplier
                case .snapDamping(let damping):
                    snapDamping = damping
                case .animation(let animation):
                    animationType = animation.rawValue
                }
            }
        }
        // Setup animation
        switch AnimationType.init(rawValue: animationType) ?? .none {
        case .scale:
            flickableView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            flickableView.alpha = 0.0
        default:
            break
        }
        flickableView.addGestureRecognizer(panGestureRecognizer)
        // If there are no constraints, center the view
        if flickableView.constraints.count == 0 {
            flickableView.center = view.center
        }
        view.addSubview(flickableView)
    }
    
    // MARK: Layout
    
    open override func viewDidLayoutSubviews() {
        // Only set the center if the view has constraints
        if flickableView.constraints.count != 0 {
            originalCenter = flickableView.center
        }
    }
    
    // MARK:- Pan Gesture
    
    @objc fileprivate func handleAttachmentGesture(_ panGesture: UIPanGestureRecognizer) {
        let location = panGesture.location(in: view)
        let boxLocation = panGesture.location(in: flickableView)
        switch panGesture.state {
        case .began:
            animator.removeAllBehaviors()
            let centerOffset = UIOffset(horizontal: boxLocation.x-flickableView.bounds.midX, vertical: boxLocation.y-flickableView.bounds.midY)
            attachmentBehavior = UIAttachmentBehavior(item: flickableView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            animator.addBehavior(attachmentBehavior)
        case .ended:
            animator.removeAllBehaviors()
            let velocity = panGesture.velocity(in: view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            guard magnitude > flickThreshold else {
                snapBehaviour = UISnapBehavior(item: flickableView, snapTo: originalCenter ?? view.center)
                snapBehaviour.damping = snapDamping
                animator.addBehavior(snapBehaviour)
                return
            }
            let centerOffset = UIOffset(horizontal: boxLocation.x-flickableView.bounds.midX, vertical: boxLocation.y-flickableView.bounds.midY)
            pushBehaviour = UIPushBehavior(items: [flickableView], mode: .instantaneous)
            pushBehaviour.pushDirection = CGVector(dx: velocity.x, dy: velocity.y)
            pushBehaviour.setTargetOffsetFromCenter(centerOffset, for: flickableView)
            pushBehaviour.magnitude = magnitude * flickVelocityMultiplier
            animator.addBehavior(pushBehaviour)
            dismiss(animated: true, completion: nil)
        default:
            attachmentBehavior.anchorPoint = location
        }
    }
    
    // MARK:- Helpers
    
    /// Connect this to a button to dismiss the view controller.
    @IBAction open func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Rotation
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Remove behaviors on rotation in order to satisfy constraints
        animator.removeAllBehaviors()
        // Center view if there are no constraints
        if flickableView.constraints.count == 0 {
            flickableView.center = CGPoint(x: size.width/2, y: size.height/2)
        }
    }
    
}
