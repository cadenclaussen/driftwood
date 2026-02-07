//
//  SailboatView.swift
//  driftwood
//

import SwiftUI

struct SailboatView: View {
    let width: CGFloat = 48
    let height: CGFloat = 36

    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: width, height: height)
    }
}
