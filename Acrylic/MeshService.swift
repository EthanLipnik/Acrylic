//
//  MeshService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import Combine
import MeshKit

class MeshService: ObservableObject {
    @Published var colors: [MeshNode.Color] = []
    @Published var width: Int = 3
    @Published var height: Int = 3
    @Published var subdivsions: Int = 18
    @Published var contentScaleFactor: Float = 1
}
