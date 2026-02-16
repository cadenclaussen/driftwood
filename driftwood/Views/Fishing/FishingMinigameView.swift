//
//  FishingMinigameView.swift
//  driftwood
//

import SwiftUI

struct FishingMinigameView: View {
    @ObservedObject var viewModel: FishingViewModel
    let onComplete: () -> Void

    private let barWidth: CGFloat = Theme.Size.fullMap
    private let barHeight: CGFloat = 40

    var body: some View {
        ZStack {
            // dimmed background
            Theme.Color.overlayDimmed
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xxxl) {
                // remaining catches
                Text("Catches: \(viewModel.remainingCatches)")
                    .font(Theme.Font.bodyLargeSemibold)
                    .foregroundColor(Theme.Color.textPrimary)

                // combo display
                if viewModel.comboCount > 0 {
                    Text("Combo x\(viewModel.comboCount)")
                        .font(Theme.Font.bodyMid)
                        .foregroundColor(Theme.Color.selection)
                }

                // timing bar
                timingBar

                // feedback text
                if let result = viewModel.lastCatchResult {
                    resultFeedback(result)
                }

                // instructions
                if viewModel.isAnimating {
                    Text("Tap to catch!")
                        .font(Theme.Font.bodyMid)
                        .foregroundColor(Theme.Color.textPrimary.opacity(Theme.Opacity.overlayDimmed))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard viewModel.isAnimating else { return }
            let result = viewModel.attemptCatch()
            if viewModel.isSessionComplete {
                Task {
                    try? await Task.sleep(for: .milliseconds(800))
                    await MainActor.run {
                        onComplete()
                    }
                }
            }
        }
    }

    private var timingBar: some View {
        ZStack(alignment: .leading) {
            // bar background
            RoundedRectangle(cornerRadius: Theme.Radius.button)
                .fill(Theme.Color.filledSlot)
                .frame(width: barWidth, height: barHeight)

            // green catch zone
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Theme.Color.positive.opacity(Theme.Opacity.button))
                .frame(
                    width: barWidth * viewModel.greenZoneWidth,
                    height: barHeight - Theme.Spacing.sm
                )
                .offset(x: barWidth * viewModel.greenZoneStart, y: 0)

            // perfect zone (brighter green)
            RoundedRectangle(cornerRadius: Theme.Spacing.xxxs)
                .fill(Theme.Color.positive)
                .frame(
                    width: barWidth * viewModel.perfectZoneWidth,
                    height: barHeight - Theme.Spacing.sm
                )
                .offset(x: barWidth * viewModel.perfectZoneStart, y: 0)

            // indicator line (centered on its position)
            Rectangle()
                .fill(Theme.Color.textPrimary)
                .frame(width: Theme.Spacing.xxs, height: barHeight + Theme.Spacing.smd)
                .offset(x: barWidth * viewModel.indicatorPosition - Theme.Spacing.xxxs)
        }
        .frame(width: barWidth, height: barHeight)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.button)
                .stroke(Theme.Color.textPrimary.opacity(Theme.Opacity.half), lineWidth: Theme.Border.standard)
        )
    }

    @ViewBuilder
    private func resultFeedback(_ result: CatchResult) -> some View {
        switch result {
        case .miss:
            Text("Miss!")
                .font(Theme.Font.headingLight)
                .fontWeight(.bold)
                .foregroundColor(Theme.Color.negative)
        case .noCatch:
            Text("Nothing...")
                .font(Theme.Font.headingLight)
                .fontWeight(.bold)
                .foregroundColor(Theme.Color.textSecondary)
        case .success:
            Text("Catch!")
                .font(Theme.Font.headingLight)
                .fontWeight(.bold)
                .foregroundColor(Theme.Color.positive)
        case .perfect:
            Text("Perfect!")
                .font(Theme.Font.headingLight)
                .fontWeight(.bold)
                .foregroundColor(Theme.Color.selection)
        }
    }
}
