//
//  ToolButtonView.swift
//  driftwood
//

import SwiftUI

struct ToolButtonView: View {
    let equippedTool: ToolType?
    let canUseTool: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void

    @State private var isPressed: Bool = false

    private var backgroundColor: Color {
        if isPressed {
            return Color.blue.opacity(0.8)
        }
        if canUseTool {
            return Color.cyan.opacity(0.7)
        }
        return Color.gray.opacity(0.7)
    }

    private var borderColor: Color {
        if isPressed {
            return Color.blue
        }
        if canUseTool {
            return Color.cyan
        }
        return Color.black.opacity(0.3)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 60, height: 60)

            toolImage
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(borderColor, lineWidth: 2)
        )
        .onTapGesture {
            if canUseTool {
                onTap()
            }
        }
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
