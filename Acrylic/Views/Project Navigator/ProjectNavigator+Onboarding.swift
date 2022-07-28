//
//  ProjectNavigator+Onboarding.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/30/22.
//

import UIKit
import UIOnboarding

extension ProjectNavigatorViewController: UIOnboardingViewControllerDelegate {
    func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
        onboardingViewController.dismiss(animated: true) { [weak self] in
#if targetEnvironment(macCatalyst)
            (self?.view.window?.windowScene?.delegate as? SceneDelegate)?.addToolbar()
#endif
        }

        UserDefaults.standard.set(true, forKey: "didFinishOnboarding")
    }
}
