//
//  FishingViewModel.swift
//  driftwood
//

import SwiftUI
import Combine

@MainActor
class FishingViewModel: ObservableObject {
    // indicator position (0-1)
    @Published var indicatorPosition: CGFloat = 0
    @Published var isAnimating: Bool = false

    // catch zones (0-1 range)
    @Published var greenZoneStart: CGFloat = 0
    @Published var greenZoneWidth: CGFloat = 0.18
    @Published var perfectZoneStart: CGFloat = 0
    @Published var perfectZoneWidth: CGFloat = 0.05

    // session state
    @Published var remainingCatches: Int = 1
    @Published var sessionCatches: [FishingCatch] = []
    @Published var comboCount: Int = 0
    @Published var lastCatchResult: CatchResult?
    @Published var isSessionComplete: Bool = false

    var fishingState: FishingState

    private var indicatorDirection: CGFloat = 1
    private let indicatorSpeed: CGFloat = 0.8 // full sweep in ~1.25 seconds
    private var animationCancellable: AnyCancellable?
    private let inventoryViewModel: InventoryViewModel
    private let level: Int
    private var sessionFortune: Int

    // track collected armor pieces for this profile
    private var collectedOldPieces: Set<ArmorSlotType> = []
    private var collectedMossyPieces: Set<ArmorSlotType> = []

    init(fortune: Int, level: Int, inventoryViewModel: InventoryViewModel, fishingState: FishingState) {
        self.level = level
        self.inventoryViewModel = inventoryViewModel
        self.fishingState = fishingState
        self.sessionFortune = fortune

        // calculate catches: floor(fortune / 10) + 1
        self.remainingCatches = (fortune / 10) + 1

        // scan inventory for already collected armor pieces
        scanCollectedArmorPieces()

        // setup first catch
        setupNextCatch()
        startAnimation()
    }

    deinit {
        animationCancellable?.cancel()
    }

    // MARK: - Animation

    func startAnimation() {
        isAnimating = true
        animationCancellable = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateIndicator()
            }
    }

    func stopAnimation() {
        isAnimating = false
        animationCancellable?.cancel()
        animationCancellable = nil
    }

    private func updateIndicator() {
        let deltaTime: CGFloat = 1.0 / 60.0
        indicatorPosition += indicatorDirection * indicatorSpeed * deltaTime

        // bounce at edges
        if indicatorPosition >= 1 {
            indicatorPosition = 1
            indicatorDirection = -1
        } else if indicatorPosition <= 0 {
            indicatorPosition = 0
            indicatorDirection = 1
        }
    }

    // MARK: - Catch Mechanics

    func attemptCatch() -> CatchResult {
        stopAnimation()

        let result: CatchResult

        // check if in perfect zone
        let perfectEnd = perfectZoneStart + perfectZoneWidth
        if indicatorPosition >= perfectZoneStart && indicatorPosition <= perfectEnd {
            let item = rollLoot()
            result = .perfect(item: item)
            comboCount += 1
            sessionFortune += 1 // combo bonus
        }
        // check if in green zone
        else {
            let greenEnd = greenZoneStart + greenZoneWidth
            if indicatorPosition >= greenZoneStart && indicatorPosition <= greenEnd {
                let item = rollLoot()
                result = .success(item: item)
                comboCount = 0
            } else {
                result = .miss
                comboCount = 0
            }
        }

        lastCatchResult = result

        if result.isSuccess {
            // perfect catches don't consume a catch
            if !result.isPerfect {
                remainingCatches -= 1
            }

            if remainingCatches > 0 {
                // brief delay then next catch
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    await MainActor.run {
                        self.setupNextCatch()
                        self.startAnimation()
                        self.lastCatchResult = nil
                    }
                }
            } else {
                isSessionComplete = true
            }
        } else {
            isSessionComplete = true
        }

        return result
    }

    private func rollLoot() -> FishingCatch {
        let item = FishingLootTable.roll(
            level: level,
            collectedOldPieces: collectedOldPieces,
            collectedMossyPieces: collectedMossyPieces
        )

        // track if this is a new armor piece
        if case .armor(let piece) = item {
            if piece.setType == .old {
                collectedOldPieces.insert(piece.slot)
            } else if piece.setType == .mossy {
                collectedMossyPieces.insert(piece.slot)
            }
        }

        // try to add to inventory
        let added = inventoryViewModel.addItem(item)

        // update fishing state
        fishingState.addCatch()

        var catch_ = FishingCatch(item: item)
        catch_.addedToInventory = added
        sessionCatches.append(catch_)

        return catch_
    }

    private func setupNextCatch() {
        // randomize green zone position
        greenZoneWidth = CGFloat.random(in: 0.15...0.20)
        greenZoneStart = CGFloat.random(in: 0...(1 - greenZoneWidth))

        // perfect zone in center of green
        perfectZoneWidth = 0.05
        perfectZoneStart = greenZoneStart + (greenZoneWidth - perfectZoneWidth) / 2

        // reset indicator
        indicatorPosition = 0
        indicatorDirection = 1
    }

    // MARK: - Armor Tracking

    private func scanCollectedArmorPieces() {
        for slot in inventoryViewModel.inventory.collectibles {
            guard let content = slot.content else { continue }
            if case .armor(let piece) = content {
                if piece.setType == .old {
                    collectedOldPieces.insert(piece.slot)
                } else if piece.setType == .mossy {
                    collectedMossyPieces.insert(piece.slot)
                }
            }
        }

        // also check equipped armor
        for piece in inventoryViewModel.inventory.equipment.allPieces {
            if piece.setType == .old {
                collectedOldPieces.insert(piece.slot)
            } else if piece.setType == .mossy {
                collectedMossyPieces.insert(piece.slot)
            }
        }
    }
}
