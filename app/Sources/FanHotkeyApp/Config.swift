import Foundation

struct FanHotkeyConfig: Codable, Equatable {
    var hotkeyEnabled: Bool = true
    var hotkeyMods: [String] = ["ctrl", "alt", "cmd"]
    var hotkeyKey: String = "8"

    var alertEnabled: Bool = true
    var alertAuto: String = "Fan: Auto"
    var alertFullBlast: String = "Fan: Full Blast"
    var alertDuration: Double = 1.2

    var autoRevertEnabled: Bool = false
    var autoRevertSec: Int = 600

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
