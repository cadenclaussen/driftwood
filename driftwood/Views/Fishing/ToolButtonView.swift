//
//  ToolButtonView.swift
//  driftwood
//

import SwiftUI

struct ToolButtonView: View {
    let equippedTool: ToolType?
    let onLongPress: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(isPressed ? Color.blue.opacity(0.8) : Color.gray.opacity(0.7))
                .frame(width: 60, height: 60)

            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(isPressed ? Color.blue : Color.black.opacity(0.3), lineWidth: 2)
        )
        .gesture(
            LongPressGesture(minimumDuration: 0.3)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                    onLongPress()
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { _ in
                    isPressed = false
                }
        )
    }

    private var iconName: String {
        equippedTool?.iconName ?? "wrench.and.screwdriver"
    }
}
