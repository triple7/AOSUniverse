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


internal func getCachedFile(assetpath: [String], text: String) -> URL {
    return getAssetUrl(assetpath: assetpath).appendingPathExtension("\(text).mp3")
}


internal func fileIsInCache(assetpath: [String], text: String) -> Bool {
    let file = getCachedFile(assetpath: assetpath, text: text)
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


internal func moveFileToPath(assetpath: [String], url: URL, text: String) -> URL  {
    let destinationUrl = getAssetUrl(assetpath: assetpath).appendingPathExtension("\(text).mp3")
    do {
        try FileManager.default.moveItem(at: url, to: destinationUrl)
        // Remove the temporary url
        try FileManager.default.removeItem(at: url)
    } catch let error {
        print("moveFileToPath error: \(error.localizedDescription)")
    }
    return destinationUrl
}

func getGmtDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss z"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
}


