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

    init(size: CGFloat, facingDirection: FacingDirection, isWalking: Bool = false, isAttacking: Bool = false, attackFrame: Int = 0) {
        self.size = size
        self.facingDirection = facingDirection
        self.isWalking = isWalking
        self.isAttacking = isAttacking
        self.attackFrame = attackFrame
    }

    private var currentSpriteName: String {
        if isAttacking, let attackSprite = facingDirection.attackSpriteName(frame: attackFrame) {
            return attackSprite
        }
        return isWalking ? facingDirection.walkSpriteName : facingDirection.idleSpriteName
    }

    var body: some View {
        Image(currentSpriteName)
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
    }
}
