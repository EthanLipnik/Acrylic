//
//  VideosManagementView+SidebarView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import PixabayKit
import SwiftUI

extension VideosManagementView {
    struct SidebarView: View {
        @Binding var selectedCategory: SearchCategory?

        let filters: [SearchCategory] = [
            .religion,
        ]

        let sections: [(String, [SearchCategory])] = [
            ("", [
                .all,
                .backgrounds,
            ]),
            ("Learning", [
                .science,
                .education,
                .computer,
                .nature,
                .animals,
                .industry,
                .business,
            ]),
            ("Humanity", [
                .people,
                .health,
                .feelings,
                .sports,
                .food,
                .music,
            ]),
            ("Somewhere else", [
                .transportation,
                .travel,
                .places,
                .buildings,
            ]),
        ]

        let images: [SearchCategory: String] = [
            .all: "square.grid.3x2.fill",
            .backgrounds: "dock.rectangle",
            .fashion: "tshirt.fill",
            .nature: "leaf.fill",
            .science: "magnifyingglass",
            .education: "graduationcap.fill",
            .feelings: "person.fill.questionmark",
            .health: "heart.fill",
            .people: "person.2.fill",
            .places: "building.columns.fill",
            .animals: "pawprint.fill",
            .industry: "hammer.fill",
            .computer: "desktopcomputer",
            .food: "fork.knife",
            .sports: "sportscourt.fill",
            .transportation: "car.fill",
            .travel: "airplane.departure",
            .buildings: "building.2.fill",
            .business: "case.fill",
            .music: "music.note",
        ]

        var body: some View {
            List(sections, id: \.0, selection: $selectedCategory) { section in
                Section(section.0) {
                    ForEach(section.1, id: \.self) { category in
                        let title = category.rawValue.capitalized

                        if let image = images[category] {
                            Label(title, systemImage: image)
                        } else {
                            Text(title)
                        }
                    }
                }
            }
            .frame(minWidth: 200)
        }
    }
}
