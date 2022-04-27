//
//  BetaInfoView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/26/22.
//

import SwiftUI

struct BetaInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openUrl
    @AppStorage("shouldNotShowBetaInfo") var shouldNotShowBetaInfo: Bool = false
    
    let launchDate = Date(timeIntervalSince1970: 1651849200)
    let expireDate = Date(timeIntervalSince1970: 1652454000)
    
    var body: some View {
        VStack {
            Text("🎉🎉")
                .font(.system(size: 64))
            Text("Acrylic is on the App Store!")
                .font(.system(.largeTitle, design: .rounded).bold())
                .multilineTextAlignment(.center)
            Spacer()
            VStack {
                groupBox(title: "Launch",
                         description: "Available for download on May 6th. The public beta will expire on May 13th.")
                groupBox(title: "Pricing",
                         description: "Acrylic is $1.99. Preorders are now available.")
                groupBox(title: "Chairty",
                         description: "For the first month, 70% of proceeds will be going to Dian Fossey Gorilla Fund.")
                
                if Date() < launchDate {
                    Text(launchDate, style: .relative)
                        .bold()
                        .foregroundColor(.secondary)
                    + Text(" Until launch")
                        .foregroundColor(.secondary)
                } else {
                    Text(expireDate, style: .relative)
                        .bold()
                        .foregroundColor(.secondary)
                    + Text(" Until the beta expires")
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack {
                Button("Don't show again") {
                    shouldNotShowBetaInfo = true
                    presentationMode.wrappedValue.dismiss()
                }
                Group {
                    if #available(iOS 15.0, *), UIDevice.current.userInterfaceIdiom != .mac {
                        Button {
                            openUrl(URL(string: "https://apps.apple.com/us/app/acrylic/id1591850668?mt=12")!)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Preorder")
                                .font(.title3.bold())
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .buttonBorderShape(.roundedRectangle)
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button {
                            openUrl(URL(string: "https://apps.apple.com/us/app/acrylic/id1591850668?mt=12")!)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Preorder")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.accentColor))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .shadow(color: Color.accentColor.opacity(0.4), radius: 16, y: 8)
            }
        }
        .padding()
        .frame(maxWidth: 400)
    }
    
    func groupBox(title: String, description: String) -> some View {
        return Group {
            if #available(iOS 15.0, *), UIDevice.current.userInterfaceIdiom != .mac {
                GroupBox(title) {
                    Text(description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                GroupBox {
                    Text(title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct BetaInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                BetaInfoView()
            }
    }
}
