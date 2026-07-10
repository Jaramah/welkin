import SwiftUI

struct SearchView: View {
    let viewModel: WeatherViewModel
    var onSelect: (Place) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var results: [Place] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.06, green: 0.08, blue: 0.18),
                                        Color(red: 0.10, green: 0.06, blue: 0.20)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                List {
                    Button {
                        onSelect(currentLocationPlaceholder)
                    } label: {
                        Label("Use Current Location", systemImage: "location.fill")
                            .font(Theme.body(16))
                            .foregroundStyle(Color.welkinPrimary)
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    if isSearching {
                        HStack { Spacer(); ProgressView().tint(.white); Spacer() }
                            .listRowBackground(Color.clear)
                    }

                    if !isSearching && results.isEmpty
                        && query.trimmingCharacters(in: .whitespaces).count >= 2 {
                        Text("No matching cities. Check the spelling or your connection.")
                            .font(Theme.body(14))
                            .foregroundStyle(Color.welkinSecondary)
                            .listRowBackground(Color.clear)
                    }

                    ForEach(results) { place in
                        Button {
                            onSelect(place)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name)
                                    .font(Theme.body(16))
                                    .foregroundStyle(Color.welkinPrimary)
                                if !place.subtitle.isEmpty {
                                    Text(place.subtitle)
                                        .font(Theme.body(13))
                                        .foregroundStyle(Color.welkinSecondary)
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.06))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $query, prompt: "Search cities")
            .onChange(of: query) { _, newValue in
                searchTask?.cancel()
                guard newValue.trimmingCharacters(in: .whitespaces).count >= 2 else {
                    results = []
                    isSearching = false
                    return
                }
                isSearching = true
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    guard !Task.isCancelled else { return }
                    let found = await viewModel.search(newValue)
                    guard !Task.isCancelled else { return }
                    results = found
                    isSearching = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.tint(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // Sentinel: id "current" tells ContentView to use CoreLocation.
    private var currentLocationPlaceholder: Place {
        Place(id: "current", name: "Current Location", latitude: 0, longitude: 0)
    }
}
