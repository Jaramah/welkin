import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = WeatherViewModel()
    @State private var showSearch = false
    /// A Regional Nowcast area being previewed in a sheet (nil when closed).
    @State private var selectedArea: RegionalNowcast.AreaForecast?
    /// A brief message shown when a not-yet-built tab is tapped.
    @State private var toast: String?

    private var mood: SkyMood {
        viewModel.bundle?.current.code.sky ?? .clearNight
    }

    /// Credit every source whose data is currently on screen.
    private var attribution: String {
        var lines = ["Weather and air quality from Open-Meteo"]
        if viewModel.regionalNowcast != nil {
            lines.append("Nowcast from NEA, via data.gov.sg")
        }
        // Backdrops (the place photo, and the bundled weather fallbacks) come from
        // Wikimedia Commons; a fetched place photo also carries its own credit on-screen.
        lines.append("Backgrounds via Wikimedia Commons")
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ZStack {
            PlaceBackground(place: viewModel.bundle?.place ?? viewModel.currentPlace, mood: mood)
                .accessibilityHidden(true)

            // Full-screen weather that matches the location: rain, snow, storms, stars.
            if let bundle = viewModel.bundle {
                WeatherEffects(code: bundle.current.code, sky: bundle.current.code.sky)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }

            switch viewModel.phase {
            case .idle, .loading:
                LoadingView()
            case .failed(let message):
                ErrorView(message: message) {
                    Task { await reload() }
                } onSearch: {
                    showSearch = true
                }
            case .loaded(let bundle):
                loadedContent(bundle)
            }

            // Controls float over the photo: a small unit toggle, and the tab bar.
            if viewModel.bundle != nil {
                unitToggle
                VStack {
                    Spacer()
                    WelkinTabBar(active: .weather,
                                 onSelect: handleTab,
                                 onSearch: { showSearch = true })
                        .padding(.horizontal, 14)
                        .padding(.bottom, 6)
                }
            }

            if let toast {
                ToastView(text: toast)
            }
        }
        .task {
            if case .idle = viewModel.phase {
                await viewModel.loadCurrentLocation()
            }
        }
        // .task fires once per view lifetime, so on its own it never runs again after a
        // cold launch — the app would follow you only until the first time you put it
        // away. Coming back to the foreground is the moment to re-check.
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await viewModel.refreshForForeground() }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(viewModel: viewModel) { place in
                showSearch = false
                Task {
                    if place.id == "current" {
                        await viewModel.loadCurrentLocation()
                    } else {
                        await viewModel.load(place: place)
                    }
                }
            }
        }
        .sheet(item: $selectedArea) { area in
            if let place = area.place {
                AreaForecastSheet(place: place, unit: viewModel.unit, area: area,
                                  validPeriod: viewModel.regionalNowcast?.validPeriodText ?? "")
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func loadedContent(_ bundle: WeatherBundle) -> some View {
        let timezone = bundle.timezone
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // The first screen is a fixed height so the header pins to the top
                    // and the hourly strip pins to the bottom, just above the tab bar,
                    // with the photo breathing between them. The Spacer does the work —
                    // no magic offset that drifts by device. Detail cards come below.
                    VStack(spacing: 0) {
                        if let message = viewModel.refreshError {
                            RefreshErrorBanner(message: message)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)
                        }

                        HeroHeader(place: bundle.place, current: bundle.current,
                                   unit: viewModel.unit, onToggleUnit: toggleUnit)
                            .padding(.top, 14)

                        Spacer(minLength: 24)

                        if !bundle.hourly.isEmpty {
                            HourlyStrip(hours: bundle.hourly, timezone: timezone)
                                .padding(.horizontal, 14)
                        }
                    }
                    .frame(height: max(320, geo.size.height - 104))

                    VStack(spacing: 14) {
                        if !bundle.daily.isEmpty {
                            DailyForecastView(days: bundle.daily, timezone: timezone)
                        }

                        // How much three major models disagree over the next few days —
                        // best-effort, and hides itself when it can't reach them.
                        ModelCompareView(place: bundle.place, unit: viewModel.unit)

                        if let nowcast = viewModel.regionalNowcast, !nowcast.areas.isEmpty {
                            // Opens the area in a sheet — it must not replace the
                            // location the main screen is showing.
                            RegionalNowcastView(nowcast: nowcast) { area in
                                selectedArea = area
                            }
                        }

                        if let aqi = bundle.aqiNow {
                            AirQualityView(aqi: aqi, pm25: bundle.pm25, pm10: bundle.pm10,
                                           ozone: bundle.ozone, no2: bundle.no2)
                        }

                        DetailGridView(current: bundle.current, unit: viewModel.unit,
                                       timezone: timezone)

                        // Attribution is a licence condition, not a courtesy: Singapore's
                        // Open Data Licence requires data.gov.sg/NEA to be credited
                        // wherever their data appears, and App Review checks data terms.
                        Text(attribution)
                            .font(Theme.label(11))
                            .foregroundStyle(Color.welkinTertiary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 22)
                    .padding(.bottom, 120)      // clear the floating tab bar
                }
            }
            .refreshable { await reload() }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    /// Small unit toggle, top-right, clear of the hero.
    private var unitToggle: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: toggleUnit) {
                    Text(viewModel.unit.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().fill(Color.black.opacity(0.42)))
                        )
                        .overlay(Circle().stroke(.white.opacity(0.14), lineWidth: 0.5))
                }
                .accessibilityLabel("Temperature unit")
                .accessibilityValue(viewModel.unit == .celsius ? "Celsius" : "Fahrenheit")
                .accessibilityHint("Double tap to switch units")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Spacer()
        }
    }

    private func toggleUnit() {
        withAnimation(.snappy) {
            viewModel.unit = viewModel.unit == .fahrenheit ? .celsius : .fahrenheit
        }
    }

    private func handleTab(_ tab: WelkinTab) {
        switch tab {
        case .weather:
            break   // already here
        case .rain:
            showToast("Rain view is coming soon")
        case .photos:
            showToast("Photos are coming soon")
        }
    }

    private func showToast(_ text: String) {
        withAnimation(.easeOut(duration: 0.2)) { toast = text }
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.3)) { toast = nil }
        }
    }

    /// When the shown place came from GPS, a refresh has to ask CoreLocation again —
    /// re-fetching the old coordinates would keep reporting the neighbourhood you
    /// were standing in when the app first launched. A searched city stays put.
    private func reload() async {
        if let place = viewModel.currentPlace, !viewModel.isFollowingLocation {
            await viewModel.load(place: place)
        } else {
            await viewModel.loadCurrentLocation()
        }
    }
}

/// A brief, non-blocking message above the tab bar — used for tabs that aren't built yet.
private struct ToastView: View {
    let text: String
    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().fill(Color.black.opacity(0.5)))
                )
                .overlay(Capsule().stroke(.white.opacity(0.14), lineWidth: 0.5))
                .padding(.bottom, 96)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().controlSize(.large).tint(.white)
            Text("Reading the skies…")
                .font(Theme.body(15))
                .foregroundStyle(Color.welkinSecondary)
        }
    }
}

private struct ErrorView: View {
    let message: String
    let retry: () -> Void
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "cloud.rain.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.welkinSecondary)
            Text(message)
                .font(Theme.body(16))
                .foregroundStyle(Color.welkinPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: retry) {
                Text("Try Again")
                    .font(Theme.body(16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .glassSurface(cornerRadius: 24)
            }
            // Always offer a way forward — e.g. when location is denied, retrying
            // just fails again, so let the user pick a city instead.
            Button(action: onSearch) {
                Text("Search for a city")
                    .font(Theme.body(15))
                    .foregroundStyle(Color.welkinSecondary)
            }
        }
    }
}

/// Shown when a refresh fails but a good forecast is already on screen. The data
/// below is still valid, just not fresh — so this warns without hiding it.
private struct RefreshErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(Theme.body(13))
                .foregroundStyle(Color.welkinSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassSurface(cornerRadius: 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Couldn't refresh. \(message)")
    }
}
