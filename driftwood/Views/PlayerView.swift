//
//  PlayerView.swift
//  driftwood
//

import SwiftUI

struct PlayerView: View {
    let size: CGFloat
    let facingDirection: FacingDirection
    let isWalking: Bool
    let isAttacking: Bool
    let attackFrame: Int
    let equippedTool: ToolType?

    init(size: CGFloat, facingDirection: FacingDirection, isWalking: Bool = false, isAttacking: Bool = false, attackFrame: Int = 0, equippedTool: ToolType? = nil) {
        self.size = size
        self.facingDirection = facingDirection
        self.isWalking = isWalking
        self.isAttacking = isAttacking
        self.attackFrame = attackFrame
        self.equippedTool = equippedTool
    }

    private var currentSpriteName: String {
        if isAttacking, let attackSprite = facingDirection.attackSpriteName(frame: attackFrame, tool: equippedTool) {
            return attackSprite
        }
        return isWalking ? facingDirection.walkSpriteName : facingDirection.idleSpriteName
    }

    // flip SwordSwingUp sprites to simulate other directions
    private var attackScaleX: CGFloat {
        guard isAttacking else { return 1 }
        return facingDirection == .left ? -1 : 1
    }

    private var attackScaleY: CGFloat {
        guard isAttacking else { return 1 }
        return facingDirection == .down ? -1 : 1
    }

    var body: some View {
        Image(currentSpriteName)
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
            .scaleEffect(x: attackScaleX, y: attackScaleY)
    }
}
