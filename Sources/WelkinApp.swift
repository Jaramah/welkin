import SwiftUI

@main
struct WelkinApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Background tasks must be registered before launch finishes.
        BackgroundRefresh.register()

        // If the user opted into location-following alerts, re-arm the monitor on
        // every launch — iOS relaunches the app for a significant location change
        // and expects the manager to be watching again to receive it. App.init runs
        // on the main thread, so reaching the MainActor-isolated monitor is safe.
        if NotificationSettings.load().followLocation {
            MainActor.assumeIsolated { LocationMonitor.shared.start() }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, phase in
            // Queue the next background wake-up whenever we leave the foreground.
            if phase == .background { BackgroundRefresh.schedule() }
        }
    }
}
