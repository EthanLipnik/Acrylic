//
//  OnboardingView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/10/22.
//

import SwiftUI
import MeshKit

struct OnboardingView: View {
    @State private var page: Int = 0
    @AppStorage("didShowOnboarding") var didShowOnboarding: Bool = false
    
    let finish: () -> Void
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
            
            Group {
                switch page {
                case 0:
                    IntroView(page: $page)
                case 1:
                    FluidView(page: $page)
                case 2:
                    VideoView(page: $page, closeWindow: finishOnboarding)
                default:
                    Text("Something went wrong...")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.secondary)
                }
            }
            .zIndex(999)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
        .overlay(
            Button {
                finishOnboarding()
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .padding(),
            alignment: .topTrailing
        )
        .edgesIgnoringSafeArea(.all)
        .frame(width: 640, height: 480)
    }
    
    func finishOnboarding() {
        didShowOnboarding = true
        
        if let button = AppDelegate.statusBar?.statusItem.button {
            AppDelegate.statusBar?.togglePopover(button)
        }
        
        finish()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView() {}
    }
}
