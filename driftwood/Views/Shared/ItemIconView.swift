//
//  ItemIconView.swift
//  driftwood
//

import SwiftUI

struct ItemIconView: View {
    let iconName: String
    let usesCustomImage: Bool
    let size: CGFloat
    var color: Color = .white

    var body: some View {
        if usesCustomImage {
            Image(iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: size, height: size)
        } else {
            Image(systemName: iconName)
                .font(.system(size: size * 0.75))
                .foregroundColor(color)
        }
    }
}
