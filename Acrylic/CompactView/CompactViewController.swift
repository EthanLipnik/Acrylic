//
//  CompactViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import UIKit
import SwiftUI

class CompactViewController: UIHostingController<CompactView> {
    
    init() {
        super.init(rootView: CompactView())
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
