import BunnyStreamAPI
import BunnyStreamPlayer
import PhotosUI
import SwiftUI
import UIKit

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
    @State private var thumbnailImageData: Data?
    @State private var thumbnailPickerItem: PhotosPickerItem?
    @State private var existingThumbnailURL: URL?
    @State private var isCreating = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool { editingStream != nil }

    /// Scheduling only applies to streams that haven't started or ended yet.
    private var canSchedule: Bool {
        guard let stream = editingStream else { return true }
        guard case .LiveStreamStatus(let status)? = stream.status else { return true }
        return status == .created || status == .scheduled
    }

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

    /// Downscales an image to a reasonable thumbnail size and re-encodes it as JPEG so uploads
    /// stay well under Bunny's ~5 MB thumbnail limit.
    private static func downscaledJPEG(from data: Data, maxDimension: CGFloat = 1920, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxDimension ? maxDimension / longest : 1
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }

    /// Parses Bunny's timestamps. Handles ISO 8601 with a timezone AND the timezone-less form
    /// Bunny returns for scheduledStartTime (e.g. "2026-07-01T08:20:00"). The naive form is
    /// interpreted in the device time zone so the DatePicker shows the same wall-clock value.
    private static func parseDate(_ value: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: value) { return date }
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: value) { return date }
        for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSSS", "yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss"] {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = .current
            df.dateFormat = format
            if let date = df.date(from: value) { return date }
        }
        return nil
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

                if canSchedule {
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
                    Toggle("Offline thumbnail", isOn: $thumbnailEnabled.animation())
                    if thumbnailEnabled {
                        PhotosPicker(selection: $thumbnailPickerItem, matching: .images) {
                            Label(
                                thumbnailImageData == nil ? "Choose from Photos" : "Change photo",
                                systemImage: "photo"
                            )
                        }
                        TextField("…or paste an image URL", text: $thumbnailUrl)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                        thumbnailPreview
                    }
                } header: {
                    Text("Thumbnail")
                } footer: {
                    if thumbnailEnabled {
                        Text("Shown in the player before the stream starts or if it encounters issues.")
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
            .onChange(of: thumbnailPickerItem) { item in
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                    // Downscale + JPEG-encode: keeps the upload well under Bunny's ~5 MB thumbnail
                    // limit (full-res iPhone photos exceed it) and normalizes HEIC to JPEG.
                    if let jpeg = Self.downscaledJPEG(from: data) {
                        thumbnailImageData = jpeg
                        thumbnailEnabled = true
                    } else {
                        viewModel.actionError = "Couldn't read the selected image."
                    }
                }
            }
            .task {
                guard isEditing, let stream = editingStream else { return }
                if let url = viewModel.offlineThumbnailURL(for: stream) {
                    existingThumbnailURL = url
                    thumbnailEnabled = true
                }
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

    @ViewBuilder
    private var thumbnailPreview: some View {
        if let data = thumbnailImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else if let url = previewURL {
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

    /// The image URL to preview: a typed URL takes precedence, otherwise the stream's current thumbnail.
    private var previewURL: URL? {
        let trimmed = thumbnailUrl.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { return URL(string: trimmed) }
        return existingThumbnailURL
    }

    private func save() async {
        isCreating = true
        errorMessage = nil
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedDescription = streamDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let streamId: String
            if let editingStream {
                _ = try await viewModel.update(
                    stream: editingStream,
                    name: trimmedName,
                    description: trimmedDescription,
                    scheduledStartTime: (canSchedule && scheduleEnabled) ? resolvedScheduledStartTime : nil,
                    enableCountdown: canSchedule && scheduleEnabled && enableCountdown,
                    dvrEnabled: dvrEnabled,
                    dvrWindowSeconds: dvrEnabled ? dvrWindowSeconds : nil,
                    recordVod: recordVod,
                    trailerVideoId: trailerEnabled ? trailerVideoId : nil,
                    isPublic: isPublic
                )
                streamId = editingStream.guid ?? ""
            } else {
                let created = try await viewModel.create(
                    name: trimmedName,
                    description: trimmedDescription,
                    scheduledStartTime: (canSchedule && scheduleEnabled) ? resolvedScheduledStartTime : nil,
                    enableCountdown: canSchedule && scheduleEnabled && enableCountdown,
                    dvrEnabled: dvrEnabled,
                    dvrWindowSeconds: dvrEnabled ? dvrWindowSeconds : nil,
                    recordVod: recordVod,
                    trailerVideoId: trailerEnabled ? trailerVideoId : nil
                )
                streamId = created.guid ?? ""
            }
            // Thumbnail is set via a separate endpoint (needs the stream id) — best-effort so it
            // doesn't block or duplicate the save if it fails.
            if !streamId.isEmpty {
                await applyThumbnail(streamId: streamId)
            }
            await onCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isCreating = false
        }
    }

    private func applyThumbnail(streamId: String) async {
        do {
            if thumbnailEnabled {
                if let data = thumbnailImageData {
                    try await viewModel.setThumbnail(streamId: streamId, jpegData: data)
                } else {
                    let trimmed = thumbnailUrl.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        try await viewModel.setThumbnail(streamId: streamId, url: trimmed)
                    }
                }
            } else if isEditing, existingThumbnailURL != nil {
                // Thumbnail was turned off while editing — remove it.
                try await viewModel.deleteThumbnail(streamId: streamId)
            }
        } catch {
            viewModel.actionError = "Stream saved, but the thumbnail couldn't be updated: \(error.localizedDescription)"
        }
    }
}
