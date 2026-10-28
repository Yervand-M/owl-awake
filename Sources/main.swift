import AppKit
import ServiceManagement

// Owl Awake — menu bar toggle for `pmset disablesleep`.
// disablesleep is a system-wide power setting: it keeps the Mac fully running
// with the lid closed (no external display needed) and stays in effect even
// after this app quits, until it is switched off again.

private let pmset = "/usr/bin/pmset"
private let sudoersPath = "/etc/sudoers.d/owl-awake"

@discardableResult
private func run(_ path: String, _ args: [String]) -> (status: Int32, output: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: path)
    task.arguments = args
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    do { try task.run() } catch { return (-1, error.localizedDescription) }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()
    return (task.terminationStatus, String(data: data, encoding: .utf8) ?? "")
}

private func isSleepDisabled() -> Bool {
    let out = run(pmset, ["-g"]).output
    for line in out.split(separator: "\n") where line.contains("SleepDisabled") {
        return line.split(whereSeparator: { $0 == " " || $0 == "\t" }).last == "1"
    }
    return false
}

/// Runs `sudo -n pmset -a disablesleep <0|1>`; works only once the sudoers rule is installed.
private func setSleepDisabled(_ on: Bool) -> Bool {
    run("/usr/bin/sudo", ["-n", pmset, "-a", "disablesleep", on ? "1" : "0"]).status == 0
}

/// One-time setup: lets the current user run exactly these two pmset commands without a password.
/// macOS shows its own admin password dialog.
private func installPermission() -> Bool {
    let user = NSUserName()
    let rule = "\(user) ALL=(root) NOPASSWD: \(pmset) -a disablesleep 0, \(pmset) -a disablesleep 1\n"
    let tmp = NSTemporaryDirectory() + "owl-awake.sudoers"
    do { try rule.write(toFile: tmp, atomically: true, encoding: .utf8) } catch { return false }
    let cmd = "/usr/sbin/visudo -cf '\(tmp)' && /usr/bin/install -m 0440 -o root -g wheel '\(tmp)' \(sudoersPath)"
    return runAsAdmin(cmd)
}

private func removePermission() -> Bool {
    runAsAdmin("\(pmset) -a disablesleep 0; /bin/rm -f \(sudoersPath)")
}

private func runAsAdmin(_ cmd: String) -> Bool {
    let escaped = cmd.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
    var error: NSDictionary?
    NSAppleScript(source: "do shell script \"\(escaped)\" with administrator privileges")?.executeAndReturnError(&error)
    return error == nil
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var awake = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(clicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        refresh()
        // Pick up changes made outside the app (e.g. pmset in Terminal).
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in self?.refresh() }
    }

    private func refresh() {
        awake = isSleepDisabled()
        statusItem.button?.image = OwlShape.menuBarImage(awake: awake)
        statusItem.button?.toolTip = awake
            ? "Owl Awake: ON — Mac stays awake, even with the lid closed"
            : "Owl Awake: OFF — normal sleep"
    }

    @objc private func clicked() {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showMenu()
        } else {
            toggle()
        }
    }

    @objc private func toggle() {
        let target = !awake
        if !setSleepDisabled(target) {
            guard installPermission(), setSleepDisabled(target) else {
                refresh()
                return
            }
        }
        refresh()
    }

    private func showMenu() {
        let menu = NSMenu()
        let state = NSMenuItem(title: awake ? "Awake — lid can be closed" : "Sleeping normally", action: nil, keyEquivalent: "")
        state.isEnabled = false
        menu.addItem(state)
        menu.addItem(withTitle: awake ? "Turn Off" : "Turn On", action: #selector(toggle), keyEquivalent: "").target = self
        menu.addItem(.separator())

        let login = NSMenuItem(title: "Open at Login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)
        menu.addItem(withTitle: "Remove Permission…", action: #selector(uninstall), keyEquivalent: "").target = self
        menu.addItem(.separator())

        let note = NSMenuItem(title: "Quitting keeps the current state", action: nil, keyEquivalent: "")
        note.isEnabled = false
        menu.addItem(note)
        menu.addItem(withTitle: "Quit Owl Awake", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil   // keep left-click as a one-click toggle
    }

    @objc private func toggleLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled { try service.unregister() } else { try service.register() }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn't change Open at Login"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    @objc private func uninstall() {
        _ = removePermission()
        refresh()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
