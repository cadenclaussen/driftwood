//
//  PlayerView.swift
//  driftwood
//

import SwiftUI

struct PlayerView: View {
    let size: CGFloat
    let facingDirection: FacingDirection

    var body: some View {
        Image(facingDirection.spriteName)
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
    }
}
