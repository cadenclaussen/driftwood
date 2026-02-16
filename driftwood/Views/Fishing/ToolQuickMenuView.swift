//
//  ToolQuickMenuView.swift
//  driftwood
//

import SwiftUI

struct ToolQuickMenuView: View {
    let tools: [ToolType]
    let currentTool: ToolType?
    let onSelect: (ToolType?) -> Void
    let onDismiss: () -> Void

    @State private var dragLocation: CGPoint = .zero
    @State private var highlightedIndex: Int? = nil
    @State private var toolFrames: [Int: CGRect] = [:]

    private let iconSize: CGFloat = Theme.Size.joystickThumb
    private let spacing: CGFloat = Theme.Spacing.md

    var body: some View {
        ZStack {
            // dimmed background
            Theme.Color.overlaySubtle
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // tool menu
            VStack {
                Spacer()

                if tools.isEmpty {
                    Text("No Tools")
                        .foregroundColor(Theme.Color.textPrimary)
                        .padding()
                        .background(Theme.Color.overlayDimmed)
                        .cornerRadius(Theme.Radius.button)
                } else {
                    HStack(spacing: spacing) {
                        ForEach(Array(tools.enumerated()), id: \.element) { index, tool in
                            toolIcon(tool: tool, index: index)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.onAppear {
                                            toolFrames[index] = geo.frame(in: .global)
                                        }
                                    }
                                )
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(Theme.Color.overlayMedium)
                    .cornerRadius(Theme.Radius.large)
                }

                Spacer()
                    .frame(height: Theme.Size.joystickBase)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    dragLocation = value.location
                    updateHighlight()
                }
                .onEnded { _ in
                    if let index = highlightedIndex, index < tools.count {
                        onSelect(tools[index])
                    } else {
                        onDismiss()
                    }
                }
        )
    }

    private func toolIcon(tool: ToolType, index: Int) -> some View {
        let isHighlighted = highlightedIndex == index
        let isEquipped = currentTool == tool

        return ZStack {
            Circle()
                .fill(isHighlighted ? Theme.Color.equipped : (isEquipped ? Theme.Color.positive.opacity(Theme.Opacity.button) : Theme.Color.buttonNeutral))
                .frame(width: iconSize, height: iconSize)

            toolImage(for: tool)
                .foregroundColor(Theme.Color.textPrimary)
        }
        .overlay(
            Circle()
                .stroke(isHighlighted ? Theme.Color.equipped : Theme.Color.borderLight, lineWidth: Theme.Border.standard)
        )
        .scaleEffect(isHighlighted ? 1.15 : 1.0)
        .animation(Theme.Anim.quick, value: isHighlighted)
    }

    private func updateHighlight() {
        highlightedIndex = nil
        for (index, frame) in toolFrames {
            let expandedFrame = frame.insetBy(dx: -10, dy: -10)
            if expandedFrame.contains(dragLocation) {
                highlightedIndex = index
                break
            }
        }
    }

    @ViewBuilder
    private func toolImage(for tool: ToolType) -> some View {
        if tool.usesCustomImage {
            Image(tool.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.slotImage, height: Theme.Size.slotImage)
        } else {
            Image(systemName: tool.iconName)
                .font(.system(size: Theme.Size.iconMedium))
        }
    }
}
