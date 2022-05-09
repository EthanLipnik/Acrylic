//
//  MeshCompactViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/23/22.
//

import UIKit
import SwiftUI

class MeshCompactViewController: MeshViewController {
    
    lazy var drawerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.systemGroupedBackground
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 0.1
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var drawerHeightConstraint: NSLayoutConstraint = drawerView.heightAnchor.constraint(equalToConstant: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(drawerView)
        
        NSLayoutConstraint.activate([
            drawerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            drawerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            drawerHeightConstraint
        ])
        
        
        let optionsView: some View = {
            MeshOptionsView(isCompact: true) { [weak self] in
                if self?.presentingViewController == nil {
                    if let session = self?.view.window?.windowScene?.session {
                        UIApplication.shared.requestSceneSessionDestruction(session, options: nil)
                    }
                } else {
                    self?.dismiss(animated: true)
                }
            }.environmentObject(meshService)
        }()
        
        let optionsVC = UIHostingController(rootView: optionsView)
        drawerView.addSubview(optionsVC.view)
        optionsVC.didMove(toParent: self)
        optionsVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        optionsVC.view.backgroundColor = UIColor.secondarySystemBackground
        optionsVC.view.layer.cornerRadius = 30
        optionsVC.view.layer.cornerCurve = .continuous
        optionsVC.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        optionsVC.view.layer.masksToBounds = true
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragDrawerGesture))
        dragGesture.allowedScrollTypesMask = [.all]
        drawerView.addGestureRecognizer(dragGesture)
    }
    
    lazy var normalDrawerHeight: CGFloat = .zero
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        drawerHeightConstraint.constant = normalDrawerHeight
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut,
                                 .beginFromCurrentState,
                                 .allowUserInteraction],
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        drawerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut,
                                 .beginFromCurrentState,
                                 .allowUserInteraction],
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc func done() {
        self.dismiss(animated: true)
    }
    
    lazy var beginDrawerConstant: CGFloat = normalDrawerHeight
    @objc func dragDrawerGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = -gesture.translation(in: nil).y
        
        switch gesture.state {
        case .began:
            beginDrawerConstant = drawerHeightConstraint.constant
        case .changed:
            drawerHeightConstraint.constant = translation + beginDrawerConstant
        case .ended, .failed, .cancelled:
            if translation < -20 {
                drawerHeightConstraint.constant = normalDrawerHeight
            } else if translation > 20 {
                drawerHeightConstraint.constant = view.bounds.height - view.safeAreaInsets.top
            } else {
                drawerHeightConstraint.constant = beginDrawerConstant
            }
        default:
            break
        }
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut,
                                 .beginFromCurrentState,
                                 .allowUserInteraction],
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        normalDrawerHeight = view.bounds.height - meshView.bounds.height - meshView.frame.origin.y - 24
        
        drawerHeightConstraint.constant = normalDrawerHeight
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut,
                                 .beginFromCurrentState,
                                 .allowUserInteraction],
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
}
