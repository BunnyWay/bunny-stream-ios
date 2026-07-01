import BunnyStreamAPI
import SwiftUI

struct CreateLiveStreamView: View {
    let viewModel: LiveStreamListViewModel
    /// When set, the form edits this existing stream (PUT) instead of creating a new one.
    let editingStream: Components.Schemas.LiveStreamModel?
    let onCreated: () async -> Void

    @State private var name: String = ""
    @State private var streamDescription: String = ""
    @State private var scheduleEnabled = false
    @State private var scheduledDate = Date().addingTimeInterval(3600)
    @State private var scheduledTimeZone: TimeZone = .current
    @State private var isPickingTimeZone = false
    @State private var enableCountdown = false
    @State private var dvrEnabled = false
    @State private var dvrWindowSeconds = 3600
    @State private var recordVod = false
    @State private var isPublic = true
    @State private var trailerEnabled = false
    @State private var trailerVideoId = ""
    @State private var isPickingTrailer = false
    @State private var thumbnailEnabled = false
    @State private var thumbnailUrl = ""
    @State private var isCreating = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool { editingStream != nil }

    init(
        viewModel: LiveStreamListViewModel,
        editingStream: Components.Schemas.LiveStreamModel? = nil,
        onCreated: @escaping () async -> Void
    ) {
        self.viewModel = viewModel
        self.editingStream = editingStream
        self.onCreated = onCreated

        guard let stream = editingStream else { return }
        _name = State(initialValue: stream.title ?? stream.name ?? "")
        _streamDescription = State(initialValue: stream.description ?? "")
        if let scheduled = stream.scheduledStartTime,
           let date = CreateLiveStreamView.parseDate(scheduled) {
            _scheduleEnabled = State(initialValue: true)
            _scheduledDate = State(initialValue: date)
        }
        _enableCountdown = State(initialValue: stream.enableCountdown ?? false)
        _dvrEnabled = State(initialValue: stream.dvrEnabled ?? false)
        if let window = stream.dvrWindowSeconds {
            _dvrWindowSeconds = State(initialValue: Int(window))
        }
        _recordVod = State(initialValue: stream.recordVod ?? false)
        _isPublic = State(initialValue: stream._public ?? true)
        if let trailerId = stream.preStreamTrailerVideoId, !trailerId.isEmpty {
            _trailerEnabled = State(initialValue: true)
            _trailerVideoId = State(initialValue: trailerId)
        }
    }

    /// Parses Bunny's ISO 8601 timestamps (with or without fractional seconds).
    private static func parseDate(_ value: String) -> Date? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFraction.date(from: value) { return date }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: value)
    }

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

                Section("Description") {
                    TextField("Optional description", text: $streamDescription, axis: .vertical)
                        .lineLimit(2...4)
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
                        Button {
                            isPickingTimeZone = true
                        } label: {
                            HStack {
                                Text("Time zone")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(scheduledTimeZone.identifier.replacingOccurrences(of: "_", with: " "))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Toggle("Show countdown in player", isOn: $enableCountdown)
                    }
                } footer: {
                    Text(scheduleEnabled
                        ? "Stream will start at \(scheduledStartDescription). It will appear as \"Upcoming\" in the dashboard."
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

                if !isEditing {
                  Section {
                    Toggle("Offline thumbnail", isOn: $thumbnailEnabled.animation())
                    if thumbnailEnabled {
                        TextField("https://example.com/thumb.jpg", text: $thumbnailUrl)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                        if let url = URL(string: thumbnailUrl.trimmingCharacters(in: .whitespaces)),
                           !thumbnailUrl.trimmingCharacters(in: .whitespaces).isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(16 / 9, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                case .failure:
                                    Label("Couldn't load image", systemImage: "photo")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                  } header: {
                    Text("Thumbnail")
                  } footer: {
                    if thumbnailEnabled {
                        Text("Shown in the player while the stream is offline. Bunny's live API sets the thumbnail by URL.")
                    }
                  }
                }

                if isEditing {
                    Section("Visibility") {
                        Toggle("Public", isOn: $isPublic)
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
            .sheet(isPresented: $isPickingTimeZone) {
                TimezonePickerView(selected: $scheduledTimeZone)
            }
            .navigationTitle(isEditing ? "Edit Live Stream" : "New Live Stream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isCreating {
                        ProgressView()
                    } else {
                        Button(isEditing ? "Save" : "Create") { Task { await save() } }
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                            .bold()
                    }
                }
            }
        }
    }

    /// Reinterprets the wall-clock value the user picked (displayed in the device time zone)
    /// as belonging to the selected time zone, yielding the correct absolute instant.
    private var resolvedScheduledStartTime: Date {
        var deviceCalendar = Calendar(identifier: .gregorian)
        deviceCalendar.timeZone = .current
        let comps = deviceCalendar.dateComponents(
            [.year, .month, .day, .hour, .minute], from: scheduledDate
        )
        var targetCalendar = Calendar(identifier: .gregorian)
        targetCalendar.timeZone = scheduledTimeZone
        return targetCalendar.date(from: comps) ?? scheduledDate
    }

    private var scheduledStartDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = scheduledTimeZone
        return formatter.string(from: resolvedScheduledStartTime)
    }

    private func save() async {
        isCreating = true
        errorMessage = nil
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedDescription = streamDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            if let editingStream {
                _ = try await viewModel.update(
                    stream: editingStream,
                    name: trimmedName,
                    description: trimmedDescription,
                    scheduledStartTime: scheduleEnabled ? resolvedScheduledStartTime : nil,
                    enableCountdown: scheduleEnabled && enableCountdown,
                    dvrEnabled: dvrEnabled,
                    dvrWindowSeconds: dvrEnabled ? dvrWindowSeconds : nil,
                    recordVod: recordVod,
                    trailerVideoId: trailerEnabled ? trailerVideoId : nil,
                    isPublic: isPublic
                )
            } else {
                _ = try await viewModel.create(
                    name: trimmedName,
                    description: trimmedDescription,
                    scheduledStartTime: scheduleEnabled ? resolvedScheduledStartTime : nil,
                    enableCountdown: scheduleEnabled && enableCountdown,
                    dvrEnabled: dvrEnabled,
                    dvrWindowSeconds: dvrEnabled ? dvrWindowSeconds : nil,
                    recordVod: recordVod,
                    trailerVideoId: trailerEnabled ? trailerVideoId : nil,
                    thumbnailUrl: thumbnailEnabled ? thumbnailUrl.trimmingCharacters(in: .whitespaces) : nil
                )
            }
            await onCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isCreating = false
        }
    }
}
