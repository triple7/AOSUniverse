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


internal func getAssetUrl(assetpath: [String]) -> URL {
    var assetFolder = getDocumentsUrl()
    for asset in assetpath {
        assetFolder = assetFolder.appendingPathComponent(asset, isDirectory: true)
    }
    if !FileManager.default.fileExists(atPath: assetFolder.path) {
        print("creating asset folder: \(assetFolder.path())")
        return createAssetFolder(folder: assetFolder)
}
    return assetFolder
}


internal func getCachedFile(assetpath: [String], type: String, text: String) -> URL {
    return getAssetUrl(assetpath: assetpath).appendingPathComponent("\(text)_\(type)_low.mp3")
}


internal func fileIsInCache(assetpath: [String], type: String, text: String) -> Bool {
    let file = getCachedFile(assetpath: assetpath, type: type, text: text)
    print("cache: \(file.path())")
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
    let destinationUrl = getAssetUrl(assetpath: assetpath + [type]).appendingPathComponent("\(text)_\(type)_low.mp3")
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
    dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss z"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
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
        
        print("Successfully updated last modified date.")
    } catch {
        print("Error setting last modified date: \(error.localizedDescription)")
    }
}


