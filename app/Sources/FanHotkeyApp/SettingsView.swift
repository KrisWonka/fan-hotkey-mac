import SwiftUI

struct SettingsView: View {
    @Binding var config: FanHotkeyConfig
    @State private var saveStatus: SaveStatus = .idle

    enum SaveStatus { case idle, saving, saved, error(String) }

    var body: some View {
        Form {
            Section("快捷键") {
                Toggle("启用全局快捷键", isOn: $config.hotkeyEnabled)
                HStack {
                    Text("组合键")
                    HotkeyRecorder(mods: $config.hotkeyMods, key: $config.hotkeyKey)
                }
                .disabled(!config.hotkeyEnabled)
                Text("点上方按钮 → 按一下组合键即可绑定（ESC 取消）。修饰键 ⌃⌥⇧⌘ 至少要有一个。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("屏幕中央提示") {
                Toggle("启用提示", isOn: $config.alertEnabled)
                HStack {
                    Text("Auto 文字")
                        .frame(width: 100, alignment: .leading)
                    TextField("Fan: Auto", text: $config.alertAuto)
                        .textFieldStyle(.roundedBorder)
                }
                .disabled(!config.alertEnabled)
                HStack {
                    Text("全速文字")
                        .frame(width: 100, alignment: .leading)
                    TextField("Fan: Full Blast", text: $config.alertFullBlast)
                        .textFieldStyle(.roundedBorder)
                }
                .disabled(!config.alertEnabled)
                HStack {
                    Text("显示时长")
                        .frame(width: 100, alignment: .leading)
                    Slider(value: $config.alertDuration, in: 0.3...3.0, step: 0.1)
                    Text("\(String(format: "%.1f", config.alertDuration)) 秒")
                        .frame(width: 60, alignment: .trailing)
                        .font(.system(.body, design: .monospaced))
                }
                .disabled(!config.alertEnabled)
            }

            Section("自动回切") {
                Toggle("切到全速后自动回 Auto", isOn: $config.autoRevertEnabled)
                HStack {
                    Text("回切倒计时")
                        .frame(width: 100, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { Double(config.autoRevertSec) / 60.0 },
                            set: { config.autoRevertSec = Int($0 * 60) }
                        ),
                        in: 1...60, step: 1
                    )
                    Text("\(config.autoRevertSec / 60) 分钟")
                        .frame(width: 80, alignment: .trailing)
                        .font(.system(.body, design: .monospaced))
                }
                .disabled(!config.autoRevertEnabled)
                Text("适合短时高负载：跑测试 / 编译 / 烤机时切到全速，倒计时一到自动回 Auto，免得忘了。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    statusBadge
                    Button("保存并重载") { save() }
                        .keyboardShortcut("s", modifiers: .command)
                }
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch saveStatus {
        case .idle:
            EmptyView()
        case .saving:
            ProgressView().controlSize(.small)
        case .saved:
            Label("已保存", systemImage: "checkmark.circle.fill").foregroundColor(.green)
        case .error(let msg):
            Label(msg, systemImage: "exclamationmark.triangle.fill").foregroundColor(.red)
        }
    }

    private func save() {
        saveStatus = .saving
        DispatchQueue.global().async {
            do {
                try config.save()
                SystemInfo.reloadHammerspoon()
                DispatchQueue.main.async {
                    saveStatus = .saved
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if case .saved = saveStatus { saveStatus = .idle }
                    }
                }
            } catch {
                DispatchQueue.main.async { saveStatus = .error(error.localizedDescription) }
            }
        }
    }
}
