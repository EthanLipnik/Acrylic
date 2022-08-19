//
//  ColorSpace.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/19/22.
//

import Foundation
import CoreGraphics

enum ColorSpace: String, Hashable, CaseIterable {
    case linearSRGB
    case sRGB
    case displayP3
    
    var displayName: String {
        switch self {
        case .linearSRGB:
            return "Linear SRGB"
        case .sRGB:
            return "sRGB"
        case .displayP3:
            return "Display P3"
        }
    }
    
    var cgColorSpace: CGColorSpace {
        switch self {
        case .linearSRGB:
            return CGColorSpace(name: CGColorSpace.linearSRGB)!
        case .sRGB:
            return CGColorSpace(name: CGColorSpace.sRGB)!
        case .displayP3:
            return CGColorSpace(name: CGColorSpace.displayP3)!
        }
    }
}
