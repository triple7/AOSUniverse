import Foundation
import Zip
import SceneKit

/** AOS Universe domain media download service
 */

public struct AOSSysLog:CustomStringConvertible {
    let timecode:String
    let log:AOSNetworkError
    let message:String
    
    public init( log: AOSNetworkError, message: String) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy--MM-dd hh:mm:ss"
        self.timecode = dateFormatter.string(from: date)
        self.log = log
                  self.message = message
    }
    
    public var description:String {
        return "\(log): \(message)"
    }
}

public final class AOSUniverse:ObservableObject {
    private let baseUrl = "https://universe.astreos.space"
    public lazy var models:[SCNScene] = {
        return [SCNScene]()
    }()

    private var buffer:Int?
    public var progress:Float?
    private var expectedContentLength:Int?
    public lazy var sysLog:[AOSSysLog] = {
        return [AOSSysLog]()
    }()

    public let shared = AOSUniverse()

    private init() {
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

    internal func unpackModel(at url: URL, body: AOSBody) -> AssetPayload {
        do{
            let unzipDirectory = try Zip.quickUnzipFile(url)
            let folder = try FileManager.default.contentsOfDirectory(atPath: unzipDirectory.path)

            let assetQuality = AssetQuality.Unknown.getQuality(folder: folder)
            
            let objs = folder.filter{ $0.contains(".obj")}.map{unzipDirectory.appendingPathComponent($0, isDirectory: false).path()}
            var modelFiles = [String:String]()
            for (i, obj) in objs.enumerated() {
                modelFiles[obj.components(separatedBy: ".").last!] = obj
            }
            let textures = folder.filter{$0.contains(".jpg")}.map{unzipDirectory.appendingPathComponent($0, isDirectory: false).path()}
            
            var textureFiles = [String:Texture]()
            
                                                  let bumpMaps = textures.filter{$0.contains("_bump")}
            let diffusemaps = textures.filter{!$0.contains("_bump")}
            let mtl = folder.filter{$0.contains(".mtl")}.map{unzipDirectory.appendingPathComponent($0, isDirectory: false).path}

            return AssetPayload(assetQuality: assetQuality, modelFiles: modelFiles, textureFiles: textureFiles, mtl: mtl.count > 0 ? mtl.first! : nil)
        }catch let error{
            assertionFailure(error.localizedDescription)
        }
        
        return AssetPayload(assetQuality: .Unknown, modelFiles: [String: String](), textureFiles: [String: Texture]())
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
    return URL(string: baseUrl)!.appendingPathExtension(assetType.id).appendingPathExtension(type.id).appendingPathComponent(fileName)
    }

    internal func getLocalAssetUrl(body: AOSBody)->URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathExtension(AssetType.model.id).appendingPathExtension(body.type.id).appendingPathComponent(body.name)
        }

    internal func getSCNScene( body: AOSBody)-> SCNScene {
        let url = getLocalAssetUrl(body: body)
        do {
            let scene = try SCNScene(url: url)
            return scene
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
                             // Should not get here
                             return SCNScene()
    }
    
                             internal func getGenericModel(type: AOSType)->SCNScene {
                return SCNScene(named: type.id)!
            }
                             
    public func getBodyModel( body: AOSBody, completion: @escaping (SCNScene)-> Void) {
        downloadAssetModel(bodies: [body], completion: { result in
            completion(self.models.removeFirst())
        })
    }
    
}
