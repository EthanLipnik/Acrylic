//
//  OptionsView+Render.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/25/21.
//

import SwiftUI

extension OptionsView {
    var renderView: some View {
        DetailView(title: "Render", systemImage: "cube.transparent") {
            HStack {
                Label("Resolution", systemImage: "arrow.up.left.and.arrow.down.right")
                    .frame(maxWidth: .infinity, alignment: .leading)
                ResolutionField(placeholder: "Width", defaultValue: 4096) { value in
                    
                }
                .font(.system(.body, design: .rounded))
                .frame(width: 40)
                Text("x")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color.secondary)
                ResolutionField(placeholder: "Height", defaultValue: 4096) { value in
                    
                }
                .font(.system(.body, design: .rounded))
                .frame(width: 40)
            }
        }
    }
    
    struct ResolutionField: View {
        let placeholder: String
        let defaultValue: Int
        let valueChanged: (Int) -> Void
        @StateObject var numbersOnly = NumbersOnly()
        
        var body: some View {
            TextField(placeholder, text: $numbersOnly.value, onEditingChanged: { _ in
                valueChanged(Int(numbersOnly.value) ?? 0)
            })
                .keyboardType(.decimalPad)
                .onAppear {
                    if numbersOnly.value.isEmpty {
                        numbersOnly.value = "\(defaultValue)"
                    }
                }
        }
    }
}

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
