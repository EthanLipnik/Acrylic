//
//  BlurTransition.swift
//
//  Created by Ethan Lipnik on 9/25/22.
//

import SwiftUI

public struct BlurModifier: ViewModifier {
    public let isIdentity: Bool
    public var intensity: CGFloat

    public func body(content: Content) -> some View {
        content
            .blur(radius: isIdentity ? intensity : 0)
            .opacity(isIdentity ? 0 : 1)
    }
}

extension AnyTransition {
    public static var blur: AnyTransition {
        .blur()
    }
    
    public static func blur(
        intensity: CGFloat = 5,
        scale: CGFloat = 0.8,
        scaleAnimation animation: Animation = .spring()
    ) -> AnyTransition {
        .scale(scale: scale)
        .animation(animation)
        .combined(
            with: .modifier(
                active: BlurModifier(isIdentity: true, intensity: intensity),
                identity: BlurModifier(isIdentity: false, intensity: intensity)
            )
        )
    }
}
