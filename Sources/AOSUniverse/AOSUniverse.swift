/*
import Foundation
import Zip

/** AOS Universe domain media download service
 */

import SceneKit

public final class AOSUniverse:ObservableObject {
    private let baseUrl = "https://universe.astreos.space"

@Published var payload:Payload?
    internal var downloads:[URL: Download] = [:]
    internal lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
    }()
static let shared = AOSUniverse()

    private init() {
        /** Initializer
         Checks for all object relative directories are created
         the first time it's run
         */
        
        for assetType in AssetType.allCases {
            for object in AOSType.allCases {
                if directoryExists(object.directoryUrl(assetType)) {
                    try! FileManager.default.createDirectory(at: object.directoryUrl(assetType), withIntermediateDirectories: true, attributes: nil)
                }
            }
        }
    }

    func process(_ event: Download.Event, for asset: Asset) {
        switch event {
            case let .progress(current, total):
                payload?[asset.id]?.update(currentBytes: current, totalBytes: total)
            case let .success(url):
                saveFile(for: asset, at: url)
        }
    }

    func saveFile(for asset: Asset, at url: URL) {
            try? FileManager.default.moveItem(at: url, to: asset.fileURL)
    }

    private func unpackModel(at url: URL) {
        do{
            let unzipDirectory = try Zip.quickUnzipFile(url)
            let folder = try FileManager.default.contentsOfDirectory(atPath: unzipDirectory.path)
            var scene:SCNScene
            if folder.count == 3{
                let texture = Foundation.URL(fileURLWithPath: unzipDirectory.appendingPathComponent(folder[0], isDirectory: false).path)
                let mtl = Foundation.URL(fileURLWithPath: unzipDirectory.appendingPathComponent(folder[1], isDirectory: false).path)
                let obj = Foundation.URL(fileURLWithPath: unzipDirectory.appendingPathComponent(folder[2], isDirectory: false).path)
                scene = try SCNScene(url: obj, options: [SCNSceneSource.LoadingOption.assetDirectoryURLs: [mtl, texture]])
            }else if folder.count == 2{
                let mtl = Foundation.URL(fileURLWithPath: unzipDirectory.appendingPathComponent(folder[0], isDirectory: false).path)
                let obj = Foundation.URL(fileURLWithPath: unzipDirectory.appendingPathComponent(folder[1], isDirectory: false).path)
                scene = try SCNScene(url: obj, options: [SCNSceneSource.LoadingOption.assetDirectoryURLs: [mtl]])
            }else{
                let url = Foundation.URL(fileURLWithPath: unzipDirectory.appendingPathComponent(folder[0], isDirectory: false).path)
                scene = try SCNScene(url: url, options: nil)
            }
            clearTempDirectory(unzipDirectory, folder)
        }catch let error{
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func clearTempDirectory(_ url: URL, _ folder: [String]){
        for f in folder{
            do{
                try FileManager.default.removeItem(atPath: url.appendingPathComponent(f, isDirectory: false).path)
            }catch let error{
                assertionFailure(error.localizedDescription)
            }
        }
    }

    internal func directoryExists( _ url: URL)->Bool {
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }
    
internal func getAssetUrl( _ fileName: String, _ assetType: AssetType, _ type: AOSType)->URL {
    return URL(string: baseUrl)!.appendingPathExtension(assetType.id).appendingPathExtension(type.id).appendingPathComponent(fileName)
    }
    
}

*/
