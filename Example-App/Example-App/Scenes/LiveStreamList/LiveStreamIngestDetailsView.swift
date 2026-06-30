import BunnyStreamAPI
import SwiftUI

/// Shows the RTMP ingest details a user needs to configure an external encoder
/// (stream key + primary ingest URL) for a given live stream.
struct LiveStreamIngestDetailsView: View {
    let stream: Components.Schemas.LiveStreamModel
    @Environment(\.dismiss) private var dismiss

    private var primaryUrl: String? {
        stream.ingestEndpoints?.rtmp?.primaryIngestUrl
    }

    private var backupUrl: String? {
        stream.ingestEndpoints?.rtmp?.backupIngestUrl
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Stream key") {
                    if let key = stream.streamKey, !key.isEmpty {
                        copyableRow(label: "Key", value: key)
                    } else {
                        Text("Not available for this stream.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Primary ingest URL") {
                    if let url = primaryUrl, !url.isEmpty {
                        copyableRow(label: "RTMP URL", value: url)
                    } else {
                        Text("Not provided by the API for this stream.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Backup ingest URL") {
                    if let url = backupUrl, !url.isEmpty {
                        copyableRow(label: "RTMP URL", value: url)
                    } else {
                        Text("Not provided by the API for this stream.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("RTMP Ingest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func copyableRow(label: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
            Spacer()
            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
        }
    }
}
