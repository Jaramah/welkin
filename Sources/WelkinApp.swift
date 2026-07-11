import SwiftUI

@main
struct WelkinApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Background tasks must be registered before launch finishes.
        BackgroundRefresh.register()
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
