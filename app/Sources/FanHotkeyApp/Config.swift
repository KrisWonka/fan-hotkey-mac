import Foundation

enum CycleStepType: String, Codable, CaseIterable, Identifiable {
    case auto
    case fullBlast
    case cooldown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .auto:      return "Auto"
        case .fullBlast: return "Full Blast"
        case .cooldown:  return "Cooldown"
        }
    }

    var icon: String {
        switch self {
        case .auto:      return "leaf.fill"
        case .fullBlast: return "wind"
        case .cooldown:  return "snowflake"
        }
    }
}

struct CycleStep: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var type: CycleStepType
    var name: String = ""  // 空字符串 = 用 type.displayName

    // Cooldown 专属
    var cooldownTargetTemp: Double = 40
    var cooldownPollSec: Double = 3

    // Full Blast 专属
    var autoRevertEnabled: Bool = false
    var autoRevertSec: Int = 600

    var effectiveName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? type.displayName : name
    }
}

struct FanHotkeyConfig: Codable, Equatable {
    var hotkeyEnabled: Bool = true
    var hotkeyMods: [String] = ["ctrl", "alt", "cmd"]
    var hotkeyKey: String = "8"

    var alertEnabled: Bool = true
    var alertDuration: Double = 1.2
    var alertCooldownDone: String = "Cooldown done ✓"

    var cycleSteps: [CycleStep] = [
        CycleStep(type: .auto),
        CycleStep(type: .fullBlast),
        CycleStep(type: .cooldown),
    ]

    static let configPath: String = {
        NSString(string: "~/.hammerspoon/fan-hotkey-config.json").expandingTildeInPath
    }()

    static func load() -> FanHotkeyConfig {
        let url = URL(fileURLWithPath: configPath)
        guard let data = try? Data(contentsOf: url),
              let cfg = try? JSONDecoder().decode(FanHotkeyConfig.self, from: data)
        else {
            return FanHotkeyConfig()
        }
        return cfg
    }

    func save() throws {
        let url = URL(fileURLWithPath: Self.configPath)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: url, options: .atomic)
    }
}
