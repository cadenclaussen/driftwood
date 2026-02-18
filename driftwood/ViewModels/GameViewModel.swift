//
//  GameViewModel.swift
//  driftwood
//

import SwiftUI
import Combine

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var player: Player
    @Published var world: World
    @Published var inventoryViewModel: InventoryViewModel
    @Published var isInventoryOpen: Bool = false
    @Published var isDead: Bool = false

    // tool/fishing state
    @Published var isToolMenuOpen: Bool = false
    @Published var isFishing: Bool = false
    @Published var showingFishingResults: Bool = false
    @Published var fishingViewModel: FishingViewModel?
    @Published var fishingState: FishingState = FishingState()

    // magic state
    @Published var magicState: MagicState = MagicState()
    @Published var magicViewModel: MagicViewModel = MagicViewModel()
    @Published var mpBarFlashing: Bool = false
    var timeSinceLastCast: CGFloat = 0

    // dash animation state
    var dashStartPosition: CGPoint?
    var dashTargetPosition: CGPoint?
    let dashSpeed: CGFloat = 800 // pixels per second

    // notifications
    @Published var showLevelUpNotification: Bool = false
    @Published var levelUpNotificationLevel: Int = 0

    // sailing state
    @Published var sailboat: Sailboat?
    @Published var sailingState: SailingState = SailingState()

    // enemy state
    @Published var slimes: [Slime] = []
    @Published var deathEffects: [SlimeDeathEffect] = []
    @Published var parryFlashEffects: [ParryFlashEffect] = []

    // map/teleport state
    @Published var isMapOpen: Bool = false
    @Published var isMapTeleportMode: Bool = false

    // environment state (day/night and weather)
    @Published var environmentState: EnvironmentState = EnvironmentState()

    @Published var joystickOffset: CGSize = .zero
    @Published var screenFadeOpacity: Double = 0

    var onReturnToMainMenu: (() -> Void)?
    private var deathPosition: CGPoint?
    private var respawnLandPosition: CGPoint?

    var effectiveMaxHealth: Int {
        let bonusHearts = inventoryViewModel.inventory.equipment.totalStats.bonusHearts
        return player.maxHealth + Int(bonusHearts)
    }

    var effectiveMaxMp: CGFloat {
        player.baseMaxMp + magicState.bonusMaxMp
    }

    var currentProfileIndex: Int
    private let tileSize: CGFloat = 24
    private var isDrowning: Bool = false
    private let movementSpeed: CGFloat = 100
    private var gameLoopCancellable: AnyCancellable?
    private var autoSaveCancellable: AnyCancellable?
    private var lastHealth: Int = 5

    init(profile: SaveProfile) {
        self.world = World()
        self.currentProfileIndex = profile.id
        self.inventoryViewModel = InventoryViewModel(inventory: profile.inventory)

        var player = Player(startPosition: profile.position.cgPoint)
        player.lookDirection = profile.lookDirection.cgPoint
        player.facingDirection = profile.facingDirection ?? FacingDirection.from(direction: profile.lookDirection.cgPoint)
        player.health = profile.health
        player.stamina = profile.stamina
        player.mp = profile.mp
        self.player = player
        self.lastHealth = profile.health

        // load fishing state
        self.fishingState = profile.fishingState

        // load magic state (with migration for old saves)
        self.magicState = profile.magicState ?? MagicState()
        self.player.equippedTool = profile.equippedTool

        // load sailing state (only if boat exists)
        if let sailboatPos = profile.sailboatPosition {
            self.sailboat = Sailboat(position: sailboatPos.cgPoint)
            self.player.isSailing = profile.isSailing
        } else {
            self.sailboat = nil
            self.player.isSailing = false
        }

        // load slimes from save or generate defaults
        if let savedSlimes = profile.slimes {
            let defaults = World.defaultSlimeSpawns()
            self.slimes = savedSlimes.map { data in
                var slime = defaults.first { $0.id == data.id } ?? Slime(id: data.id, position: data.position.cgPoint, spawnOrigin: data.position.cgPoint)
                slime.position = data.position.cgPoint
                slime.health = data.health
                slime.isAlive = data.isAlive
                return slime
            }
        } else {
            self.slimes = World.defaultSlimeSpawns()
        }

        // load environment state (with migration for old saves)
        self.environmentState = profile.environmentState ?? EnvironmentState()
    }

    // MARK: - Inventory

    func openInventory() {
        isInventoryOpen = true
        gameLoopCancellable?.cancel()
        gameLoopCancellable = nil
    }

    func closeInventory() {
        isInventoryOpen = false
        inventoryViewModel.clearSelection()
        startGameLoop()
    }

    func useMeal(at index: Int) {
        inventoryViewModel.useMeal(at: index, player: &player, effectiveMaxHealth: effectiveMaxHealth)
        if player.health != lastHealth {
            lastHealth = player.health
            saveCurrentProfile()
        }
    }

    func startGameLoop() {
        gameLoopCancellable = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePlayerPosition()
            }

        // auto-save every 30 seconds
        autoSaveCancellable = Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.saveCurrentProfile()
            }
    }

    func stopGameLoop() {
        gameLoopCancellable?.cancel()
        gameLoopCancellable = nil
        autoSaveCancellable?.cancel()
        autoSaveCancellable = nil
        saveCurrentProfile()
    }

    func createSaveProfile() -> SaveProfile {
        let sailboatPos = sailboat.map { CodablePoint($0.position) }
        let slimeData = slimes.map { $0.toSaveData() }

        // if sailing, save the board position (last land position) and not sailing
        if player.isSailing, let landPosition = player.sailingBoardPosition {
            var landPlayer = player
            landPlayer.position = landPosition
            landPlayer.isSailing = false
            landPlayer.sailingBoardPosition = nil
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, magicState: magicState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos, slimes: slimeData, environmentState: environmentState)
        }

        // if swimming, save the last land position instead of current water position
        if player.isSwimming, let landPosition = player.swimStartPoint {
            var landPlayer = player
            landPlayer.position = landPosition
            landPlayer.isSwimming = false
            landPlayer.swimStartPoint = nil
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, magicState: magicState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos, slimes: slimeData, environmentState: environmentState)
        }

        return SaveProfile(from: player, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, magicState: magicState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos, slimes: slimeData, environmentState: environmentState)
    }

    func saveCurrentProfile() {
        let profile = createSaveProfile()
        SaveManager.shared.saveProfile(profile)
    }

    private func updateStamina(deltaTime: CGFloat, isMoving: Bool) {
        // no stamina drain while sailing
        if player.isSailing {
            if player.stamina < player.maxStamina {
                player.stamina = min(player.stamina + player.staminaRegenRate * deltaTime, player.maxStamina)
            }
            return
        }

        if player.isSwimming {
            if isMoving {
                let drainRate = player.isSprinting ? player.swimSprintStaminaDrainRate : player.swimStaminaDrainRate
                player.stamina -= drainRate * deltaTime
                if player.stamina <= 0 {
                    player.stamina = 0
                    handleStaminaDepleted()
                }
            }
        } else if player.stamina < player.maxStamina {
            player.stamina = min(player.stamina + player.staminaRegenRate * deltaTime, player.maxStamina)
        }
    }

    private func handleStaminaDepleted() {
        guard let startPoint = player.swimStartPoint else { return }
        guard !isDrowning else { return }
        isDrowning = true

        // check if this drowning will kill the player
        let willDie = player.health <= 1

        if willDie {
            deathPosition = player.position
            respawnLandPosition = startPoint
        }

        withAnimation(.easeIn(duration: 0.3)) {
            screenFadeOpacity = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(400))

            if willDie {
                player.health = 0
                lastHealth = 0
                saveCurrentProfile()
                isDead = true
                isDrowning = false
                return
            }

            player.position = startPoint
            player.isSwimming = false
            player.swimStartPoint = nil
            player.health = max(0, player.health - 1) // drowning costs 1 heart

            if player.health != lastHealth {
                lastHealth = player.health
                saveCurrentProfile()
            }

            withAnimation(.easeOut(duration: 0.3)) {
                screenFadeOpacity = 0
            }

            try? await Task.sleep(for: .milliseconds(300))
            isDrowning = false
        }
    }

    // MARK: - Magic/MP

    private func updateMpRegen(deltaTime: CGFloat) {
        timeSinceLastCast += deltaTime

        // base regen: 10 MP/s, bonus after 2s: 20 MP/s
        let regenRate: CGFloat = timeSinceLastCast >= 2.0 ? 20 : 10
        if player.mp < effectiveMaxMp {
            player.mp = min(player.mp + regenRate * deltaTime, effectiveMaxMp)
        }
    }

    private func updateMagic(deltaTime: CGFloat) {
        magicViewModel.update(deltaTime: deltaTime)

        // check for fireball collisions
        checkFireballCollisions()

        // apply tornado pull to enemies
        applyTornadoPull(deltaTime: deltaTime)

        // update dash animation
        updateDash(deltaTime: deltaTime)
    }

    private func checkFireballCollisions() {
        var projectilesToRemove: [UUID] = []

        for projectile in magicViewModel.projectiles {
            // check enemy collision
            var hitEnemy = false
            for i in slimes.indices {
                guard slimes[i].isAlive else { continue }
                let dx = slimes[i].position.x - projectile.position.x
                let dy = slimes[i].position.y - projectile.position.y
                let distance = sqrt(dx * dx + dy * dy)
                if distance < Slime.halfSize + 8 { // projectile radius ~8
                    hitEnemy = true
                    break
                }
            }

            // check obstacle collision (tile-based)
            let tileX = Int(projectile.position.x / tileSize)
            let tileY = Int(projectile.position.y / tileSize)
            let tile = world.tiles[safe: tileY]?[safe: tileX]
            var hitObstacle = tile?.blocksProjectiles ?? true

            // check rock collision bounds
            if !hitObstacle {
                let projectileRadius: CGFloat = 8
                let projectileRect = CGRect(
                    x: projectile.position.x - projectileRadius,
                    y: projectile.position.y - projectileRadius,
                    width: projectileRadius * 2,
                    height: projectileRadius * 2
                )
                for rock in world.rockOverlays {
                    if projectileRect.intersects(rock.collisionRect(tileSize: tileSize)) {
                        hitObstacle = true
                        break
                    }
                }
            }

            if hitEnemy || hitObstacle {
                // create explosion and deal AoE damage
                magicViewModel.createExplosion(at: projectile.position)
                dealFireballAoeDamage(at: projectile.position, radius: projectile.aoeRadius, damage: projectile.damage)
                projectilesToRemove.append(projectile.id)
            }
        }

        for id in projectilesToRemove {
            magicViewModel.removeProjectile(id: id)
        }
    }

    private func dealFireballAoeDamage(at position: CGPoint, radius: CGFloat, damage: Int) {
        for i in slimes.indices {
            guard slimes[i].isAlive else { continue }
            let dx = slimes[i].position.x - position.x
            let dy = slimes[i].position.y - position.y
            let distance = sqrt(dx * dx + dy * dy)
            if distance <= radius {
                damageSlime(index: i, damage: damage)
            }
        }
    }

    private func applyTornadoPull(deltaTime: CGFloat) {
        for tornado in magicViewModel.tornados {
            guard tornado.isActive else { continue }
            for i in slimes.indices {
                guard slimes[i].isAlive else { continue }
                if tornado.containsPoint(slimes[i].position) {
                    let dir = tornado.pullDirection(from: slimes[i].position)
                    let pullAmount = tornado.pullForce * deltaTime
                    slimes[i].position.x += dir.x * pullAmount
                    slimes[i].position.y += dir.y * pullAmount
                }
            }
        }

        // apply slow debuff when tornado ends
        for tornado in magicViewModel.tornados where !tornado.isActive {
            for i in slimes.indices {
                guard slimes[i].isAlive else { continue }
                if tornado.containsPoint(slimes[i].position) {
                    slimes[i].slowTimer = Slime.slowDuration
                }
            }
        }
    }

    // MARK: - Environment (Day/Night + Weather)

    private var isGameplayPaused: Bool {
        isInventoryOpen || isFishing || isDead || screenFadeOpacity > 0 || isMapOpen || showingFishingResults
    }

    private func updateEnvironment(deltaTime: CGFloat) {
        guard !isGameplayPaused else { return }
        updateDayNight(deltaTime: deltaTime)
        updateWeather(deltaTime: deltaTime)
    }

    private func updateDayNight(deltaTime: CGFloat) {
        environmentState.timeOfDay += deltaTime / EnvironmentState.cycleDuration
        if environmentState.timeOfDay >= 1.0 {
            environmentState.timeOfDay = environmentState.timeOfDay.truncatingRemainder(dividingBy: 1.0)
        }
    }

    private func updateWeather(deltaTime: CGFloat) {
        // handle transition in progress
        if environmentState.weatherTransitionProgress < 1.0 {
            environmentState.weatherTransitionProgress += deltaTime / EnvironmentState.transitionDuration
            if environmentState.weatherTransitionProgress >= 1.0 {
                environmentState.weatherTransitionProgress = 1.0
                environmentState.currentWeather = environmentState.targetWeather
            }
            return
        }

        // advance weather timer
        environmentState.weatherTimer += deltaTime
        if environmentState.weatherTimer >= environmentState.nextWeatherChangeTime {
            pickNextWeatherTarget()
        }
    }

    private func pickNextWeatherTarget() {
        let adjacentTypes = environmentState.currentWeather.adjacentTypes
        guard !adjacentTypes.isEmpty else { return }

        let newTarget = adjacentTypes.randomElement()!
        environmentState.targetWeather = newTarget
        environmentState.weatherTransitionProgress = 0
        environmentState.weatherTimer = 0
        environmentState.nextWeatherChangeTime = CGFloat.random(
            in: EnvironmentState.minWeatherDuration...EnvironmentState.maxWeatherDuration
        )
    }

    func getDayNightTint() -> (color: Color, brightness: CGFloat) {
        let time = environmentState.timeOfDay

        // define phase colors and brightness
        // dawn (0.0-0.25): warm orange, 80%
        // day (0.25-0.5): white, 100%
        // dusk (0.5-0.75): orange/pink, 70%
        // night (0.75-1.0): blue, 50%

        let dawnColor = Color(red: 1.0, green: 0.85, blue: 0.7)
        let dayColor = Color.white
        let duskColor = Color(red: 1.0, green: 0.7, blue: 0.55)
        let nightColor = Color(red: 0.55, green: 0.6, blue: 0.8)

        let dawnBrightness: CGFloat = 0.8
        let dayBrightness: CGFloat = 1.0
        let duskBrightness: CGFloat = 0.7
        let nightBrightness: CGFloat = 0.5

        // calculate position within current phase and interpolate
        switch time {
        case 0..<0.25: // dawn
            let progress = time / 0.25
            let color = interpolateColor(from: nightColor, to: dawnColor, progress: progress)
            let brightness = nightBrightness + (dawnBrightness - nightBrightness) * progress
            return (color, brightness)
        case 0.25..<0.5: // day (dawn -> day)
            let progress = (time - 0.25) / 0.25
            let color = interpolateColor(from: dawnColor, to: dayColor, progress: progress)
            let brightness = dawnBrightness + (dayBrightness - dawnBrightness) * progress
            return (color, brightness)
        case 0.5..<0.75: // dusk (day -> dusk)
            let progress = (time - 0.5) / 0.25
            let color = interpolateColor(from: dayColor, to: duskColor, progress: progress)
            let brightness = dayBrightness + (duskBrightness - dayBrightness) * progress
            return (color, brightness)
        default: // night (dusk -> night)
            let progress = (time - 0.75) / 0.25
            let color = interpolateColor(from: duskColor, to: nightColor, progress: progress)
            let brightness = duskBrightness + (nightBrightness - duskBrightness) * progress
            return (color, brightness)
        }
    }

    private func interpolateColor(from: Color, to: Color, progress: CGFloat) -> Color {
        // simple linear interpolation - SwiftUI colors
        // we'll blend using overlay approach in the view instead
        // return the dominant color based on progress
        if progress < 0.5 {
            return from
        } else {
            return to
        }
    }

    private func damageSlime(index: Int, damage: Int) {
        slimes[index].health -= damage
        slimes[index].hitFlashTimer = Slime.hitFlashDuration
        if slimes[index].health <= 0 {
            slimes[index].isAlive = false
            deathEffects.append(SlimeDeathEffect(position: slimes[index].position))
        }
    }

    // MARK: - Spell Casting

    func castFireball() {
        // check if cast would fail due to insufficient MP
        if player.mp < CGFloat(SpellType.fireball.mpCost) && !magicViewModel.isOnCooldown(.fireball) {
            flashMpBar()
            return
        }

        guard magicViewModel.canCast(.fireball, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else { return }

        // toggle fireball equipped state
        magicViewModel.toggleFireballEquipped()
    }

    func castDash() {
        // check if cast would fail due to insufficient MP
        if player.mp < CGFloat(SpellType.dash.mpCost) && !magicViewModel.isOnCooldown(.dash) {
            flashMpBar()
            return
        }

        guard magicViewModel.canCast(.dash, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else { return }

        executeDash()
    }

    func shootFireballAt(screenOffset: CGPoint) {
        guard magicViewModel.isFireballEquipped else { return }
        guard magicViewModel.canCast(.fireball, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else {
            magicViewModel.unequipFireball()
            return
        }

        // calculate direction from player to tap position
        let length = sqrt(screenOffset.x * screenOffset.x + screenOffset.y * screenOffset.y)
        guard length > 10 else { return }

        let direction = CGPoint(x: screenOffset.x / length, y: screenOffset.y / length)
        executeFireball(direction: direction)
    }

    func castSpell(slotIndex: Int) {
        guard let spell = magicState.equippedSpells[safe: slotIndex] ?? nil else { return }

        // check if cast would fail due to insufficient MP
        if player.mp < CGFloat(spell.mpCost) && !magicViewModel.isOnCooldown(spell) {
            flashMpBar()
            return
        }

        guard magicViewModel.canCast(spell, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else { return }

        switch spell {
        case .dash:
            executeDash()
        case .fireball:
            magicViewModel.toggleFireballEquipped()
        case .tornado:
            // tornado requires tap-to-place, immediate tap places at player position
            executeTornado(at: player.position)
        }
    }

    private func flashMpBar() {
        mpBarFlashing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.mpBarFlashing = false
        }
    }

    func startSpellAim(slotIndex: Int) {
        guard let spell = magicState.equippedSpells[safe: slotIndex] ?? nil else { return }

        // check if cast would fail due to insufficient MP
        if player.mp < CGFloat(spell.mpCost) && !magicViewModel.isOnCooldown(spell) {
            flashMpBar()
            return
        }

        guard magicViewModel.canCast(spell, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else { return }

        switch spell {
        case .fireball:
            magicViewModel.startFireballAim()
        case .tornado:
            magicViewModel.startTornadoPlacement()
        case .dash:
            break
        }
    }

    func updateSpellAim(offset: CGPoint) {
        if magicViewModel.isAimingFireball {
            // normalize direction
            let length = sqrt(offset.x * offset.x + offset.y * offset.y)
            if length > 10 {
                let direction = CGPoint(x: offset.x / length, y: offset.y / length)
                magicViewModel.updateFireballAim(direction: direction)
            }
        } else if magicViewModel.isPlacingTornado {
            // offset from player position
            let targetPos = CGPoint(
                x: player.position.x + offset.x,
                y: player.position.y + offset.y
            )
            magicViewModel.updateTornadoTarget(position: targetPos)
        }
    }

    func endSpellAim() {
        if magicViewModel.isAimingFireball {
            if let direction = magicViewModel.fireballAimDirection {
                executeFireball(direction: direction)
            }
            magicViewModel.cancelFireballAim()
        } else if magicViewModel.isPlacingTornado {
            if let targetPos = magicViewModel.tornadoTargetPosition {
                executeTornado(at: targetPos)
            } else {
                // no drag, place at player
                executeTornado(at: player.position)
            }
            magicViewModel.cancelTornadoPlacement()
        }
    }

    private func executeDash() {
        guard magicViewModel.canCast(.dash, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else { return }

        player.mp -= CGFloat(SpellType.dash.mpCost)
        timeSinceLastCast = 0
        magicViewModel.startDashCooldown()

        // calculate dash target (3 tiles = 72pt)
        let dashDistance: CGFloat = 72
        let direction = facingToVector(player.facingDirection)
        let dx = direction.x * dashDistance
        let dy = direction.y * dashDistance
        var targetPos = CGPoint(x: player.position.x + dx, y: player.position.y + dy)

        // clamp to valid position (check path)
        targetPos = findValidDashTarget(from: player.position, toward: targetPos)

        // start dash animation
        player.isDashing = true
        dashStartPosition = player.position
        dashTargetPosition = targetPos
    }

    private func updateDash(deltaTime: CGFloat) {
        guard player.isDashing, let target = dashTargetPosition else { return }

        let dx = target.x - player.position.x
        let dy = target.y - player.position.y
        let distance = sqrt(dx * dx + dy * dy)

        // reached target
        if distance < 5 {
            player.position = target
            player.isDashing = false
            dashStartPosition = nil
            dashTargetPosition = nil
            return
        }

        // move toward target
        let moveDistance = dashSpeed * deltaTime
        if moveDistance >= distance {
            player.position = target
            player.isDashing = false
            dashStartPosition = nil
            dashTargetPosition = nil
        } else {
            let ratio = moveDistance / distance
            player.position.x += dx * ratio
            player.position.y += dy * ratio
        }
    }

    private func findValidDashTarget(from start: CGPoint, toward end: CGPoint) -> CGPoint {
        // check multiple points along path
        let steps = 10
        var lastValid = start

        // player hitbox dimensions (same as canMoveTo)
        let halfWidth: CGFloat = 12
        let halfHeight: CGFloat = 16
        let treeOverlap: CGFloat = 20

        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let checkPos = CGPoint(
                x: start.x + (end.x - start.x) * t,
                y: start.y + (end.y - start.y) * t
            )

            // check all tiles the player hitbox overlaps (same as canMoveTo)
            let leftTile = Int(floor((checkPos.x - halfWidth) / tileSize))
            let rightTile = Int(floor((checkPos.x + halfWidth - 0.01) / tileSize))
            let topTile = Int(floor((checkPos.y - halfHeight) / tileSize))
            let bottomTile = Int(floor((checkPos.y + halfHeight - 0.01) / tileSize))

            var hitsTile = false
            for tileY in topTile...bottomTile {
                for tileX in leftTile...rightTile {
                    let tile = world.tile(at: tileX, y: tileY)
                    if !tile.isWalkable && !tile.isSwimmable {
                        // check tree trunk depth overlap
                        if let treeTrunk = treeTrunkAt(tileX: tileX, tileY: tileY) {
                            let trunkBottomY = CGFloat(treeTrunk.y + treeTrunk.size) * tileSize
                            if checkPos.y > trunkBottomY - tileSize * 2 {
                                let trunkBottomTile = treeTrunk.y + treeTrunk.size - 1
                                if tileY == trunkBottomTile {
                                    let reducedTopTile = Int(floor((checkPos.y - halfHeight + treeOverlap) / tileSize))
                                    if tileY < reducedTopTile {
                                        continue
                                    }
                                }
                            }
                        }
                        hitsTile = true
                        break
                    }
                }
                if hitsTile { break }
            }
            if hitsTile { break }

            // check rock collision bounds with depth adjustment
            let playerRect = CGRect(
                x: checkPos.x - halfWidth,
                y: checkPos.y - halfHeight,
                width: halfWidth * 2,
                height: halfHeight * 2
            )
            var hitsRock = false
            for rock in world.rockOverlays {
                if playerRect.intersects(rock.depthCollisionRect(tileSize: tileSize, playerY: checkPos.y)) {
                    hitsRock = true
                    break
                }
            }
            if hitsRock { break }

            lastValid = checkPos
        }

        return lastValid
    }

    private func executeFireball(direction: CGPoint) {
        guard magicViewModel.canCast(.fireball, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else { return }

        player.mp -= CGFloat(SpellType.fireball.mpCost)
        timeSinceLastCast = 0

        let damage = SpellType.fireball.baseDamage + (magicState.spellTiers[SpellType.fireball.rawValue] ?? 0)
        magicViewModel.createFireball(at: player.position, direction: direction, damage: damage)
    }

    private func executeTornado(at position: CGPoint) {
        guard magicViewModel.canCast(.tornado, mp: player.mp, isSwimming: player.isSwimming, isSailing: player.isSailing) else { return }

        player.mp -= CGFloat(SpellType.tornado.mpCost)
        timeSinceLastCast = 0
        magicViewModel.createTornado(at: position)
    }

    func respawn() {
        // if died in water, respawn at last land position; otherwise at death position
        let respawnPosition = respawnLandPosition ?? deathPosition ?? player.position

        player.position = respawnPosition
        player.isSwimming = false
        player.swimStartPoint = nil
        player.health = effectiveMaxHealth
        player.stamina = player.maxStamina
        player.mp = effectiveMaxMp

        // reset cooldowns on respawn
        magicViewModel.cooldowns = [:]
        timeSinceLastCast = 0

        // reset combat states
        resetCombatStates()

        lastHealth = player.health
        saveCurrentProfile()

        deathPosition = nil
        respawnLandPosition = nil

        withAnimation(.easeOut(duration: 0.3)) {
            screenFadeOpacity = 0
        }

        isDead = false
    }

    func returnToMainMenu() {
        // respawn player before returning to menu so they're alive when they return
        let respawnPosition = respawnLandPosition ?? deathPosition ?? player.position
        player.position = respawnPosition
        player.isSwimming = false
        player.swimStartPoint = nil
        player.health = effectiveMaxHealth
        player.stamina = player.maxStamina
        isDead = false
        deathPosition = nil
        respawnLandPosition = nil

        saveCurrentProfile()
        stopGameLoop()
        onReturnToMainMenu?()
    }

    // MARK: - Block/Parry System

    var canBlock: Bool {
        !player.isSwimming &&
        !player.isSailing &&
        !player.isAttacking &&
        !player.isCharging &&
        player.blockCooldownTimer <= 0
    }

    func startBlock() {
        guard canBlock else { return }
        player.isBlocking = true
        player.blockStartTime = CACurrentMediaTime()
    }

    func endBlock() {
        guard player.isBlocking else { return }
        player.isBlocking = false
        player.blockCooldownTimer = Player.blockCooldown
    }

    private func updateBlock(deltaTime: CGFloat) {
        // decrement cooldown
        if player.blockCooldownTimer > 0 {
            player.blockCooldownTimer = max(0, player.blockCooldownTimer - deltaTime)
        }

        guard player.isBlocking else { return }

        // auto-end after max duration
        let elapsed = CGFloat(CACurrentMediaTime() - player.blockStartTime)
        if elapsed >= Player.blockDuration {
            endBlock()
        }
    }

    private func isInParryWindow() -> Bool {
        guard player.isBlocking else { return false }
        let elapsed = CGFloat(CACurrentMediaTime() - player.blockStartTime)
        return elapsed <= Player.parryWindow
    }

    private func triggerParry(slimeIndex: Int) {
        // stun the enemy
        slimes[slimeIndex].isStunned = true
        slimes[slimeIndex].stunEndTime = Slime.parryStunDuration

        // knockback enemy away from player
        let dir = CGPoint(
            x: slimes[slimeIndex].position.x - player.position.x,
            y: slimes[slimeIndex].position.y - player.position.y
        )
        applyKnockback(
            position: &slimes[slimeIndex].position,
            direction: dir,
            distance: Slime.parryKnockback,
            halfWidth: Slime.halfSize,
            halfHeight: Slime.halfSize
        )

        // create parry flash effect at player position
        parryFlashEffects.append(ParryFlashEffect(position: player.position))
    }

    private func updateParryEffects(deltaTime: CGFloat) {
        for i in (0..<parryFlashEffects.count).reversed() {
            parryFlashEffects[i].elapsed += deltaTime
            if parryFlashEffects[i].elapsed >= ParryFlashEffect.duration {
                parryFlashEffects.remove(at: i)
            }
        }
    }

    // MARK: - Charged Attack System

    var canCharge: Bool {
        !player.isSwimming &&
        !player.isSailing &&
        !player.isBlocking &&
        !player.isAttacking &&
        player.equippedTool == .sword
    }

    func startCharge() {
        guard canCharge else { return }
        player.isCharging = true
        player.chargeStartTime = CACurrentMediaTime()
        player.chargeProgress = 0
    }

    func releaseCharge() {
        guard player.isCharging else { return }

        // calculate damage multiplier based on charge progress
        // 0% = 1x, 100% = 2x
        let damageMultiplier = 1.0 + player.chargeProgress * (Player.maxChargeDamageMultiplier - 1.0)

        // charged attacks (any charge > 0) are AoE
        let isCharged = player.chargeProgress > 0.1

        player.isCharging = false
        player.chargeProgress = 0

        // perform sword swing with damage multiplier and AoE flag
        startSwordSwing(damageMultiplier: Int(ceil(damageMultiplier)), isCharged: isCharged)
    }

    private func cancelCharge() {
        player.isCharging = false
        player.chargeProgress = 0
    }

    private func updateCharge(deltaTime: CGFloat) {
        guard player.isCharging else { return }

        // cancel if now invalid state
        if player.isSwimming || player.isSailing || player.isBlocking {
            cancelCharge()
            return
        }

        let elapsed = CGFloat(CACurrentMediaTime() - player.chargeStartTime)
        player.chargeProgress = min(1.0, elapsed / Player.chargeTime)
    }

    private func resetCombatStates() {
        player.isBlocking = false
        player.blockCooldownTimer = 0
        cancelCharge()
    }

    private func updatePlayerPosition() {
        let deltaTime: CGFloat = 1.0 / 60.0
        let maxRadius = (120.0 - 50.0) / 2
        let distance = hypot(joystickOffset.width, joystickOffset.height)
        let isMoving = distance > 0

        player.isWalking = isMoving && !player.isSailing && !player.isBlocking

        updateAttackAnimation(deltaTime: deltaTime)
        updateStamina(deltaTime: deltaTime, isMoving: isMoving)
        updateMpRegen(deltaTime: deltaTime)
        updateMagic(deltaTime: deltaTime)
        updateBlock(deltaTime: deltaTime)
        updateCharge(deltaTime: deltaTime)
        updateSlimes(deltaTime: deltaTime)
        checkSlimeContactDamage()
        checkSwordHits()
        updateDeathEffects(deltaTime: deltaTime)
        updateParryEffects(deltaTime: deltaTime)
        updateEnvironment(deltaTime: deltaTime)

        // handle sailing movement
        if player.isSailing {
            updateSailingPosition(deltaTime: deltaTime, distance: distance, maxRadius: maxRadius)
            return
        }

        // skip normal movement during dash (dash handles its own movement)
        if player.isDashing { return }

        // no movement while blocking
        if player.isBlocking {
            // still allow changing facing direction
            if isMoving {
                player.lookDirection = CGPoint(
                    x: joystickOffset.width / distance,
                    y: joystickOffset.height / distance
                )
                player.facingDirection = FacingDirection.from(direction: player.lookDirection)
            }
            return
        }

        guard isMoving else { return }

        let clampedDistance = min(distance, maxRadius)
        let normalizedX = (joystickOffset.width / distance) * (clampedDistance / maxRadius)
        let normalizedY = (joystickOffset.height / distance) * (clampedDistance / maxRadius)

        var speedMultiplier: CGFloat
        if player.isSwimming {
            speedMultiplier = player.isSprinting ? 0.8 : player.swimSpeedMultiplier
        } else {
            speedMultiplier = player.isSprinting ? player.sprintSpeedMultiplier : 1.0
        }
        // apply charging movement penalty
        if player.isCharging {
            speedMultiplier *= Player.chargingMoveSpeedMultiplier
        }
        let currentSpeed = movementSpeed * speedMultiplier
        let deltaX = normalizedX * currentSpeed * deltaTime
        let deltaY = normalizedY * currentSpeed * deltaTime

        let previousPosition = player.position

        let newPosition = CGPoint(
            x: player.position.x + deltaX,
            y: player.position.y + deltaY
        )

        if canMoveTo(newPosition) {
            player.position = newPosition
        } else {
            let slideX = CGPoint(x: player.position.x + deltaX, y: player.position.y)
            if canMoveTo(slideX) {
                player.position = slideX
            }
            let slideY = CGPoint(x: player.position.x, y: player.position.y + deltaY)
            if canMoveTo(slideY) {
                player.position = slideY
            }
        }

        player.lookDirection = CGPoint(
            x: joystickOffset.width / distance,
            y: joystickOffset.height / distance
        )
        player.facingDirection = FacingDirection.from(direction: player.lookDirection)

        updateSwimmingState(previousPosition: previousPosition)
    }

    private func updateSailingPosition(deltaTime: CGFloat, distance: CGFloat, maxRadius: CGFloat) {
        // update wind (weather affects drift rate)
        let weatherDriftMult = environmentState.effectiveWindDriftMultiplier
        sailingState.updateWind(deltaTime: deltaTime, driftMultiplier: weatherDriftMult)

        // calculate joystick velocity
        var deltaX: CGFloat = 0
        var deltaY: CGFloat = 0

        if distance > 0 {
            let clampedDistance = min(distance, maxRadius)
            let normalizedX = (joystickOffset.width / distance) * (clampedDistance / maxRadius)
            let normalizedY = (joystickOffset.height / distance) * (clampedDistance / maxRadius)

            // sailing speed: 4x swim speed = 2x walk speed
            let sailingSpeed = movementSpeed * player.swimSpeedMultiplier * player.sailingSpeedMultiplier
            deltaX = normalizedX * sailingSpeed * deltaTime
            deltaY = normalizedY * sailingSpeed * deltaTime

            // update facing direction
            player.lookDirection = CGPoint(
                x: joystickOffset.width / distance,
                y: joystickOffset.height / distance
            )
            player.facingDirection = FacingDirection.from(direction: player.lookDirection)
        }

        // add wind push (weather affects wind strength)
        let weatherWindMult = environmentState.effectiveWindMultiplier
        let windPush = sailingState.windDirection
        deltaX += windPush.x * sailingState.windStrength * weatherWindMult * deltaTime
        deltaY += windPush.y * sailingState.windStrength * weatherWindMult * deltaTime

        let newPosition = CGPoint(
            x: player.position.x + deltaX,
            y: player.position.y + deltaY
        )

        // use sailing collision check
        if canSailTo(newPosition) {
            player.position = newPosition
            sailboat?.position = newPosition
        } else {
            // slide movement
            let slideX = CGPoint(x: player.position.x + deltaX, y: player.position.y)
            if canSailTo(slideX) {
                player.position = slideX
                sailboat?.position = slideX
            }
            let slideY = CGPoint(x: player.position.x, y: player.position.y + deltaY)
            if canSailTo(slideY) {
                player.position = slideY
                sailboat?.position = slideY
            }
        }
    }

    private func canSailTo(_ position: CGPoint) -> Bool {
        // boat hitbox: 64x64 sprite with 18px inset on each side = 28x28 collision
        let halfSize: CGFloat = 14

        let leftTile = Int(floor((position.x - halfSize) / tileSize))
        let rightTile = Int(floor((position.x + halfSize - 0.01) / tileSize))
        let topTile = Int(floor((position.y - halfSize) / tileSize))
        let bottomTile = Int(floor((position.y + halfSize - 0.01) / tileSize))

        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                if !world.tile(at: tileX, y: tileY).isSwimmable {
                    return false
                }
            }
        }
        return true
    }

    private func canMoveTo(_ position: CGPoint) -> Bool {
        // player hitbox: 24 wide x 32 tall (4 pixel margin on each side horizontally)
        let halfWidth: CGFloat = 12
        let halfHeight: CGFloat = 16
        let treeOverlap: CGFloat = 20  // how much head can overlap into tree trunk

        // get tile range that the player hitbox overlaps
        let leftTile = Int(floor((position.x - halfWidth) / tileSize))
        let rightTile = Int(floor((position.x + halfWidth - 0.01) / tileSize))
        let topTile = Int(floor((position.y - halfHeight) / tileSize))
        let bottomTile = Int(floor((position.y + halfHeight - 0.01) / tileSize))

        // check all tiles the hitbox overlaps
        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                let tile = world.tile(at: tileX, y: tileY)
                if !tile.isWalkable && !tile.isSwimmable {
                    // check if this is a tree trunk tile (allow depth overlap)
                    if let treeTrunk = treeTrunkAt(tileX: tileX, tileY: tileY) {
                        let trunkBottomY = CGFloat(treeTrunk.y + treeTrunk.size) * tileSize
                        // allow overlap when player is below tree (head goes into trunk)
                        if position.y > trunkBottomY - tileSize * 2 {
                            // check if this tile is in the overlap zone (bottom portion of trunk)
                            let trunkBottomTile = treeTrunk.y + treeTrunk.size - 1
                            if tileY == trunkBottomTile {
                                // tile is in overlap zone if it's above the reduced top
                                let reducedTopTile = Int(floor((position.y - halfHeight + treeOverlap) / tileSize))
                                if tileY < reducedTopTile {
                                    continue  // allow this overlap
                                }
                            }
                        }
                    }
                    return false
                }
            }
        }

        // check rock collision bounds with depth adjustment
        let playerRect = CGRect(
            x: position.x - halfWidth,
            y: position.y - halfHeight,
            width: halfWidth * 2,
            height: halfHeight * 2
        )
        for rock in world.rockOverlays {
            let rockRect = rock.depthCollisionRect(tileSize: tileSize, playerY: position.y)
            if playerRect.intersects(rockRect) {
                return false
            }
        }

        return true
    }

    private func treeTrunkAt(tileX: Int, tileY: Int) -> GroundSprite? {
        for sprite in world.groundSprites {
            let spriteLeft = sprite.x
            let spriteRight = sprite.x + sprite.size - 1
            let spriteTop = sprite.y
            let spriteBottom = sprite.y + sprite.size - 1

            if tileX >= spriteLeft && tileX <= spriteRight &&
               tileY >= spriteTop && tileY <= spriteBottom {
                return sprite
            }
        }
        return nil
    }

    private func isInWater(_ position: CGPoint) -> Bool {
        let tileX = Int(position.x / tileSize)
        let tileY = Int(position.y / tileSize)
        return world.tile(at: tileX, y: tileY).isSwimmable
    }

    private func updateSwimmingState(previousPosition: CGPoint) {
        let wasSwimming = player.isSwimming
        let nowInWater = isInWater(player.position)

        if nowInWater && !wasSwimming {
            player.isSwimming = true
            player.swimStartPoint = previousPosition
            // cancel block/charge when entering water
            resetCombatStates()
        } else if !nowInWater && wasSwimming {
            player.isSwimming = false
            player.swimStartPoint = nil
        }
    }

    // MARK: - Tools

    func equipTool(_ tool: ToolType?) {
        player.equippedTool = tool
        isToolMenuOpen = false
    }

    func openToolMenu() {
        isToolMenuOpen = true
    }

    func closeToolMenu() {
        isToolMenuOpen = false
    }

    func ownedTools() -> [ToolType] {
        var tools: [ToolType] = []
        if inventoryViewModel.inventory.tools.fishingRodTier > 0 {
            tools.append(.fishingRod)
        }
        if inventoryViewModel.inventory.tools.swordTier > 0 {
            tools.append(.sword)
        }
        if inventoryViewModel.inventory.tools.axeTier > 0 {
            tools.append(.axe)
        }
        return tools
    }

    // MARK: - Tool Actions

    var canUseTool: Bool {
        guard let tool = player.equippedTool else { return false }
        if player.isAttacking { return false }
        switch tool {
        case .fishingRod:
            return isFacingWater() && !player.isSwimming
        case .sword:
            return inventoryViewModel.inventory.tools.swordTier > 0 && !player.isSwimming
        case .axe:
            return isFacingTree() && !player.isSwimming
        }
    }

    func useTool() {
        guard let tool = player.equippedTool else { return }
        switch tool {
        case .fishingRod:
            startFishing()
        case .sword:
            startSwordSwing()
        case .axe:
            useAxe()
        }
    }

    // MARK: - Axe

    func useAxe() {
        guard !player.isAttacking, !player.isSwimming, isFacingTree() else { return }
        player.isAttacking = true
        player.attackAnimationFrame = 1
        player.attackAnimationTime = 0
        player.attackSwingId += 1
        player.currentSwingDamage = 1
        player.isChargedAttack = false

        _ = inventoryViewModel.addItem(.resource(type: .wood, quantity: 1))
        saveCurrentProfile()
    }

    // MARK: - Sword

    func startSwordSwing(damageMultiplier: Int = 1, isCharged: Bool = false) {
        guard !player.isAttacking, !player.isSwimming else { return }
        player.isAttacking = true
        player.attackAnimationFrame = 1
        player.attackAnimationTime = 0
        player.attackSwingId += 1
        player.currentSwingDamage = damageMultiplier
        player.isChargedAttack = isCharged
    }

    private func updateAttackAnimation(deltaTime: CGFloat) {
        // decrement invincibility timer
        if player.invincibilityTimer > 0 {
            player.invincibilityTimer = max(0, player.invincibilityTimer - deltaTime)
        }

        guard player.isAttacking else { return }

        player.attackAnimationTime += deltaTime
        let frameIndex = Int(player.attackAnimationTime / Player.attackFrameDuration) + 1
        if frameIndex > Player.attackFrameCount {
            player.isAttacking = false
            player.attackAnimationFrame = 0
            player.attackAnimationTime = 0
        } else {
            player.attackAnimationFrame = frameIndex
        }
    }

    // MARK: - Directional Detection

    private func facingOffset() -> (dx: Int, dy: Int) {
        switch player.facingDirection {
        case .up: return (0, -1)
        case .down: return (0, 1)
        case .left: return (-1, 0)
        case .right: return (1, 0)
        }
    }

    private func facingToVector(_ facing: FacingDirection) -> CGPoint {
        switch facing {
        case .up: return CGPoint(x: 0, y: -1)
        case .down: return CGPoint(x: 0, y: 1)
        case .left: return CGPoint(x: -1, y: 0)
        case .right: return CGPoint(x: 1, y: 0)
        }
    }

    func isFacingWater() -> Bool {
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        // check both 1 and 2 tiles away (boat is summoned 2 tiles out)
        let tile1 = world.tile(at: playerTileX + dx, y: playerTileY + dy)
        let tile2 = world.tile(at: playerTileX + dx * 2, y: playerTileY + dy * 2)
        return tile1.isSwimmable && tile2.isSwimmable
    }

    func isFacingTree() -> Bool {
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        let targetX = playerTileX + dx
        let targetY = playerTileY + dy

        // trees use groundSprites (trunk is 2x2 tiles)
        for sprite in world.groundSprites {
            let spriteLeft = sprite.x
            let spriteRight = sprite.x + sprite.size - 1
            let spriteTop = sprite.y
            let spriteBottom = sprite.y + sprite.size - 1

            if targetX >= spriteLeft && targetX <= spriteRight &&
               targetY >= spriteTop && targetY <= spriteBottom {
                return true
            }
        }
        return false
    }

    func isFacingRock() -> Bool {
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        let targetX = playerTileX + dx
        let targetY = playerTileY + dy

        // rocks are 2x2 tiles anchored at top-left
        for rock in world.rockOverlays {
            let rockLeft = rock.x
            let rockRight = rock.x + 1  // 2 tiles wide
            let rockTop = rock.y
            let rockBottom = rock.y + 1  // 2 tiles tall

            if targetX >= rockLeft && targetX <= rockRight &&
               targetY >= rockTop && targetY <= rockBottom {
                return true
            }
        }
        return false
    }

    // MARK: - Fishing

    var canFish: Bool {
        player.equippedTool == .fishingRod && isFacingWater() && !player.isSwimming
    }

    func startFishing() {
        guard canFish else { return }

        gameLoopCancellable?.cancel()
        gameLoopCancellable = nil

        let fortune = inventoryViewModel.inventory.totalFishingFortune
        let vm = FishingViewModel(
            fortune: fortune,
            level: fishingState.fishingLevel,
            inventoryViewModel: inventoryViewModel,
            fishingState: fishingState
        )
        fishingViewModel = vm
        isFishing = true
    }

    func endFishing() {
        guard let vm = fishingViewModel else { return }

        // check for level up
        let previousLevel = fishingState.fishingLevel
        let newLevel = vm.fishingState.fishingLevel

        // update fishing state with new catches
        fishingState = vm.fishingState
        showingFishingResults = true

        // trigger level up notification if leveled up
        if newLevel > previousLevel {
            showFishingLevelUp(newLevel)
        }
    }

    func showFishingLevelUp(_ level: Int) {
        levelUpNotificationLevel = level
        showLevelUpNotification = true

        Task {
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                showLevelUpNotification = false
            }
        }
    }

    func dismissFishingResults() {
        showingFishingResults = false
        isFishing = false
        fishingViewModel = nil
        saveCurrentProfile()
        startGameLoop()
    }

    // MARK: - Sailing

    var canSummonSailboat: Bool {
        inventoryViewModel.inventory.majorUpgrades.hasSailboat &&
        !player.isSwimming &&
        !player.isSailing &&
        isFacingWater()
    }

    var isNearSailboat: Bool {
        guard let boat = sailboat, !player.isSailing else { return false }
        let distance = hypot(player.position.x - boat.position.x,
                             player.position.y - boat.position.y)
        return distance < tileSize * 2.0
    }

    var isNearLandWhileSailing: Bool {
        guard player.isSailing else { return false }
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        for dy in -1...1 {
            for dx in -1...1 {
                let tile = world.tile(at: playerTileX + dx, y: playerTileY + dy)
                if tile.isWalkable { return true }
            }
        }
        return false
    }

    func summonSailboat() {
        guard canSummonSailboat else { return }

        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        // place boat 2 tiles away so it doesn't get stuck in land collision
        let targetTileX = playerTileX + dx * 2
        let targetTileY = playerTileY + dy * 2

        // place boat at center of target water tile
        let boatX = CGFloat(targetTileX) * tileSize + tileSize / 2
        let boatY = CGFloat(targetTileY) * tileSize + tileSize / 2

        sailboat = Sailboat(position: CGPoint(x: boatX, y: boatY))
        saveCurrentProfile()
    }

    func boardSailboat() {
        guard let boat = sailboat, isNearSailboat else { return }

        player.sailingBoardPosition = player.position // save land position before boarding
        player.position = boat.position
        player.isSailing = true
        player.isSwimming = false
        player.swimStartPoint = nil
        saveCurrentProfile()
    }

    func disembark() {
        guard player.isSailing, isNearLandWhileSailing else { return }

        // keep sailboat at current position and rotation
        sailboat?.position = player.position
        sailboat?.rotationAngle = atan2(player.lookDirection.y, player.lookDirection.x)

        // find nearest walkable tile, prefer facing direction
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (facingDx, facingDy) = facingOffset()

        // check facing direction first
        let facingTile = world.tile(at: playerTileX + facingDx, y: playerTileY + facingDy)
        if facingTile.isWalkable {
            let landX = CGFloat(playerTileX + facingDx) * tileSize + tileSize / 2
            let landY = CGFloat(playerTileY + facingDy) * tileSize + tileSize / 2
            player.position = CGPoint(x: landX, y: landY)
            player.isSailing = false
            player.sailingBoardPosition = nil
            saveCurrentProfile()
            return
        }

        // search all adjacent tiles for walkable
        for dy in -1...1 {
            for dx in -1...1 {
                if dx == 0 && dy == 0 { continue }
                let tile = world.tile(at: playerTileX + dx, y: playerTileY + dy)
                if tile.isWalkable {
                    let landX = CGFloat(playerTileX + dx) * tileSize + tileSize / 2
                    let landY = CGFloat(playerTileY + dy) * tileSize + tileSize / 2
                    player.position = CGPoint(x: landX, y: landY)
                    player.isSailing = false
                    player.sailingBoardPosition = nil
                    saveCurrentProfile()
                    return
                }
            }
        }
    }

    // MARK: - Enemies

    private func updateSlimes(deltaTime: CGFloat) {
        for i in 0..<slimes.count {
            guard slimes[i].isAlive else { continue }

            // decrement hit flash
            if slimes[i].hitFlashTimer > 0 {
                slimes[i].hitFlashTimer = max(0, slimes[i].hitFlashTimer - deltaTime)
            }

            // decrement slow timer
            if slimes[i].slowTimer > 0 {
                slimes[i].slowTimer = max(0, slimes[i].slowTimer - deltaTime)
            }

            // decrement stun timer
            if slimes[i].isStunned {
                slimes[i].stunEndTime = max(0, slimes[i].stunEndTime - deltaTime)
                if slimes[i].stunEndTime <= 0 {
                    slimes[i].isStunned = false
                }
                continue // stunned slimes don't move or change AI state
            }

            // decrement attack cooldown
            if slimes[i].attackCooldown > 0 {
                slimes[i].attackCooldown = max(0, slimes[i].attackCooldown - deltaTime)
            }

            let distToPlayer = hypot(
                player.position.x - slimes[i].position.x,
                player.position.y - slimes[i].position.y
            )

            // state transitions
            switch slimes[i].aiState {
            case .patrol:
                if distToPlayer <= Slime.chaseRadius {
                    slimes[i].aiState = .chase
                }
            case .chase:
                if distToPlayer > Slime.chaseRadius {
                    slimes[i].aiState = .returning
                }
            case .returning:
                if distToPlayer <= Slime.chaseRadius {
                    slimes[i].aiState = .chase
                }
                let distToSpawn = hypot(
                    slimes[i].spawnOrigin.x - slimes[i].position.x,
                    slimes[i].spawnOrigin.y - slimes[i].position.y
                )
                if distToSpawn < tileSize {
                    slimes[i].aiState = .patrol(target: slimes[i].spawnOrigin)
                }
            }

            // movement
            switch slimes[i].aiState {
            case .patrol(let target):
                moveSlime(index: i, toward: target, speed: Slime.patrolSpeed, deltaTime: deltaTime)
                let distToTarget = hypot(target.x - slimes[i].position.x, target.y - slimes[i].position.y)
                if distToTarget < 4 {
                    slimes[i].patrolPauseTimer = CGFloat.random(in: 1.0...2.0)
                    slimes[i].aiState = .patrol(target: randomPatrolTarget(for: slimes[i]))
                }
                if slimes[i].patrolPauseTimer > 0 {
                    slimes[i].patrolPauseTimer -= deltaTime
                }
            case .chase:
                moveSlime(index: i, toward: player.position, speed: Slime.chaseSpeed, deltaTime: deltaTime)
            case .returning:
                moveSlime(index: i, toward: slimes[i].spawnOrigin, speed: Slime.patrolSpeed, deltaTime: deltaTime)
            }
        }
    }

    private func moveSlime(index: Int, toward target: CGPoint, speed: CGFloat, deltaTime: CGFloat) {
        // skip if pausing during patrol
        if case .patrol = slimes[index].aiState, slimes[index].patrolPauseTimer > 0 {
            return
        }

        let dx = target.x - slimes[index].position.x
        let dy = target.y - slimes[index].position.y
        let dist = hypot(dx, dy)
        guard dist > 1 else { return }

        // apply slow multiplier if slowed by tornado
        let effectiveSpeed = slimes[index].isSlowed ? speed * Slime.slowMultiplier : speed
        let moveX = (dx / dist) * effectiveSpeed * deltaTime
        let moveY = (dy / dist) * effectiveSpeed * deltaTime

        let newPos = CGPoint(x: slimes[index].position.x + moveX, y: slimes[index].position.y + moveY)
        if slimeCanMoveTo(newPos) {
            slimes[index].position = newPos
        } else {
            // slide movement
            let slideX = CGPoint(x: slimes[index].position.x + moveX, y: slimes[index].position.y)
            if slimeCanMoveTo(slideX) {
                slimes[index].position = slideX
            }
            let slideY = CGPoint(x: slimes[index].position.x, y: slimes[index].position.y + moveY)
            if slimeCanMoveTo(slideY) {
                slimes[index].position = slideY
            }
        }
    }

    private func randomPatrolTarget(for slime: Slime) -> CGPoint {
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let dist = CGFloat.random(in: 20...Slime.patrolRadius)
        let target = CGPoint(
            x: slime.spawnOrigin.x + cos(angle) * dist,
            y: slime.spawnOrigin.y + sin(angle) * dist
        )
        // validate the target is walkable
        if slimeCanMoveTo(target) { return target }
        return slime.spawnOrigin // fallback to spawn if target is invalid
    }

    private func slimeCanMoveTo(_ position: CGPoint) -> Bool {
        let half = Slime.halfSize
        let leftTile = Int(floor((position.x - half) / tileSize))
        let rightTile = Int(floor((position.x + half - 0.01) / tileSize))
        let topTile = Int(floor((position.y - half) / tileSize))
        let bottomTile = Int(floor((position.y + half - 0.01) / tileSize))

        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                let tile = world.tile(at: tileX, y: tileY)
                if !tile.isWalkable { return false }
            }
        }

        let slimeRect = CGRect(x: position.x - half, y: position.y - half, width: Slime.size, height: Slime.size)
        for rock in world.rockOverlays {
            if slimeRect.intersects(rock.collisionRect(tileSize: tileSize)) {
                return false
            }
        }
        return true
    }

    // MARK: - Combat

    private func checkSlimeContactDamage() {
        guard !player.isInvincible && !player.isSailing && !isDead else { return }

        let playerRect = CGRect(
            x: player.position.x - 12,
            y: player.position.y - 16,
            width: 24, height: 32
        )

        for i in 0..<slimes.count {
            guard slimes[i].isAlive else { continue }
            guard slimes[i].canAct else { continue } // stunned slimes can't deal damage
            guard slimes[i].attackCooldown <= 0 else { continue } // slime on cooldown
            guard playerRect.intersects(slimes[i].collisionRect) else { continue }

            // check for blocking
            if player.isBlocking {
                // check for parry (first 150ms of block)
                if isInParryWindow() {
                    triggerParry(slimeIndex: i)
                }
                // block negates damage but player still gets pushed back
                let dir = CGPoint(
                    x: player.position.x - slimes[i].position.x,
                    y: player.position.y - slimes[i].position.y
                )
                applyKnockback(position: &player.position, direction: dir, distance: Slime.knockbackDistance, halfWidth: 12, halfHeight: 16)
                return // processed this contact
            }

            // not blocking - take damage
            player.health = max(0, player.health - Slime.contactDamage)
            player.invincibilityTimer = Player.invincibilityDuration
            slimes[i].attackCooldown = Slime.attackCooldownDuration
            lastHealth = player.health

            // cancel charge if taking damage
            if player.isCharging {
                cancelCharge()
            }

            // knockback player away from slime
            let dir = CGPoint(
                x: player.position.x - slimes[i].position.x,
                y: player.position.y - slimes[i].position.y
            )
            applyKnockback(position: &player.position, direction: dir, distance: Slime.knockbackDistance, halfWidth: 12, halfHeight: 16)

            // check death
            if player.health <= 0 {
                deathPosition = player.position
                respawnLandPosition = player.position
                saveCurrentProfile()
                isDead = true
            }
            return // only process one hit per frame
        }
    }

    private func checkSwordHits() {
        guard player.isAttacking else { return }

        // charged attacks use circular AoE, normal attacks use directional hitbox
        let chargedAoeRadius: CGFloat = 40

        for i in 0..<slimes.count {
            guard slimes[i].isAlive else { continue }
            guard slimes[i].hitCooldown != player.attackSwingId else { continue }

            var isHit = false
            if player.isChargedAttack {
                // circular AoE for charged attacks
                let dx = slimes[i].position.x - player.position.x
                let dy = slimes[i].position.y - player.position.y
                let distance = sqrt(dx * dx + dy * dy)
                isHit = distance <= chargedAoeRadius + Slime.halfSize
            } else {
                // directional hitbox for normal attacks
                guard let hitbox = swordHitbox() else { continue }
                isHit = hitbox.intersects(slimes[i].collisionRect)
            }

            guard isHit else { continue }

            // deal damage (uses currentSwingDamage which may be modified by charge)
            slimes[i].health -= player.currentSwingDamage
            slimes[i].hitCooldown = player.attackSwingId
            slimes[i].hitFlashTimer = Slime.hitFlashDuration

            // knockback direction: charged = away from player, normal = facing direction
            let dir: CGPoint
            if player.isChargedAttack {
                dir = CGPoint(
                    x: slimes[i].position.x - player.position.x,
                    y: slimes[i].position.y - player.position.y
                )
            } else {
                let (dx, dy) = facingOffset()
                dir = CGPoint(x: CGFloat(dx), y: CGFloat(dy))
            }
            applyKnockback(position: &slimes[i].position, direction: dir, distance: Slime.knockbackDistance, halfWidth: Slime.halfSize, halfHeight: Slime.halfSize)

            // check slime death
            if slimes[i].health <= 0 {
                slimes[i].isAlive = false
                deathEffects.append(SlimeDeathEffect(position: slimes[i].position))
            }
        }
    }

    private func swordHitbox() -> CGRect? {
        guard player.isAttacking else { return nil }
        let reach: CGFloat = 20
        let hitboxSize: CGFloat = 28
        let half = hitboxSize / 2

        let cx: CGFloat
        let cy: CGFloat
        switch player.facingDirection {
        case .up:    cx = player.position.x; cy = player.position.y - reach
        case .down:  cx = player.position.x; cy = player.position.y + reach
        case .left:  cx = player.position.x - reach; cy = player.position.y
        case .right: cx = player.position.x + reach; cy = player.position.y
        }
        return CGRect(x: cx - half, y: cy - half, width: hitboxSize, height: hitboxSize)
    }

    private func applyKnockback(position: inout CGPoint, direction: CGPoint, distance: CGFloat, halfWidth: CGFloat, halfHeight: CGFloat) {
        let length = hypot(direction.x, direction.y)
        guard length > 0 else { return }
        let nx = direction.x / length
        let ny = direction.y / length

        // apply in steps to respect collision
        let steps = 4
        let stepDist = distance / CGFloat(steps)
        for _ in 0..<steps {
            let newPos = CGPoint(x: position.x + nx * stepDist, y: position.y + ny * stepDist)
            if canEntityMoveTo(newPos, halfWidth: halfWidth, halfHeight: halfHeight) {
                position = newPos
            } else {
                break
            }
        }
    }

    private func canEntityMoveTo(_ position: CGPoint, halfWidth: CGFloat, halfHeight: CGFloat) -> Bool {
        let leftTile = Int(floor((position.x - halfWidth) / tileSize))
        let rightTile = Int(floor((position.x + halfWidth - 0.01) / tileSize))
        let topTile = Int(floor((position.y - halfHeight) / tileSize))
        let bottomTile = Int(floor((position.y + halfHeight - 0.01) / tileSize))
        let treeOverlap: CGFloat = 20

        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                let tile = world.tile(at: tileX, y: tileY)
                if !tile.isWalkable && !tile.isSwimmable {
                    // check tree trunk depth overlap for player-sized entities
                    if halfWidth == 12 && halfHeight == 16 {
                        if let treeTrunk = treeTrunkAt(tileX: tileX, tileY: tileY) {
                            let trunkBottomY = CGFloat(treeTrunk.y + treeTrunk.size) * tileSize
                            if position.y > trunkBottomY - tileSize * 2 {
                                let trunkBottomTile = treeTrunk.y + treeTrunk.size - 1
                                if tileY == trunkBottomTile {
                                    let reducedTopTile = Int(floor((position.y - halfHeight + treeOverlap) / tileSize))
                                    if tileY < reducedTopTile {
                                        continue
                                    }
                                }
                            }
                        }
                    }
                    return false
                }
            }
        }

        let entityRect = CGRect(x: position.x - halfWidth, y: position.y - halfHeight, width: halfWidth * 2, height: halfHeight * 2)
        for rock in world.rockOverlays {
            // use depth-adjusted collision for player-sized entities
            if halfWidth == 12 && halfHeight == 16 {
                if entityRect.intersects(rock.depthCollisionRect(tileSize: tileSize, playerY: position.y)) {
                    return false
                }
            } else {
                if entityRect.intersects(rock.collisionRect(tileSize: tileSize)) {
                    return false
                }
            }
        }
        return true
    }

    private func updateDeathEffects(deltaTime: CGFloat) {
        for i in (0..<deathEffects.count).reversed() {
            deathEffects[i].elapsed += deltaTime
            if deathEffects[i].elapsed >= SlimeDeathEffect.duration {
                deathEffects.remove(at: i)
            }
        }
    }

    // MARK: - Map/Teleport

    var isOnTeleportPad: Bool {
        guard !player.isSailing, !player.isSwimming else { return false }
        return currentTeleportPad != nil
    }

    var currentTeleportPad: TeleportPad? {
        guard !player.isSailing, !player.isSwimming else { return nil }
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        return world.teleportPads.first { $0.tileX == playerTileX && $0.tileY == playerTileY }
    }

    func openMap(teleportMode: Bool) {
        isMapTeleportMode = teleportMode
        isMapOpen = true
    }

    func closeMap() {
        isMapOpen = false
        isMapTeleportMode = false
    }

    func teleportTo(pad: TeleportPad) {
        // don't teleport to current location
        if let current = currentTeleportPad, current.id == pad.id {
            closeMap()
            return
        }

        // close map immediately
        closeMap()

        // reset combat states before teleport
        resetCombatStates()

        // fade to black
        withAnimation(.easeIn(duration: 0.3)) {
            screenFadeOpacity = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(500))

            // teleport player
            player.position = pad.worldPosition
            saveCurrentProfile()

            // fade back in
            withAnimation(.easeOut(duration: 0.3)) {
                screenFadeOpacity = 0
            }
        }
    }
}
