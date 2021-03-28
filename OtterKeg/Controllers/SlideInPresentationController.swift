//
//  ChangeDrinkerController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/6/21.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
    
    // MARK: - Properties
    private var dimmingView: UIView!
    var direction: PresentationDirection
    
    private var bottomDisplayRatioSize = 1.0/3.0

    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         direction: PresentationDirection) {
        self.direction = direction

        super.init(presentedViewController: presentedViewController,
                 presenting: presentingViewController)
        
        setupDimmingView()
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        //1
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                        withParentContainerSize: containerView!.bounds.size)

        //2
        switch direction {
            case .right:
                frame.origin.x = containerView!.frame.width*(1.0/3.0)
            case .bottom:
                // Determines how far down from the top to DISPLAY the frame, not the frame size
                frame.origin.y = containerView!.frame.height*CGFloat(1.0 - bottomDisplayRatioSize)
        default:
            frame.origin = .zero
        }
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        guard let dimmingView = dimmingView else {
          return
        }
        // 1
        containerView?.insertSubview(dimmingView, at: 0)

        // 2
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                options: [], metrics: nil, views: ["dimmingView": dimmingView]))

        //3
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
            case .left, .right:
                return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
            case .bottom, .top:
                // Determines size of the DISPLAY frame
                return CGSize(width: parentSize.width, height: parentSize.height*CGFloat(bottomDisplayRatioSize))
        }
    }
}

// MARK: - Private
private extension SlideInPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
      presentingViewController.dismiss(animated: true)
    }
}
