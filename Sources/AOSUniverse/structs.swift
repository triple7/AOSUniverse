//
//  File.swift
//  
//
//  Created by Yuma decaux on 13/4/2023.
//

import Foundation

/** AOS Universe syslog
 Used for logging all user interactions in:
 * states
 * AOS universe network API calls
 expliration of celestial objects
 
 */

public struct AOSSysLog:CustomStringConvertible {
    let timecode:String
    let log:AOSLog
    let message:String
    
    public init( log: AOSLog, message: String) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.timecode = dateFormatter.string(from: date)
        self.log = log
                  self.message = message
    }
    
    public var description:String {
        return "\(log): \(message)"
    }
}

public typealias Payload = AOSPayload

public struct AOSPayload {
public let id: Int
    let assetType:AssetType
    var assets:[AOSAsset]
 var isDownloading: Bool = false
private(set) var currentBytes: Int64 = 0
private(set) var totalBytes: Int64 = 0

    var progress: Double {
        guard totalBytes > 0 else { return 0.0 }
        return Double(currentBytes) / Double(totalBytes)
    }

    public mutating func update(currentBytes: Int64, totalBytes: Int64) {
        self.currentBytes = currentBytes
        self.totalBytes = totalBytes
    }

    public mutating func removeAsset( at index: Int) {
        self.assets.remove(at: index)
    }
    
    subscript(assetId: AOSAsset.ID) -> AOSAsset? {
        get {
            assets.first { $0.id == assetId }
        }
        set {
            guard let newValue,
                  let index = assets.firstIndex(where: { $0.id == assetId })
            else { return }
            assets[index] = newValue
        }
    }
 
}

extension AOSPayload {
    
        var directoryURL: URL {
            var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            documentsPath.appendPathComponent(assetType.id)
            return documentsPath
        }
    
    }
    
public struct AOSAsset:Identifiable {
    public let id:String
    let assetType:AssetType
    let url:URL
    var isDownloading: Bool = false
   private(set) var currentBytes: Int64 = 0
   private(set) var totalBytes: Int64 = 0

       var progress: Double {
           guard totalBytes > 0 else { return 0.0 }
           return Double(currentBytes) / Double(totalBytes)
       }

       public mutating func update(currentBytes: Int64, totalBytes: Int64) {
           self.currentBytes = currentBytes
           self.totalBytes = totalBytes
       }

}

extension AOSAsset {
    
    var fileURL: URL {
        var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsPath.appendPathComponent(assetType.id)
        documentsPath.appendPathComponent(id)
        documentsPath.appendPathExtension(assetType.media)
        return documentsPath
    }
    
    func fileExists()->Bool {
        return FileManager.default.fileExists(atPath: self.fileURL.path)
    }

    func getLastModified()->Date {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            return attr[FileAttributeKey.modificationDate] as! Date
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        return Date()
}
    
}

public struct FilterCombinations:Codable {
    public let InfraredCombination:[String]
    public let UltravioletCombination:[String]
    public let VisibleLightCombination:[String]
    public let BroadbandandNarrowbandCombination:[String]
    public let GrismandPrismCombination:[String]
    public let DetectionandClearFilters:[String]
    public let CombinedWavelengths:[String]
    public let SpecializedFilters:[String]
    
}


public struct Manifest:Codable {
    let manifest:[ManifestEntry]
}

public struct ManifestEntry:Codable {
    let name:String
    let lastModified:String
}

