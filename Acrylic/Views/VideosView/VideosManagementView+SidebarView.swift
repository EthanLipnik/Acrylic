//
//  VideosManagementView+SidebarView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

#if os(macOS)
import SwiftUI
import PixabayKit

extension VideosManagementView {
    struct SidebarView: View {
        @Binding var selectedCategory: SearchCategory?
        
        let filters: [SearchCategory] = [
            .religion
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
            .music: "music.note"
        ]
        
        var body: some View {
            List(SearchCategory.allCases.filter({ !filters.contains($0) }), id: \.self, selection: $selectedCategory) { category in
                let title = category.rawValue.capitalized
                
                if let image = images[category] {
                    Label(title, systemImage: image)
                } else {
                    Text(title)
                }
            }
        }
    }
}
#endif
