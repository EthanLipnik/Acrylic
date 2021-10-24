//
//  OptionsViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SwiftUI

class OptionsViewController: UIHostingController<OptionsView> {
    
    init() {
        super.init(rootView: OptionsView())
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.backgroundColor = UIColor.clear
    }
}
