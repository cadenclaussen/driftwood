//
//  FishingMinigameView.swift
//  driftwood
//

import SwiftUI

struct FishingMinigameView: View {
    @ObservedObject var viewModel: FishingViewModel
    let onComplete: () -> Void

    private let barWidth: CGFloat = 300
    private let barHeight: CGFloat = 40

    var body: some View {
        ZStack {
            // dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // remaining catches
                Text("Catches: \(viewModel.remainingCatches)")
                    .font(.headline)
                    .foregroundColor(.white)

                // combo display
                if viewModel.comboCount > 0 {
                    Text("Combo x\(viewModel.comboCount)")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
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
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
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
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.4))
                .frame(width: barWidth, height: barHeight)

            // green catch zone
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.green.opacity(0.6))
                .frame(
                    width: barWidth * viewModel.greenZoneWidth,
                    height: barHeight - 8
                )
                .offset(x: barWidth * viewModel.greenZoneStart + 4)

            // perfect zone (brighter green)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.green)
                .frame(
                    width: barWidth * viewModel.perfectZoneWidth,
                    height: barHeight - 8
                )
                .offset(x: barWidth * viewModel.perfectZoneStart + 4)

            // indicator line
            Rectangle()
                .fill(Color.white)
                .frame(width: 4, height: barHeight + 10)
                .offset(x: barWidth * viewModel.indicatorPosition - 2)
        }
        .frame(width: barWidth, height: barHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
        )
    }

    @ViewBuilder
    private func resultFeedback(_ result: CatchResult) -> some View {
        switch result {
        case .miss:
            Text("Miss!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
        case .success:
            Text("Catch!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
        case .perfect:
            Text("Perfect!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
        }
    }
}
