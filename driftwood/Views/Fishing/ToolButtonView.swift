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

            toolImage
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

    @ViewBuilder
    private var toolImage: some View {
        if let tool = equippedTool {
            if tool.usesCustomImage {
                Image(tool.iconName)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 44, height: 44)
            } else {
                Image(systemName: tool.iconName)
                    .font(.system(size: 24))
            }
        } else {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 24))
        }
    }
}
