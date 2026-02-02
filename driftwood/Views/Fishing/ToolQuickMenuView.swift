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

    private let iconSize: CGFloat = 50
    private let spacing: CGFloat = 12

    var body: some View {
        ZStack {
            // dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // tool menu
            VStack {
                Spacer()

                if tools.isEmpty {
                    Text("No Tools")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(16)
                }

                Spacer()
                    .frame(height: 120)
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
                .fill(isHighlighted ? Color.blue : (isEquipped ? Color.green.opacity(0.6) : Color.gray.opacity(0.6)))
                .frame(width: iconSize, height: iconSize)

            Image(systemName: tool.iconName)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(isHighlighted ? Color.blue : Color.white.opacity(0.3), lineWidth: 2)
        )
        .scaleEffect(isHighlighted ? 1.15 : 1.0)
        .animation(.easeOut(duration: 0.1), value: isHighlighted)
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
}
