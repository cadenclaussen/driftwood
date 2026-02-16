//
//  JoystickView.swift
//  driftwood
//

import SwiftUI

struct JoystickView: View {
    @Binding var offset: CGSize

    private let baseSize: CGFloat = Theme.Size.joystickBase
    private let thumbSize: CGFloat = Theme.Size.joystickThumb

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.Color.emptySlot)
                .frame(width: baseSize, height: baseSize)
            Circle()
                .fill(Theme.Color.buttonNeutral)
                .frame(width: thumbSize, height: thumbSize)
                .offset(thumbOffset)
        }
        .gesture(dragGesture)
    }

    private var maxRadius: CGFloat {
        (baseSize - thumbSize) / 2
    }

    private var thumbOffset: CGSize {
        let distance = hypot(offset.width, offset.height)
        guard distance > 0 else { return .zero }
        let clampedDistance = min(distance, maxRadius)
        let scale = clampedDistance / distance
        return CGSize(
            width: offset.width * scale,
            height: offset.height * scale
        )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { _ in
                offset = .zero
            }
    }

    var normalizedOffset: CGSize {
        CGSize(
            width: thumbOffset.width / maxRadius,
            height: thumbOffset.height / maxRadius
        )
    }
}
