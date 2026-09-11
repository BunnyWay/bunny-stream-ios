import Foundation

/// The fields to create a live stream with. Only `title` is required.
public struct BunnyLiveStreamCreateRequest: Equatable, Sendable {
  public var title: String
  public var description: String?
  public var collectionId: String?
  /// When set, the stream starts out as ``BunnyLiveStreamStatus/scheduled``.
  public var scheduledStartTime: Date?
  public var scheduledEndTime: Date?
  public var isPublic: Bool?
  /// Lets viewers rewind. Requires ``dvrWindowSeconds``.
  public var dvrEnabled: Bool?
  /// How far back viewers can rewind, in seconds. Maximum 43200 (12 hours).
  public var dvrWindowSeconds: Int?
  /// Produce a VOD recording once the stream ends.
  public var recordVod: Bool?
  /// Show a countdown before the scheduled start. Only applies with ``scheduledStartTime`` set.
  public var enableCountdown: Bool?
  /// GUID of a VOD video to loop as a trailer before the stream starts.
  public var preStreamTrailerVideoId: String?
  /// Up to 4 RTMP endpoints the incoming stream is forwarded to.
  public var rtmpOutputs: [BunnyRtmpOutput]?

  public init(
    title: String,
    description: String? = nil,
    collectionId: String? = nil,
    scheduledStartTime: Date? = nil,
    scheduledEndTime: Date? = nil,
    isPublic: Bool? = nil,
    dvrEnabled: Bool? = nil,
    dvrWindowSeconds: Int? = nil,
    recordVod: Bool? = nil,
    enableCountdown: Bool? = nil,
    preStreamTrailerVideoId: String? = nil,
    rtmpOutputs: [BunnyRtmpOutput]? = nil
  ) {
    self.title = title
    self.description = description
    self.collectionId = collectionId
    self.scheduledStartTime = scheduledStartTime
    self.scheduledEndTime = scheduledEndTime
    self.isPublic = isPublic
    self.dvrEnabled = dvrEnabled
    self.dvrWindowSeconds = dvrWindowSeconds
    self.recordVod = recordVod
    self.enableCountdown = enableCountdown
    self.preStreamTrailerVideoId = preStreamTrailerVideoId
    self.rtmpOutputs = rtmpOutputs
  }

  var apiModel: Components.Schemas.CreateLiveStreamModel {
    Components.Schemas.CreateLiveStreamModel(
      title: title,
      description: description,
      collectionId: collectionId,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledEndTime,
      _public: isPublic,
      dvrEnabled: dvrEnabled,
      dvrWindowSeconds: dvrWindowSeconds.map(Int32.init),
      recordVod: recordVod,
      enableCountdown: enableCountdown,
      preStreamTrailerVideoId: preStreamTrailerVideoId,
      rtmpOutputs: rtmpOutputs?.map {
        Components.Schemas.RtmpOutput(endpoint: $0.endpoint, streamKey: $0.streamKey)
      }
    )
  }
}

/// The fields to change on an existing live stream.
///
/// Every field is optional and only the ones you set are sent — the API leaves the rest
/// untouched. Note that this means you can't clear a value by assigning `nil`.
public struct BunnyLiveStreamUpdateRequest: Equatable, Sendable {
  public var title: String?
  public var description: String?
  public var collectionId: String?
  public var scheduledStartTime: Date?
  public var scheduledEndTime: Date?
  public var isPublic: Bool?
  public var dvrEnabled: Bool?
  public var dvrWindowSeconds: Int?
  public var recordVod: Bool?
  public var enableCountdown: Bool?
  public var preStreamTrailerVideoId: String?
  public var rtmpOutputs: [BunnyRtmpOutput]?

  public init(
    title: String? = nil,
    description: String? = nil,
    collectionId: String? = nil,
    scheduledStartTime: Date? = nil,
    scheduledEndTime: Date? = nil,
    isPublic: Bool? = nil,
    dvrEnabled: Bool? = nil,
    dvrWindowSeconds: Int? = nil,
    recordVod: Bool? = nil,
    enableCountdown: Bool? = nil,
    preStreamTrailerVideoId: String? = nil,
    rtmpOutputs: [BunnyRtmpOutput]? = nil
  ) {
    self.title = title
    self.description = description
    self.collectionId = collectionId
    self.scheduledStartTime = scheduledStartTime
    self.scheduledEndTime = scheduledEndTime
    self.isPublic = isPublic
    self.dvrEnabled = dvrEnabled
    self.dvrWindowSeconds = dvrWindowSeconds
    self.recordVod = recordVod
    self.enableCountdown = enableCountdown
    self.preStreamTrailerVideoId = preStreamTrailerVideoId
    self.rtmpOutputs = rtmpOutputs
  }

  var apiModel: Components.Schemas.UpdateLiveStreamModel {
    Components.Schemas.UpdateLiveStreamModel(
      title: title,
      description: description,
      collectionId: collectionId,
      dvrEnabled: dvrEnabled,
      dvrWindowSeconds: dvrWindowSeconds.map(Int32.init),
      recordVod: recordVod,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledEndTime,
      _public: isPublic,
      enableCountdown: enableCountdown,
      preStreamTrailerVideoId: preStreamTrailerVideoId,
      rtmpOutputs: rtmpOutputs?.map {
        Components.Schemas.RtmpOutput(endpoint: $0.endpoint, streamKey: $0.streamKey)
      }
    )
  }
}
