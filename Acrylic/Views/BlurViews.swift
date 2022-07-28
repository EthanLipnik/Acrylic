//
//  BlurViews.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import SwiftUI

struct BlurView: View {
    enum Style {
        case circle
        case roundedRectangle(cornerRadius: CGFloat = 10)
    }

    enum Effect {
        case ultraThin
        case thin
        case regular

        @available(iOS 15, macOS 12, *)
        var material: Material {
            switch self {
            case .ultraThin:
                return .ultraThin
            case .thin:
                return .thin
            case .regular:
                return .regular
            }
        }

        var blurEffect: UIBlurEffect.Style {
            switch self {
            case .ultraThin:
                return .systemUltraThinMaterial
            case .thin:
                return .systemThinMaterial
            case .regular:
                return .regular
            }
        }
    }

    var style: Style = .roundedRectangle()
    var effect: Effect = .regular

    var body: some View {
        Group {
            if #available(iOS 15, macOS 12, *) {
                switch style {
                case .circle:
                    Circle()
                        .fill(effect.material)
                case .roundedRectangle(let cornerRadius):
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(effect.material)
                }
            } else {
                switch style {
                case .circle:
                    VisualEffectBlur(blurStyle: effect.blurEffect)
                        .clipShape(Circle())
                case .roundedRectangle(let cornerRadius):
                    VisualEffectBlur(blurStyle: effect.blurEffect)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            }
        }
    }
}
