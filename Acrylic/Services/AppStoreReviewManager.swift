//
//  AppStoreReviewManager.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/26/22.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
    static let minimumReviewWorthyActionCount = 3
    
    static func requestReview(for scene: UIWindowScene) {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main
        
        var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
        
        actionCount += 1
        
        defaults.set(actionCount, forKey: .reviewWorthyActionCount)
        
        guard actionCount >= minimumReviewWorthyActionCount else {
            return
        }
        
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)
        
        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }
        
        SKStoreReviewController.requestReview(in: scene)
        
        defaults.set(0, forKey: .reviewWorthyActionCount)
        defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
    }
}

extension UIWindowScene {
    func requestReview() {
        AppStoreReviewManager.requestReview(for: self)
    }
}

extension UserDefaults {
    enum Key: String {
        case reviewWorthyActionCount
        case lastReviewRequestAppVersion
    }
    
    func integer(forKey key: Key) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }
    
    func set(_ integer: Int, forKey key: Key) {
        set(integer, forKey: key.rawValue)
    }
    
    func set(_ object: Any?, forKey key: Key) {
        set(object, forKey: key.rawValue)
    }
}
