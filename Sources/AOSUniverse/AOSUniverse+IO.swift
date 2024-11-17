//
//  AOSUniverse+IO.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 10/11/2024.
//

import Foundation

// Mark: IO with remote server

internal func getDocumentsUrl()->URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }


internal func getAssetUrl(assetpath: [String], type: String) -> URL {
    var assetFolder = getDocumentsUrl()
    for asset in assetpath {
        assetFolder = assetFolder.appendingPathComponent(asset, isDirectory: true)
    }
    assetFolder = assetFolder.appendingPathComponent(type, isDirectory: true)
    if !FileManager.default.fileExists(atPath: assetFolder.path) {
        return createAssetFolder(folder: assetFolder)
}
    return assetFolder
}


internal func getCachedFile(assetpath: [String], type: String, text: String) -> URL {
    return getAssetUrl(assetpath: assetpath, type: type).appendingPathComponent(text)
}


internal func fileIsInCache(assetpath: [String], type: String, text: String) -> Bool {
    let file = getCachedFile(assetpath: assetpath, type: type, text: text)
    return FileManager.default.fileExists(atPath: file.path)
}


internal func createAssetFolder(folder: URL) -> URL {
    do {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    } catch let error {
        print("createAssetFolder: \(error.localizedDescription)")
        return folder
    }
}


internal func moveFileToPath(assetpath: [String], type: String, url: URL, text: String) -> URL  {
    let destinationUrl = getAssetUrl(assetpath: assetpath, type: type).appendingPathComponent("\(text)_\(type)_low.mp3")
    do {
        try FileManager.default.moveItem(at: url, to: destinationUrl)
        // Remove the temporary url
        try FileManager.default.removeItem(at: url)
    } catch let error {
        print("moveFileToPath error: \(error.localizedDescription)")
    }
    return destinationUrl
}

public func getGmtDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
}


public func getLastModifiedDate(dateString: String) -> Date? {
    print("get last modified date: \(dateString)")
    let dateFormatter = getGmtDateFormatter()
    let test = dateFormatter.date(from: dateString)
    print(test)
    return dateFormatter.date(from: dateString)!
}


public func getLastModifiedDate(for filePath: String) -> Date? {
    let fileManager = FileManager.default

    do {
        let attributes = try fileManager.attributesOfItem(atPath: filePath)
        if let modificationDate = attributes[.modificationDate] as? Date {
            return modificationDate
        }
    } catch {
        print("Error retrieving file attributes: \(error.localizedDescription)")
    }

    return nil
}


func setLastModifiedDate(for fileURL: URL, to date: Date) {
    let fileManager = FileManager.default
    
    do {
        // Create a dictionary with the modification date attribute
        let attributes: [FileAttributeKey: Any] = [.modificationDate: date]
        
        // Set the attributes for the specified file
        try fileManager.setAttributes(attributes, ofItemAtPath: fileURL.path)
        
    } catch {
        print("Error setting last modified date: \(error.localizedDescription)")
    }
}

func createManifest(manifest: Manifest, url: URL) {
    print(url.path())
    do {
    let encoder = JSONEncoder()
    let jsonData = try encoder.encode(manifest)
    try jsonData.write(to: url, options: .atomic)
} catch let error {
    print("createManifest: \(error.localizedDescription)")
}
}


func getManifest(assetpath: [String], type: String)-> Manifest {
    let url = getAssetUrl(assetpath: assetpath, type: type).appendingPathComponent("manifest.json")
    if !FileManager.default.fileExists(atPath: url.path()) {
        let newManifest = Manifest(manifest: [ManifestEntry]())
        createManifest(manifest: newManifest, url: url)
    }
                             let data = try? Data(contentsOf: url)
    let decoder = JSONDecoder()
    let manifest = try? decoder.decode(Manifest.self, from: data!)
    return manifest!
}

