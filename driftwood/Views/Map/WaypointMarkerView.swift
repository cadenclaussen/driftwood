//
//  WaypointMarkerView.swift
//  driftwood

import SwiftUI

struct WaypointMarkerView: View {
    let pad: TeleportPad
    let isCurrentLocation: Bool
    let isSelectable: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            if isSelectable && !isCurrentLocation {
                onTap()
            }
        }) {
            ZStack {
                Circle()
                    .fill(isCurrentLocation ? Theme.Color.positive : Theme.Color.teleport)
                    .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
                Image(systemName: isCurrentLocation ? "checkmark" : "arrow.up.and.down")
                    .font(.system(size: Theme.Size.iconMicro, weight: .bold))
                    .foregroundColor(Theme.Color.textPrimary)
            }
            .opacity(isSelectable || isCurrentLocation ? Theme.Opacity.full : Theme.Opacity.half)
        }
        .disabled(!isSelectable || isCurrentLocation)
        .frame(width: Theme.Size.waypointMarkerWidth, height: Theme.Size.waypointMarkerHeight)
    }
}
