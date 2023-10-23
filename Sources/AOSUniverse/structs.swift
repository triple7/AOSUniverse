//
//  File.swift
//  
//
//  Created by Yuma decaux on 13/4/2023.
//

import Foundation

public typealias Payload = AOSPayload

public struct AOSPayload {
public let id: Int
    let assetType:AssetType
    var assets:[Asset]
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
    
    subscript(assetId: Asset.ID) -> Asset? {
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
    
public struct Asset:Identifiable {
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

extension Asset {
    
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
    

