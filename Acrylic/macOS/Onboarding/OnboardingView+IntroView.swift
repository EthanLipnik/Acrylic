//
//  OnboardingView+IntroView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/10/22.
//

import SwiftUI

extension OnboardingView {
    struct IntroView: View {
        @Binding var page: Int
        
        var body: some View {
            HStack {
                VStack {
                    Image("Icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 128)
                    Text("Acrylic")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Button("Learn More") {
                        withAnimation(.spring()) {
                            page += 1
                        }
                    }
                    .controlSize(.large)
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
                }.padding()
            }
        }
    }
}

struct OnboardingView_Intro_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView.IntroView(page: .constant(0))
    }
}
