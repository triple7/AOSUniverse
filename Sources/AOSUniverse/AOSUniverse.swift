import Foundation
import Zip
import SceneKit

#if os(iOS)
import UIKit
public typealias Image = UIImage
public typealias Label = UILabel
#elseif os(macOS)
import AppKit
public typealias Image = NSImage
public typealias Label = NSTextField
#endif

public final class AOSUniverse:NSObject {
    internal let baseUrl = "https://universe.oseyeris.com/serve/"
    public lazy var models:[SCNScene] = {
        return [SCNScene]()
    }()

    private var buffer:Int?
    public var progress:Float?
    private var expectedContentLength:Int?
    public lazy var sysLog:[AOSSysLog] = {
        return [AOSSysLog]()
    }()
    internal var progressLabel:Label?
    
    public static let shared = AOSUniverse()

    private override init() {
        /** Initializer
         Checks for all object relative directories are created
         the first time it's run
         */
        
        for assetType in AssetType.allCases {
            for object in AOSType.allCases {
                if FileManager.default.fileExists(atPath: object.directoryUrl(assetType).absoluteString) {
                    print("AOSUniverse: creating \(object) folder")
                    try! FileManager.default.createDirectory(at: object.directoryUrl(assetType), withIntermediateDirectories: true, attributes: nil)
                }
            }
        }
        
        super.init()
    }

    func saveScnFile(for asset: AOSAsset, at url: URL) {
            try? FileManager.default.moveItem(at: url, to: asset.fileURL)
    }

    func saveScene(scene: SCNScene, assetType: AssetType, type: AOSType, name: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let subdirectoryURL = documentsDirectory.appendingPathComponent(assetType.id).appendingPathComponent(type.id)
            do {
                if !FileManager.default.fileExists(atPath: subdirectoryURL.path) {
                    try FileManager.default.createDirectory(at: subdirectoryURL, withIntermediateDirectories: true, attributes: nil)
                }
                
                let sceneFileURL = subdirectoryURL.appendingPathComponent("\(name).scn")
                
                // Save the scene to the specified file URL
                scene.write(to: sceneFileURL, options: nil, delegate: nil)
                
                print("saveScnFile: saved to \(sceneFileURL.path)")
            } catch {
                print("saveScnFile: Error saving scene \(error.localizedDescription)")
            }
        }
    }

    internal func unpackScn(at url: URL, body: AOSBody) -> SCNScene? {
        do{
            let data = try! Data(contentsOf: url)

            let targetpath = getLocalAssetUrl(body: body)
            let targetUrl = targetpath.appendingPathComponent("\(body.id).zip", isDirectory: false)
            try data.write(to: targetUrl)
            try Zip.unzipFile(targetUrl, destination: targetpath, overwrite: true, password: nil)
            let folder = try FileManager.default.contentsOfDirectory(atPath: targetpath.path())

            var scene:SCNScene
            let jpegFiles = folder.filter{$0.contains(".jpg")}

            if let sceneFile = (folder.filter{ $0.contains(".scn") }).first {
                // TODO: filter per material component
                // TODO: all remote files should be packaged as zipped scn
                scene = try SCNScene(url: targetpath.appendingPathComponent(sceneFile))
                if jpegFiles.count != 0 {
                    let jpegUrl = targetpath.appendingPathComponent(jpegFiles.first!)
                    let image = Image(contentsOfFile: jpegUrl.path())
                    let material = SCNMaterial()
                    material.diffuse.contents = image
                    scene.rootNode.childNodes.forEach { node in
                        node.geometry?.materials = [material]
                        node.geometry?.firstMaterial?.displacement.contents = material
                    }
                }
            } else {
                // legacy method
                let obj = folder.filter{$0.contains(".obj")}.first!
                let mtl = folder.filter{$0.contains(".mtl")}
                let hasMtl = mtl.count > 0
                scene = try SCNScene(url: targetpath.appendingPathComponent(obj), options: hasMtl ? [SCNSceneSource.LoadingOption.assetDirectoryURLs: [mtl.first!]] : nil)
            }
            // Delete zip file
            try FileManager.default.removeItem(at: targetUrl)
            return scene
        }catch let error{
            print("error: \(error.localizedDescription)")
            assertionFailure(error.localizedDescription)
            return nil
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

    internal func pathExists( _ url: URL)->Bool {
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }
    
internal func getRemoteAssetUrl( _ fileName: String, _ assetType: AssetType, _ type: AOSType)->URL {
    return URL(string: baseUrl)!.appendingPathComponent(assetType.id).appendingPathComponent(type.id).appendingPathComponent(fileName)
    }

    
    internal func getRemoteAssetUrl( assetpath: [String], type: String, fileName: String)->URL {
        var url = URL(string: baseUrl)!
        for asset in assetpath {
            url = url.appendingPathComponent(asset)
        }
        url = url.appendingPathComponent(type)
        return url.appendingPathComponent(fileName)
        }

    
    internal func getLocalAssetUrl(body: AOSBody)->URL {
        return getAssetUrl(assetpath: [body.type.id, "models"], type: "\(body.id)")
        }

    internal func getGenericModel(type: AOSType)->SCNScene {
        let filename = "\(type.id).scn"
        print("AOSUniverse: loading generic model \(filename)")
        return SCNScene(named: filename)!
    }
                             
    public func getBodyModel( body: AOSBody, progressLabel: Label, completion: @escaping (SCNScene)-> Void) {
        downloadAssetModel(bodies: [body], progressLabel: progressLabel, completion: { result in
            completion(self.models.removeFirst())
        })
    }
    
}

extension AOSUniverse:URLSessionDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        expectedContentLength = Int(response.expectedContentLength)
        buffer = 0
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer = buffer! + data.count
        let percentageDownloaded = Float(buffer!) / Float(expectedContentLength!)
        DispatchQueue.main.async {
#if os(iOS)
            self.progressLabel?.text = "\(percentageDownloaded) percent"
#endif
        }
    }

    
    internal func printLogs() {
        for log in sysLog {
            print(log)
        }
    }
}
