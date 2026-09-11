import SwiftUI

struct TimezonePickerView: View {
    @Binding var selected: TimeZone
    @Environment(\.dismiss) private var dismiss

    @State private var search = ""

    private let identifiers: [String] = TimeZone.knownTimeZoneIdentifiers.sorted()

    private var filtered: [String] {
        guard !search.isEmpty else { return identifiers }
        return identifiers.filter { $0.localizedCaseInsensitiveContains(search) }
    }

    private func offsetLabel(for id: String) -> String {
        guard let tz = TimeZone(identifier: id) else { return "" }
        let seconds = tz.secondsFromGMT()
        let sign = seconds >= 0 ? "+" : "-"
        let hours = abs(seconds) / 3600
        let minutes = (abs(seconds) % 3600) / 60
        return String(format: "GMT%@%02d:%02d", sign, hours, minutes)
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    Text("No results.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(filtered, id: \.self) { id in
                        Button {
                            if let tz = TimeZone(identifier: id) {
                                selected = tz
                            }
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(id.replacingOccurrences(of: "_", with: " "))
                                        .foregroundStyle(.primary)
                                    Text(offsetLabel(for: id))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if id == selected.identifier {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Search time zones")
            .navigationTitle("Time Zone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
