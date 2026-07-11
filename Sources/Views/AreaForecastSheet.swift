import SwiftUI

/// A Regional Nowcast area opened in its own sheet, so tapping one never
/// replaces the location the main screen is showing.
struct AreaForecastSheet: View {
    let place: Place
    let unit: TemperatureUnit

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .loading

    enum Phase {
        case loading
        case loaded(WeatherBundle)
        case failed(String)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground(mood: mood)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                switch phase {
                case .loading:
                    ProgressView().controlSize(.large).tint(.white)

                case .failed(let message):
                    VStack(spacing: 14) {
                        Image(systemName: "cloud.rain.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.welkinSecondary)
                        Text(message)
                            .font(Theme.body(15))
                            .foregroundStyle(Color.welkinPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                case .loaded(let bundle):
                    content(bundle)
                }
            }
            .navigationTitle(place.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.tint(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { await load() }
    }

    private var mood: SkyMood {
        if case .loaded(let bundle) = phase { return bundle.current.code.sky }
        return .clearNight
    }

    @ViewBuilder
    private func content(_ bundle: WeatherBundle) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                CurrentWeatherView(place: bundle.place, current: bundle.current,
                                   unit: unit, scrollOffset: 0)
                    .padding(.top, 4)

                if !bundle.hourly.isEmpty {
                    HourlyForecastView(hours: bundle.hourly, timezone: bundle.timezone)
                }
                if !bundle.daily.isEmpty {
                    DailyForecastView(days: bundle.daily, timezone: bundle.timezone)
                }
                if let aqi = bundle.aqiNow {
                    AirQualityView(aqi: aqi, pm25: bundle.pm25, pm10: bundle.pm10,
                                   ozone: bundle.ozone, no2: bundle.no2)
                }
                DetailGridView(current: bundle.current, unit: unit, timezone: bundle.timezone)
            }
            .padding(.horizontal, Theme.pad)
            .padding(.bottom, 30)
        }
    }

    private func load() async {
        do {
            phase = .loaded(try await WeatherService().fetch(for: place, unit: unit))
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
