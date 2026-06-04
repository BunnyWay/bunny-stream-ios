import SwiftUI

struct CreateLiveStreamView: View {
    let viewModel: LiveStreamListViewModel
    let onCreated: () async -> Void

    @State private var name: String = ""
    @State private var scheduleEnabled = false
    @State private var scheduledDate = Date().addingTimeInterval(3600)
    @State private var isCreating = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Stream name") {
                    TextField("e.g. My Live Stream", text: $name)
                        .autocorrectionDisabled()
                }

                Section {
                    Toggle("Schedule start time", isOn: $scheduleEnabled)
                    if scheduleEnabled {
                        DatePicker(
                            "Start time",
                            selection: $scheduledDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                } footer: {
                    Text(scheduleEnabled
                        ? "Stream will appear as \"Upcoming\" in the dashboard."
                        : "Stream will appear as \"Created\" — start it manually via RTMP.")
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
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
                scheduledStartTime: scheduleEnabled ? scheduledDate : nil
            )
            await onCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isCreating = false
        }
    }
}
