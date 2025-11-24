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


public func getAssetUrl(assetpath: [String], type: String? = nil) -> URL {
    var assetFolder = getDocumentsUrl()
    for asset in assetpath {
        assetFolder = assetFolder.appendingPathComponent(asset, isDirectory: true)
    }
    if let type = type {
        assetFolder = assetFolder.appendingPathComponent(type, isDirectory: true)
    }
    if !FileManager.default.fileExists(atPath: assetFolder.path) {
        print("creating asset folder")
        return createAssetFolder(folder: assetFolder)
}
    return assetFolder
}


public func getCachedFile(assetpath: [String], type: String, text: String) -> URL {
    return getAssetUrl(assetpath: assetpath, type: type).appendingPathComponent(text)
}

public func getCachedFileByType(assetType: AssetType, aosType: AOSType, fileName: String, extendedName: String? = nil) -> URL {
    var assetPath = getDocumentsUrl().appendingPathComponent(assetType.id, isDirectory: true).appendingPathComponent(aosType.id, isDirectory: true)
    if let extendedname = extendedName {
        assetPath = assetPath.appendingPathComponent(extendedname, isDirectory: true)
    }
    return Foundation.URL(fileURLWithPath: assetPath.appending(component: fileName).path())
}


func fileIsInCache(assetpath: [String], type: String, text: String) -> Bool {
    let file = getCachedFile(assetpath: assetpath, type: type, text: text)
    return FileManager.default.fileExists(atPath: file.path)
}

public func fileIsCached(assetType: AssetType, aosType: AOSType, fileName: String, extendedName: String? = nil) -> Bool {
    var assetPath = getDocumentsUrl().appendingPathComponent(assetType.id, isDirectory: true).appendingPathComponent(aosType.id, isDirectory: true)
    if let extendedName = extendedName {
        assetPath = assetPath.appendingPathComponent(extendedName, isDirectory: true)
    }
    return FileManager.default.fileExists(atPath: assetPath.appendingPathComponent(fileName).path())
}

internal func createAssetFolderByArray(path: [String]) -> URL {
    let documents = getDocumentsUrl()
    let folder = documents.appendingPathComponent(path.joined(separator: "/"), isDirectory: true)

    do {
        try FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return folder
    } catch {
        print("createAssetFolder: \(error.localizedDescription)")
        return folder   // return best-effort URL instead of crashing
    }
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
    let destinationUrl = getAssetUrl(assetpath: assetpath, type: type).appendingPathComponent(text)
    do {
        try FileManager.default.moveItem(at: url, to: destinationUrl)
        // Remove the temporary url
        try FileManager.default.removeItem(at: url)
    } catch let error {
        print("moveFileToPath error: \(error.localizedDescription)")
    }
    return destinationUrl
}


func createManifest(manifest: Manifest, url: URL) {
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
    let dataString = String(data: data!, encoding: .utf8)
    let decoder = JSONDecoder()
    let manifest = try? decoder.decode(Manifest.self, from: dataString!.data(using: .utf8)!)
    return manifest!
}


