import SwiftUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var showSearch = false
    @State private var scrollY: CGFloat = 0

    private var mood: SkyMood {
        viewModel.bundle?.current.code.sky ?? .clearNight
    }

    var body: some View {
        ZStack {
            AnimatedBackground(mood: mood)

            switch viewModel.phase {
            case .idle, .loading:
                LoadingView()
            case .failed(let message):
                ErrorView(message: message) {
                    Task { await reload() }
                }
            case .loaded(let bundle):
                loadedContent(bundle)
            }

            topBar
        }
        .task {
            if case .idle = viewModel.phase {
                await viewModel.loadCurrentLocation()
            }
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
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func loadedContent(_ bundle: WeatherBundle) -> some View {
        let timezone = bundle.timezone
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                CurrentWeatherView(place: bundle.place, current: bundle.current,
                                   unit: viewModel.unit, scrollOffset: scrollY)
                    .padding(.top, 70)
                    .padding(.bottom, 8)

                if !bundle.hourly.isEmpty {
                    HourlyForecastView(hours: bundle.hourly, timezone: timezone)
                }

                if !bundle.daily.isEmpty {
                    DailyForecastView(days: bundle.daily, timezone: timezone)
                }

                if let aqi = bundle.aqiNow {
                    AirQualityView(aqi: aqi, pm25: bundle.pm25, pm10: bundle.pm10,
                                   ozone: bundle.ozone, no2: bundle.no2)
                }

                DetailGridView(current: bundle.current, unit: viewModel.unit, timezone: timezone)

                Text("Data from Open-Meteo")
                    .font(Theme.label(11))
                    .foregroundStyle(Color.auroraTertiary)
                    .padding(.top, 4)
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, Theme.pad)
        }
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y
        } action: { _, newValue in
            scrollY = newValue
        }
        .refreshable { await reload() }
    }

    private var topBar: some View {
        VStack {
            HStack {
                Button { showSearch = true } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassSurface(cornerRadius: 20)
                }

                Spacer()

                Button {
                    withAnimation(.snappy) {
                        viewModel.unit = viewModel.unit == .fahrenheit ? .celsius : .fahrenheit
                    }
                } label: {
                    Text(viewModel.unit.symbol)
                        .font(Theme.title(16))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassSurface(cornerRadius: 20)
                }
            }
            .padding(.horizontal, Theme.pad)
            Spacer()
        }
    }

    private func reload() async {
        if let place = viewModel.currentPlace {
            await viewModel.load(place: place)
        } else {
            await viewModel.loadCurrentLocation()
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().controlSize(.large).tint(.white)
            Text("Reading the skies…")
                .font(Theme.body(15))
                .foregroundStyle(Color.auroraSecondary)
        }
    }
}

private struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "cloud.rain.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.auroraSecondary)
            Text(message)
                .font(Theme.body(16))
                .foregroundStyle(Color.auroraPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: retry) {
                Text("Try Again")
                    .font(Theme.body(16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .glassSurface(cornerRadius: 24)
            }
        }
    }
}
