//
//  SailboatView.swift
//  driftwood

import SwiftUI

struct SailboatView: View {
    let rotationAngle: Double // radians
    let size: CGFloat = 32

    var body: some View {
        Image("BirdEyeSailboat")
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
            .rotationEffect(.radians(rotationAngle + .pi / 2))
    }
}
