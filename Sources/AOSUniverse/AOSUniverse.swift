import Foundation
import Zip

/** AOS Universe domain media download service
 */

public final class AOSUniverse {
    private let baseUrl = "https://universe.astreos.space"
    private let imageUrl = "https://universe.oseyeris.com/serve/typeID/images/"

    internal var payload:Payload?
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
        for object in AOSType.allCases {
            if directoryExists(object.directoryUrl) {
try! FileManager.default.createDirectory(at: object.directoryUrl, withIntermediateDirectories: true, attributes: nil)
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
        let filemanager = FileManager.default
        try? filemanager.moveItem(at: url, to: asset.fileURL)
    }

    internal func directoryExists( _ url: URL)->Bool {
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }
    
internal func getAssetUrl( _ fileName: String, _ assetType: AssetType, _ type: AOSType)->URL {
    return URL(string: baseUrl)!.appendingPathExtension(assetType.id).appendingPathExtension(type.id).appendingPathComponent(fileName)
    }
    
}
