import SwiftUI

struct CreateLiveStreamView: View {
    let viewModel: LiveStreamListViewModel
    let onCreated: () async -> Void

    @State private var name: String = ""
    @State private var scheduleEnabled = false
    @State private var scheduledDate = Date().addingTimeInterval(3600)
    @State private var enableCountdown = false
    @State private var dvrEnabled = false
    @State private var dvrWindowSeconds = 3600
    @State private var recordVod = false
    @State private var trailerEnabled = false
    @State private var trailerVideoId = ""
    @State private var isPickingTrailer = false
    @State private var isCreating = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    private let dvrWindowOptions: [(label: String, seconds: Int)] = [
        ("30 min", 1800),
        ("1 hour", 3600),
        ("2 hours", 7200),
        ("4 hours", 14400),
        ("8 hours", 28800),
        ("12 hours", 43200),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Stream name") {
                    TextField("e.g. My Live Stream", text: $name)
                        .autocorrectionDisabled()
                }

                Section {
                    Toggle("Schedule start time", isOn: $scheduleEnabled.animation())
                    if scheduleEnabled {
                        DatePicker(
                            "Start time",
                            selection: $scheduledDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        Toggle("Show countdown in player", isOn: $enableCountdown)
                    }
                } footer: {
                    Text(scheduleEnabled
                        ? "Stream will appear as \"Upcoming\" in the dashboard."
                        : "Stream will appear as \"Created\" — start it manually via RTMP.")
                }

                Section {
                    Toggle("Pre-stream trailer", isOn: $trailerEnabled.animation())
                    if trailerEnabled {
                        Button {
                            isPickingTrailer = true
                        } label: {
                            HStack {
                                Text(trailerVideoId.isEmpty ? "Select video…" : trailerVideoId)
                                    .foregroundStyle(trailerVideoId.isEmpty ? .secondary : .primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Trailer")
                } footer: {
                    if trailerEnabled {
                        Text("A VOD from your library will loop until the stream starts.")
                    }
                }

                Section {
                    Toggle("DVR (viewers can rewind)", isOn: $dvrEnabled)
                    if dvrEnabled {
                        Picker("DVR window", selection: $dvrWindowSeconds) {
                            ForEach(dvrWindowOptions, id: \.seconds) { option in
                                Text(option.label).tag(option.seconds)
                            }
                        }
                    }
                    Toggle("Save as VOD after stream ends", isOn: $recordVod)
                } header: {
                    Text("Recording")
                } footer: {
                    if dvrEnabled {
                        Text("Viewers can rewind up to \(dvrWindowOptions.first(where: { $0.seconds == dvrWindowSeconds })?.label ?? "") during the live stream.")
                    }
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .sheet(isPresented: $isPickingTrailer) {
                TrailerPickerView(viewModel: viewModel, selectedId: $trailerVideoId)
            }
            .navigationTitle("New Live Stream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isCreating {
                        ProgressView()
                    } else {
                        Button("Create") { Task { await create() } }
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                            .bold()
                    }
                }
            }
        }
    }

    private func create() async {
        isCreating = true
        errorMessage = nil
        do {
            _ = try await viewModel.create(
                name: name.trimmingCharacters(in: .whitespaces),
                scheduledStartTime: scheduleEnabled ? scheduledDate : nil,
                enableCountdown: scheduleEnabled && enableCountdown,
                dvrEnabled: dvrEnabled,
                dvrWindowSeconds: dvrEnabled ? dvrWindowSeconds : nil,
                recordVod: recordVod,
                trailerVideoId: trailerEnabled ? trailerVideoId : nil
            )
            await onCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isCreating = false
        }
    }
}
