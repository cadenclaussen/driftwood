import SwiftUI

enum Theme {

    // MARK: - Colors (Warm/Earthy — island driftwood palette)
    enum Color {
        // base tones
        private static let cream = SwiftUI.Color(red: 0.96, green: 0.91, blue: 0.82)
        private static let tan = SwiftUI.Color(red: 0.72, green: 0.63, blue: 0.50)
        private static let bark = SwiftUI.Color(red: 0.18, green: 0.12, blue: 0.07)
        private static let olive = SwiftUI.Color(red: 0.47, green: 0.58, blue: 0.30)
        private static let rust = SwiftUI.Color(red: 0.78, green: 0.30, blue: 0.18)
        private static let teal = SwiftUI.Color(red: 0.25, green: 0.52, blue: 0.48)
        private static let amber = SwiftUI.Color(red: 0.88, green: 0.68, blue: 0.22)
        private static let burnt = SwiftUI.Color(red: 0.82, green: 0.50, blue: 0.18)

        // text
        static let textPrimary = cream
        static let textSecondary = tan
        static let textDisabled = tan.opacity(0.5)

        // overlays/backgrounds
        static let overlayDark = bark.opacity(0.92)
        static let overlayMedium = bark.opacity(0.88)
        static let overlayDimmed = bark.opacity(0.78)
        static let overlayHalf = bark.opacity(0.55)
        static let overlaySubtle = bark.opacity(0.45)
        static let panelBackground = SwiftUI.Color(red: 0.14, green: 0.10, blue: 0.06).opacity(0.96)
        static let panelBackgroundLight = SwiftUI.Color(red: 0.20, green: 0.14, blue: 0.08).opacity(0.93)

        // gameplay
        static let health = rust
        static let stamina = olive
        static let magic = amber
        static let magicCyan = SwiftUI.Color(red: 0.82, green: 0.62, blue: 0.15)
        static let positive = olive
        static let negative = rust
        static let sprint = burnt
        static let teleport = SwiftUI.Color(red: 0.70, green: 0.48, blue: 0.22)
        static let selection = amber
        static let equipped = teal
        static let inventory = SwiftUI.Color(red: 0.55, green: 0.38, blue: 0.22)
        static let craftable = olive
        static let uncraftable = rust
        static let fishing = teal
        static let food = burnt
        static let favorite = amber
        static let junk = rust

        // slot backgrounds
        static let emptySlot = SwiftUI.Color(red: 0.38, green: 0.30, blue: 0.22).opacity(0.35)
        static let filledSlot = SwiftUI.Color(red: 0.42, green: 0.33, blue: 0.24).opacity(0.45)
        static let equippedSlot = teal.opacity(0.2)
        static let equippedSlotLight = teal.opacity(0.3)
        static let ownedToolSlot = burnt.opacity(0.3)
        static let unownedSlot = SwiftUI.Color(red: 0.38, green: 0.30, blue: 0.22).opacity(0.2)

        // borders
        static let borderDark = SwiftUI.Color(red: 0.12, green: 0.08, blue: 0.04).opacity(0.45)
        static let borderDarkSubtle = SwiftUI.Color(red: 0.12, green: 0.08, blue: 0.04).opacity(0.3)
        static let borderLight = cream.opacity(0.25)
        static let borderFaint = cream.opacity(0.15)
        static let borderMedium = tan.opacity(0.45)

        // button backgrounds
        static let buttonPositive = olive.opacity(0.85)
        static let buttonNegative = rust.opacity(0.75)
        static let buttonNeutral = SwiftUI.Color(red: 0.48, green: 0.40, blue: 0.32).opacity(0.65)
        static let buttonInactive = SwiftUI.Color(red: 0.52, green: 0.44, blue: 0.36).opacity(0.7)
        static let buttonMenu = SwiftUI.Color(red: 0.52, green: 0.44, blue: 0.36).opacity(0.8)
        static let buttonInventory = SwiftUI.Color(red: 0.55, green: 0.38, blue: 0.22).opacity(0.8)
        static let buttonBlue = teal.opacity(0.8)
        static let tabSelected = teal.opacity(0.5)

        // stat colors
        static let statHealth = rust
        static let statDefense = teal
        static let statFortune = SwiftUI.Color(red: 0.35, green: 0.60, blue: 0.55)
        static let statSpeed = olive
        static let statMagic = SwiftUI.Color(red: 0.62, green: 0.38, blue: 0.52)

        // rarity
        static func rarity(_ rarity: ItemRarity) -> SwiftUI.Color {
            switch rarity {
            case .common: return tan
            case .uncommon: return olive
            case .rare: return teal
            case .epic: return SwiftUI.Color(red: 0.65, green: 0.32, blue: 0.48)
            }
        }

        // resource icon colors
        static func resourceIcon(_ type: ResourceType) -> SwiftUI.Color {
            switch type {
            case .wood: return SwiftUI.Color(red: 0.60, green: 0.42, blue: 0.25)
            case .stone, .metalScrap, .platinumScraps, .brokenWheel, .wire, .plastic, .wheel: return tan
            case .leatherScrap, .sharkTooth, .scale, .string, .cotton, .sail: return cream
            case .oil: return SwiftUI.Color(red: 0.15, green: 0.12, blue: 0.10)
            case .commonFish, .rareFish, .messageInBottle: return teal
            case .rainbowFish, .theOldOne: return SwiftUI.Color(red: 0.65, green: 0.32, blue: 0.48)
            case .seaweed, .plantFiber: return olive
            case .overgrownCoin, .timeLocket: return amber
            case .moonFragment: return SwiftUI.Color(red: 0.40, green: 0.55, blue: 0.62)
            case .sunFragment: return burnt
            case .sailorsJournal: return SwiftUI.Color(red: 0.60, green: 0.42, blue: 0.25)
            }
        }
    }

    // MARK: - Fonts (serif titles, rounded UI)
    enum Font {
        static let titleHuge = SwiftUI.Font.system(size: 42, weight: .bold, design: .serif)
        static let titleLarge = SwiftUI.Font.system(size: 36, weight: .bold, design: .serif)
        static let title = SwiftUI.Font.system(size: 28, weight: .bold, design: .serif)
        static let titleSemibold = SwiftUI.Font.system(size: 28, weight: .semibold, design: .serif)

        static let heading = SwiftUI.Font.system(size: 24, weight: .semibold, design: .rounded)
        static let headingLight = SwiftUI.Font.system(size: 22, weight: .regular, design: .rounded)
        static let subheading = SwiftUI.Font.system(size: 20, weight: .semibold, design: .rounded)

        static let bodyLargeSemibold = SwiftUI.Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = SwiftUI.Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodySemibold = SwiftUI.Font.system(size: 16, weight: .semibold, design: .rounded)
        static let bodyBold = SwiftUI.Font.system(size: 16, weight: .bold, design: .rounded)
        static let bodyMid = SwiftUI.Font.system(size: 15, weight: .regular, design: .rounded)

        static let bodySmall = SwiftUI.Font.system(size: 14, weight: .regular, design: .rounded)
        static let bodySmallSemibold = SwiftUI.Font.system(size: 14, weight: .semibold, design: .rounded)
        static let bodySmallBold = SwiftUI.Font.system(size: 14, weight: .bold, design: .rounded)
        static let bodySmallMedium = SwiftUI.Font.system(size: 14, weight: .medium, design: .rounded)

        static let caption = SwiftUI.Font.system(size: 12, weight: .regular, design: .rounded)
        static let captionMedium = SwiftUI.Font.system(size: 12, weight: .medium, design: .rounded)
        static let captionBold = SwiftUI.Font.system(size: 12, weight: .bold, design: .rounded)
        static let captionSemibold = SwiftUI.Font.system(size: 12, weight: .semibold, design: .rounded)

        static let label = SwiftUI.Font.system(size: 11, weight: .regular, design: .rounded)
        static let labelBold = SwiftUI.Font.system(size: 11, weight: .bold, design: .rounded)

        static let micro = SwiftUI.Font.system(size: 10, weight: .regular, design: .rounded)
        static let microBold = SwiftUI.Font.system(size: 10, weight: .bold, design: .rounded)
        static let microMedium = SwiftUI.Font.system(size: 10, weight: .medium, design: .rounded)
        static let microSemibold = SwiftUI.Font.system(size: 10, weight: .semibold, design: .rounded)

        static let nano = SwiftUI.Font.system(size: 9, weight: .regular, design: .rounded)
        static let nanoMedium = SwiftUI.Font.system(size: 9, weight: .medium, design: .rounded)

        static let pico = SwiftUI.Font.system(size: 8, weight: .regular, design: .rounded)

        static let picoTiny = SwiftUI.Font.system(size: 7, weight: .regular, design: .rounded)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxxxs: CGFloat = 1
        static let xxxs: CGFloat = 2
        static let xxxsm: CGFloat = 3
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let smd: CGFloat = 10
        static let md: CGFloat = 12
        static let mdl: CGFloat = 15
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 30
        static let huge: CGFloat = 32
        static let massive: CGFloat = 40
        static let colossal: CGFloat = 60
    }

    // MARK: - Corner Radius
    enum Radius {
        static let small: CGFloat = 4
        static let slot: CGFloat = 6
        static let button: CGFloat = 8
        static let medium: CGFloat = 10
        static let panel: CGFloat = 12
        static let large: CGFloat = 16
    }

    // MARK: - Border Widths
    enum Border {
        static let thin: CGFloat = 1
        static let standard: CGFloat = 2
        static let thick: CGFloat = 3
    }

    // MARK: - Sizes
    enum Size {
        static let circleButton: CGFloat = 60
        static let actionButton: CGFloat = 44
        static let inventorySlot: CGFloat = 44
        static let equipmentSlot: CGFloat = 50
        static let barWidth: CGFloat = 100
        static let barHeight: CGFloat = 12
        static let miniMap: CGFloat = 80
        static let fullMap: CGFloat = 300
        static let joystickBase: CGFloat = 120
        static let joystickThumb: CGFloat = 50
        static let windArrow: CGFloat = 44

        // view-specific sizes
        static let slotImage: CGFloat = 40
        static let inventoryButtonIcon: CGFloat = 64
        static let dialogButtonWidth: CGFloat = 120
        static let dialogButtonHeight: CGFloat = 44
        static let deathButtonWidth: CGFloat = 200
        static let deathButtonHeight: CGFloat = 50
        static let menuButtonWidth: CGFloat = 180
        static let menuButtonHeight: CGFloat = 60
        static let recipePanelWidth: CGFloat = 220
        static let recipePanelHeight: CGFloat = 280
        static let itemPanelMaxWidth: CGFloat = 280
        static let detailPanelMaxWidth: CGFloat = 220
        static let resultsMaxWidth: CGFloat = 300
        static let waypointMarkerWidth: CGFloat = 60
        static let waypointMarkerHeight: CGFloat = 50
        static let mapPlayerDot: CGFloat = 10
        static let mapMiniDot: CGFloat = 6
        static let inventoryPanelWidth: CGFloat = 500
        static let inventoryPanelHeight: CGFloat = 370
        static let collectiblesSectionWidth: CGFloat = 240
        static let craftingSectionWidth: CGFloat = 150
        static let hudRightBuffer: CGFloat = 36
        static let windArrowTopOffset: CGFloat = 50
        static let notificationTopOffset: CGFloat = 80

        // icon sizes
        static let iconHuge: CGFloat = 32
        static let iconLarge: CGFloat = 28
        static let iconMedium: CGFloat = 24
        static let iconMedSm: CGFloat = 22
        static let iconSmall: CGFloat = 20
        static let iconMini: CGFloat = 18
        static let iconTiny: CGFloat = 16
        static let iconMicro: CGFloat = 14
        static let iconNano: CGFloat = 12
        static let iconPico: CGFloat = 10
    }

    // MARK: - Animation
    enum Anim {
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.1)
        static let longPressDuration: Double = 0.3
    }

    // MARK: - Opacity
    enum Opacity {
        static let full: CGFloat = 1.0
        static let overlay: CGFloat = 0.85
        static let overlayMedium: CGFloat = 0.8
        static let overlayDimmed: CGFloat = 0.7
        static let button: CGFloat = 0.6
        static let half: CGFloat = 0.5
        static let slot: CGFloat = 0.4
        static let subtle: CGFloat = 0.3
        static let faint: CGFloat = 0.2
    }
}
