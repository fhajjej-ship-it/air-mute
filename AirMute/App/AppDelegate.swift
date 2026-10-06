//
//  AppDelegate.swift
//  AirMute
//
//  Application delegate handling app lifecycle and service initialization.
//

import Cocoa
import AVFAudio
import Darwin

/// Main application delegate.
///
/// Responsibilities:
/// - Initialize and wire up all services
/// - Monitor audioaccessoryd Darwin notifications for AirPods mute events
/// - Toggle system mute when AirPods button is pressed
/// - Handle app lifecycle events
///
/// The key insight: audioaccessoryd emits Darwin notifications (com.apple.audioaccessoryd.MuteState)
/// when AirPods triggers a mute action. We listen for these native events.
/// Supports AirPods Max and AirPods Pro.
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Services

    private var audioController: AudioMuteController!
    private var audioAccessoryMonitor: AudioAccessoryMonitor!
    private var statusBarController: StatusBarController!

    // Keep reference to BluetoothManager for device detection (status display)
    private var bluetoothManager: BluetoothManager!
    private var gestureInputEngine: AVAudioEngine?
    private var inputTapInstalled = false
    private var terminationSignal: DispatchSourceSignal?

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep local diagnostics readable while the app is running.
        setvbuf(stdout, nil, _IONBF, 0)
        signal(SIGTERM, SIG_IGN)
        terminationSignal = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
        terminationSignal?.setEventHandler { NSApp.terminate(nil) }
        terminationSignal?.resume()
        print("[AppDelegate] Application launching...")
        print("[Air Mute] Microphone permission raw value: \(AVAudioApplication.shared.recordPermission.rawValue)")

        // Initialize services
        setupServices()

        // Setup audioaccessoryd notification monitoring
        setupAudioAccessoryMonitoring()
        requestGestureInputConnection()
        DispatchQueue.main.async { [weak self] in
            guard let controller = self?.audioController else { return }
            print("[Air Mute] Input: \(controller.inputDeviceName), supportsMute: \(controller.supportsMute), muted: \(controller.isMuted)")
        }

        print("[AppDelegate] Application ready")
        print("[AppDelegate] Press your AirPods button to toggle mute")
        print("[AppDelegate] Listening for audioaccessoryd mute state notifications...")
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("[AppDelegate] Application terminating...")
        audioAccessoryMonitor?.stopMonitoring()
        stopGestureInputConnection()

        // Restore mic to unmuted state if it was muted by this app
        if audioController.isMuted {
            print("[AppDelegate] Restoring microphone to unmuted state...")
            audioController.setMute(false)
        }

    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Setup

    private func requestGestureInputConnection() {
        print("[Air Mute] Requesting OS microphone permission for active gesture input; no audio saved or sent")
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("[Air Mute] Microphone permission response: \(granted)")
                guard granted else {
                    print("[Air Mute] Active gesture input blocked by microphone permission")
                    return
                }
                self.startGestureInputConnection()
            }
        }
    }

    private func startGestureInputConnection() {
        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            print("[Air Mute] Active gesture input unavailable: invalid hardware format")
            return
        }
        // Input-only graph: no connection to speakers, files, network or speech APIs.
        // Inspect no samples. A single metadata receipt proves the tap is running.
        var firstBuffer = true
        input.installTap(onBus: 0, bufferSize: 8192, format: nil) { _, _ in
            if firstBuffer {
                firstBuffer = false
                DispatchQueue.main.async {
                    print("[Air Mute] Input buffer callback active; audio contents discarded")
                }
            }
        }
        inputTapInstalled = true
        gestureInputEngine = engine
        do {
            try engine.start()
            print("[Air Mute] Active input engine started: \(engine.isRunning), sampleRate: \(format.sampleRate), channels: \(format.channelCount)")
            print("[Air Mute] Active input stays connected until Air Mute quits")
        } catch {
            print("[Air Mute] Active input engine failed: \(error)")
            stopGestureInputConnection()
            audioController.setMute(false)
        }
    }

    private func stopGestureInputConnection() {
        guard let engine = gestureInputEngine else { return }
        engine.stop()
        if inputTapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            inputTapInstalled = false
        }
        gestureInputEngine = nil
        print("[Air Mute] Active input engine stopped")
    }

    private func setupServices() {
        // Create audio controller first (no dependencies)
        audioController = AudioMuteController()

        // Create Bluetooth manager (for device status display)
        bluetoothManager = BluetoothManager()

        // Create audio accessory monitor (for AirPods crown button detection)
        audioAccessoryMonitor = AudioAccessoryMonitor()

        // Create status bar controller
        statusBarController = StatusBarController(
            audioController: audioController,
            bluetoothManager: bluetoothManager
        )

        // Check for paired AirPods (for status display)
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.checkForAirPods()
        }
    }

    private func setupAudioAccessoryMonitoring() {
        audioAccessoryMonitor.onMuteRequest = { [weak self] muted in
            guard let self = self else { return false }
            let success = self.audioController.setMute(muted)
            if success {
                DispatchQueue.main.async {
                    self.statusBarController.updateIcon()
                    self.statusBarController.showMutePopover(isMuted: muted)
                }
            }
            return success
        }
        // Legacy notifications are diagnostics only. A state-less toggle could
        // undo the public API's explicit requested state if both arrive.
        audioAccessoryMonitor.onMuteStateChanged = { _ in
            print("[Air Mute] Legacy mute notification observed")
        }

        // Debug: log all notifications
        audioAccessoryMonitor.onNotification = { notification in
            print("[AppDelegate] Audio accessory notification: \(notification)")
        }

        // Start monitoring
        let success = audioAccessoryMonitor.startMonitoring()

        if success {
            print("[AppDelegate] Audio accessory monitoring started successfully")
        } else {
            print("[AppDelegate] WARNING: Failed to start audio accessory monitoring")
        }
    }

    private func checkForAirPods() {
        let devices = bluetoothManager.pairedDevices()

        if devices.isEmpty {
            print("[AppDelegate] No paired AirPods found")
            print("[AppDelegate] Please pair your AirPods Max or AirPods Pro and try again")
        } else {
            print("[AppDelegate] Found \(devices.count) paired AirPods device(s):")
            for device in devices {
                print("  - \(device.name) (\(device.id))")
            }
        }
    }
}
