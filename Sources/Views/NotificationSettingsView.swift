import SwiftUI
import UserNotifications

/// Weather-alert toggles, reached from the menu.
struct NotificationSettingsView: View {
    @State private var settings = NotificationSettings.load()
    @State private var authorized = false
    @State private var askedOnce = false

    private let hours = Array(0...23)

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.06, green: 0.08, blue: 0.18),
                                    Color(red: 0.10, green: 0.06, blue: 0.20)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            List {
                if !authorized {
                    Section {
                        Button {
                            Task {
                                authorized = await NotificationService.shared.requestAuthorization()
                                askedOnce = true
                            }
                        } label: {
                            Label("Turn on notifications", systemImage: "bell.badge")
                                .font(Theme.body(16))
                                .foregroundStyle(Color.welkinPrimary)
                        }
                        .listRowBackground(Color.white.opacity(0.06))
                    } footer: {
                        Text(askedOnce
                             ? "Notifications are off. Enable them for Welkin in iOS Settings."
                             : "Welkin needs permission before it can alert you.")
                            .font(Theme.body(12))
                            .foregroundStyle(Color.welkinTertiary)
                    }
                }

                Section {
                    toggle("Rain alerts", "cloud.rain.fill", $settings.rainAlerts)
                    toggle("Haze / air quality", "aqi.medium", $settings.hazeAlerts)
                    toggle("Thunderstorm warnings", "cloud.bolt.fill", $settings.severeAlerts)
                } header: {
                    Text("ALERTS").font(Theme.label(11)).foregroundStyle(Color.welkinTertiary)
                } footer: {
                    Text("Checked when Welkin refreshes and when iOS wakes it in the background. iOS schedules those wake-ups at its own discretion, so these are best-effort — they can arrive late.")
                        .font(Theme.body(12))
                        .foregroundStyle(Color.welkinTertiary)
                }

                if settings.nearTermAlertsEnabled {
                    Section {
                        toggle("Follow my location", "location.fill", $settings.followLocation)
                    } header: {
                        Text("LOCATION").font(Theme.label(11)).foregroundStyle(Color.welkinTertiary)
                    } footer: {
                        Text("Lets the alerts above follow you between areas — so you get Bedok's rain when you're in Bedok, even if you haven't opened Welkin. Needs \u{201C}Always\u{201D} location access, and uses the low-power location radio.")
                            .font(Theme.body(12))
                            .foregroundStyle(Color.welkinTertiary)
                    }
                }

                Section {
                    toggle("Daily briefing", "sun.horizon.fill", $settings.dailyBriefing)

                    if settings.dailyBriefing {
                        Picker(selection: $settings.briefingHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text(label(for: hour)).tag(hour)
                            }
                        } label: {
                            Text("Time")
                                .font(Theme.body(16))
                                .foregroundStyle(Color.welkinPrimary)
                        }
                        .tint(Color.welkinSecondary)
                        .listRowBackground(Color.white.opacity(0.06))
                    }
                } header: {
                    Text("MORNING").font(Theme.label(11)).foregroundStyle(Color.welkinTertiary)
                } footer: {
                    Text("A summary of the day, delivered at a fixed time. This one is scheduled ahead, so it arrives reliably.")
                        .font(Theme.body(12))
                        .foregroundStyle(Color.welkinTertiary)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { authorized = await NotificationService.shared.isAuthorized() }
        .onChange(of: settings) { _, new in
            new.save()
            // Follow only while it's on AND there's a near-term alert to follow;
            // turning off the last alert should also stop the location watch.
            if new.followLocation, new.nearTermAlertsEnabled {
                LocationMonitor.shared.start()
            } else {
                LocationMonitor.shared.stop()
            }
        }
    }

    private func toggle(_ title: String, _ icon: String, _ value: Binding<Bool>) -> some View {
        Toggle(isOn: value) {
            Label(title, systemImage: icon)
                .font(Theme.body(16))
                .foregroundStyle(Color.welkinPrimary)
        }
        .tint(Color(red: 0.35, green: 0.75, blue: 1.0))
        .listRowBackground(Color.white.opacity(0.06))
    }

    private func label(for hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let date = Calendar.current.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("j")
        return formatter.string(from: date)
    }
}
