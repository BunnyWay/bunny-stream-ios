**STRUCT**

# `Schemas.StorageObjectModel`

```swift
public struct StorageObjectModel: Codable, Hashable, Sendable
```

Represents a storage object containing file details for a video.

- Remark: Generated from `#/components/schemas/StorageObjectModel`.

## Properties
### `guid`

```swift
public var guid: Swift.String?
```

The unique identifier of the storage object.

- Remark: Generated from `#/components/schemas/StorageObjectModel/guid`.

### `storageZoneName`

```swift
public var storageZoneName: Swift.String?
```

The name of the storage zone where the file is kept.

- Remark: Generated from `#/components/schemas/StorageObjectModel/storageZoneName`.

### `path`

```swift
public var path: Swift.String?
```

The file path of the storage object.

- Remark: Generated from `#/components/schemas/StorageObjectModel/path`.

### `objectName`

```swift
public var objectName: Swift.String?
```

The name of the object in storage.

- Remark: Generated from `#/components/schemas/StorageObjectModel/objectName`.

### `length`

```swift
public var length: Swift.Int64?
```

The length of the file in bytes.

- Remark: Generated from `#/components/schemas/StorageObjectModel/length`.

### `lastChanged`

```swift
public var lastChanged: Foundation.Date?
```

The date and time when the file was last modified.

- Remark: Generated from `#/components/schemas/StorageObjectModel/lastChanged`.

### `serverId`

```swift
public var serverId: Swift.Int32?
```

The identifier of the server storing the file.

- Remark: Generated from `#/components/schemas/StorageObjectModel/serverId`.

### `isDirectory`

```swift
public var isDirectory: Swift.Bool?
```

Indicates if the storage object is a directory.

- Remark: Generated from `#/components/schemas/StorageObjectModel/isDirectory`.

### `userId`

```swift
public var userId: Swift.String?
```

The user ID associated with the storage object.

- Remark: Generated from `#/components/schemas/StorageObjectModel/userId`.

### `contentType`

```swift
public var contentType: Swift.String?
```

The MIME type of the file.

- Remark: Generated from `#/components/schemas/StorageObjectModel/contentType`.

### `dateCreated`

```swift
public var dateCreated: Foundation.Date?
```

The date and time when the file was created.

- Remark: Generated from `#/components/schemas/StorageObjectModel/dateCreated`.

### `storageZoneId`

```swift
public var storageZoneId: Swift.Int64?
```

The identifier of the storage zone.

- Remark: Generated from `#/components/schemas/StorageObjectModel/storageZoneId`.

### `checksum`

```swift
public var checksum: Swift.String?
```

A checksum value for file integrity verification.

- Remark: Generated from `#/components/schemas/StorageObjectModel/checksum`.

### `replicatedZones`

```swift
public var replicatedZones: Swift.String?
```

A list of storage zones where the file is replicated.

- Remark: Generated from `#/components/schemas/StorageObjectModel/replicatedZones`.

## Methods
### `init(guid:storageZoneName:path:objectName:length:lastChanged:serverId:isDirectory:userId:contentType:dateCreated:storageZoneId:checksum:replicatedZones:)`

```swift
public init(
    guid: Swift.String? = nil,
    storageZoneName: Swift.String? = nil,
    path: Swift.String? = nil,
    objectName: Swift.String? = nil,
    length: Swift.Int64? = nil,
    lastChanged: Foundation.Date? = nil,
    serverId: Swift.Int32? = nil,
    isDirectory: Swift.Bool? = nil,
    userId: Swift.String? = nil,
    contentType: Swift.String? = nil,
    dateCreated: Foundation.Date? = nil,
    storageZoneId: Swift.Int64? = nil,
    checksum: Swift.String? = nil,
    replicatedZones: Swift.String? = nil
)
```

Creates a new `StorageObjectModel`.

- Parameters:
  - guid: The unique identifier of the storage object.
  - storageZoneName: The name of the storage zone where the file is kept.
  - path: The file path of the storage object.
  - objectName: The name of the object in storage.
  - length: The length of the file in bytes.
  - lastChanged: The date and time when the file was last modified.
  - serverId: The identifier of the server storing the file.
  - isDirectory: Indicates if the storage object is a directory.
  - userId: The user ID associated with the storage object.
  - contentType: The MIME type of the file.
  - dateCreated: The date and time when the file was created.
  - storageZoneId: The identifier of the storage zone.
  - checksum: A checksum value for file integrity verification.
  - replicatedZones: A list of storage zones where the file is replicated.

#### Parameters

| Name | Description |
| ---- | ----------- |
| guid | The unique identifier of the storage object. |
| storageZoneName | The name of the storage zone where the file is kept. |
| path | The file path of the storage object. |
| objectName | The name of the object in storage. |
| length | The length of the file in bytes. |
| lastChanged | The date and time when the file was last modified. |
| serverId | The identifier of the server storing the file. |
| isDirectory | Indicates if the storage object is a directory. |
| userId | The user ID associated with the storage object. |
| contentType | The MIME type of the file. |
| dateCreated | The date and time when the file was created. |
| storageZoneId | The identifier of the storage zone. |
| checksum | A checksum value for file integrity verification. |
| replicatedZones | A list of storage zones where the file is replicated. |

### `init(from:)`

```swift
public init(from decoder: any Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |