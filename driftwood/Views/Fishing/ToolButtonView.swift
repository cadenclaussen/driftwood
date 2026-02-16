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
            return Theme.Color.buttonBlue
        }
        if canUseTool {
            return Theme.Color.fishing.opacity(Theme.Opacity.overlayDimmed)
        }
        return Theme.Color.buttonInactive
    }

    private var borderColor: Color {
        if isPressed {
            return Theme.Color.equipped
        }
        if canUseTool {
            return Theme.Color.fishing
        }
        return Theme.Color.borderDark
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: Theme.Size.circleButton, height: Theme.Size.circleButton)

            toolImage
                .foregroundColor(Theme.Color.textPrimary)
        }
        .overlay(
            Circle()
                .stroke(borderColor, lineWidth: Theme.Border.standard)
        )
        .onTapGesture {
            if canUseTool {
                onTap()
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: Theme.Anim.longPressDuration)
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
                    .frame(width: Theme.Size.actionButton, height: Theme.Size.actionButton)
            } else {
                Image(systemName: tool.iconName)
                    .font(.system(size: Theme.Size.iconMedium))
            }
        } else {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: Theme.Size.iconMedium))
        }
    }
}
