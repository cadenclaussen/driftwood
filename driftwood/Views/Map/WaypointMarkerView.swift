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
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(isCurrentLocation ? Color.green : Color(red: 0.6, green: 0.3, blue: 0.8))
                        .frame(width: 32, height: 32)
                    Image(systemName: isCurrentLocation ? "checkmark" : "arrow.up.and.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                Text(pad.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
            }
            .opacity(isSelectable || isCurrentLocation ? 1.0 : 0.5)
        }
        .disabled(!isSelectable || isCurrentLocation)
        .frame(width: 60, height: 50)
    }
}
