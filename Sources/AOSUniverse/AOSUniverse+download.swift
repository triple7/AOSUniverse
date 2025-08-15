//
//  AOSUniverse+legacyDownload.swift
//  
//
//  Created by Yuma decaux on 4/11/2023.
//

import Foundation
import SceneKit
import Zip

extension AOSUniverse {
    
    /** request returned data check
     */
    private func requestIsValid(error: Error?, response: URLResponse?, url: URL? = nil) -> Bool {
        var gotError = false
        if let error = error {
            self.sysLog.append(AOSSysLog(log: .RequestError, message: error.localizedDescription))
            gotError = true
        }
        if let response = response {
            let urlResponse = (response as! HTTPURLResponse)
            if urlResponse.statusCode != 200 {
                let responseError = NSError(domain: "com.error", code: urlResponse.statusCode)
                self.sysLog.append(AOSSysLog(log: .RequestError, message: responseError.localizedDescription))
                gotError = true
            }
        } else {
            self.sysLog.append(AOSSysLog(log: .RequestError, message: "response timed out"))
            gotError = true
        }
if !gotError {
            let message = url != nil ? url!.absoluteString : "data"
            self.sysLog.append(AOSSysLog(log: .Ok, message: "\(message) downloaded"))
        }
        return !gotError
    }

    
    public func downloadAssetModel(bodies: [AOSBody], progressLabel: Label?, completion: @escaping ([SCNScene]) -> Void) {
        let serialQueue = DispatchQueue(label: "AOSUniverseDownloadQueue")
        
        self.progressLabel = progressLabel
        let session = URLSession.shared
        var remainingBodies = bodies
        var output = [SCNScene]()
        
        // Create a recursive function to handle the download
        func downloadNextBody() {
            guard !remainingBodies.isEmpty else {
                // All URLs have been downloaded, call the completion handler
                completion(output)
                return
            }
            
            let body = remainingBodies.removeFirst()
            let modelUrl = getRemoteAssetUrl(assetpath: [body.type.id, "models"], type: "", fileName: "\(body.id).zip")
            
            let operation = ModelDownloadOperation(session: session, downloadTaskUrl: modelUrl, completionHandler: { (tempUrl, response, error) in
                if self.requestIsValid(error: error, response: response, url: tempUrl) {
                    output.append(self.unpackScn(at: tempUrl, body: body)!)
                    self.sysLog.append(AOSSysLog(log: .Ok, message: "\(modelUrl.lastPathComponent) downloaded"))
                } else {
                    // get generic model for given body type
                    output.append(self.getGenericModel(type: body.type))
                    self.sysLog.append(AOSSysLog(log: .Ok, message: "Generic \(body.type.id) used"))
                }
                
                // Call the recursive function to download the next url
                serialQueue.async {
                    downloadNextBody()
                }
            })
            
            // Add the operation to the serial queue to execute it serially
            serialQueue.async {
                operation.start()
            }
        }
        
        // Start the download process by calling the recursive function
        serialQueue.async {
            downloadNextBody()
        }
    }

    public func downloadAssetModel(
        bodies: [AOSBody],
        progressLabel: Label?
    ) async -> [SCNScene] {
        let session = URLSession.shared
        var output: [SCNScene] = []

        for (index, body) in bodies.enumerated() {
            let modelUrl = getRemoteAssetUrl(
                assetpath: [body.type.id, "models"],
                type: "",
                fileName: "\(body.id).zip"
            )

            do {
                let (tempUrl, response) = try await session.download(from: modelUrl)
                if requestIsValid(error: nil, response: response, url: tempUrl) {
                    if let scene = unpackScn(at: tempUrl, body: body) {
                        output.append(scene)
                        sysLog.append(AOSSysLog(log: .Ok, message: "\(modelUrl.lastPathComponent) downloaded"))
                    } else {
                        throw URLError(.badServerResponse)
                    }
                } else {
                    throw URLError(.badServerResponse)
                }
            } catch {
                output.append(getGenericModel(type: body.type))
                sysLog.append(AOSSysLog(log: .Ok, message: "Generic \(body.type.id) used"))
            }

            if let label = progressLabel {
                await MainActor.run {
#if os(iOS)
                    label.text = "Downloaded \(index + 1) of \(bodies.count)"
#elseif os(macOS)
                    label.stringValue = "Downloaded \(index + 1) of \(bodies.count)"
#endif
                }
            }
        }

        return output
    }

    
    private func fetchLastModifiedDate(for url: URL, dateCompletion: @escaping (Date?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"  // Use HEAD to fetch only headers without downloading the file
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error fetching headers: \(error?.localizedDescription ?? "Unknown error")")
                dateCompletion(nil)
                return
            }
            
            if let lastModifiedString = httpResponse.allHeaderFields["Last-Modified"] as? String {
                let dateFormatter = self.getGmtDateFormatter()
                if let lastModifiedDate = dateFormatter.date(from: lastModifiedString) {
                    dateCompletion(lastModifiedDate)
                    return
                }
            }
            
            dateCompletion(nil)  // Return nil if Last-Modified header is not available or parsing fails
        }
        
        task.resume()
    }
    
    private func getRemoteManifest(url: URL, completion: @escaping (Manifest?) -> Void ) {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
          
            if self.requestIsValid(error: error, response: response) {
                let decoder = JSONDecoder()
                let manifest = try! decoder.decode(Manifest.self, from: data!)
                completion(manifest)
                return
            }
            completion(nil)
        
        })
        task.resume()
    }
    
    
    private func getRemoteSource(url: URL, completion: @escaping (URL?) -> Void ) {
        
        let session = URLSession.shared
        
        let task = session.downloadTask(with: url) { tempUrl, response, error in
            
            if self.requestIsValid(error: error, response: response, url: tempUrl) {
                completion(tempUrl)
                return
            }
            completion(nil)
        }
        task.resume()
    }
    
    public func updateResource(assetPath: [String], type: String, result: @escaping ([URL]) -> Void ) {
        
        let localManifest = getManifest(assetpath: assetPath, type: type).manifest
        let url = getRemoteAssetUrl(assetpath: assetPath, type: type, fileName: "manifest.json")
        
        getRemoteManifest(url: url, completion: { payload in
            // compare lastModified and add new resources
            if let payload = payload {
                let remoteManifest = payload.manifest
                
                let localLastModified = localManifest.map{self.getLastModifiedDate(dateString: $0.lastModified)}
                let remoteLastModified = remoteManifest.map{self.getLastModifiedDate(dateString: $0.lastModified)}
                
                var updates = [String]()
                if localLastModified.count == 0 {
                    // First manifest, download everything
                    updates = remoteManifest.map{$0.name}
                } else {
                    for (i, lastModified) in remoteLastModified.enumerated() {
                        let remoteModified = remoteLastModified[i]
                        if max(lastModified!, remoteModified!) == remoteModified! && lastModified != remoteModified! {
                            updates.append(remoteManifest[i].name)
                        }
                    }
                }
                if !updates.isEmpty {
                    // Save the new manifest to file
                    let manifestUrl = getAssetUrl(assetpath: assetPath, type: type).appendingPathComponent("manifest.json")
                    createManifest(manifest: payload, url: manifestUrl)
                    // Serially download the new resources
                    let updatedUrls = updates.map{self.getRemoteAssetUrl(assetpath: assetPath, type: type, fileName: $0)}
                    self.getRemoteResources(assetpath: assetPath, type: type, urls: updatedUrls, completion: { savedUrls in
                        result(savedUrls)
                    })
                }
            }
                                       })
                    
                }
                
                
    public func getRemoteResources(assetpath: [String], type: String, urls: [URL], completion: @escaping  ([URL]) -> Void) {
                    let serialQueue = DispatchQueue(label: "resourcesDownloadQueue")
                    
                    var remainingUrls = urls
                    
        let session = URLSession.shared
                    var output = [URL]()
                    
                    // Create a recursive function to handle the download
                    func downloadNextResource() {
                        guard !remainingUrls.isEmpty else {
                            // All resources have been downloaded, call the completion handler
                            completion(output)
                            return
                        }
                        
                        let resource = remainingUrls.removeFirst()
                        let request = URLRequest(url: resource)
                        
                        let operation = AOSDirectDownloadTask(session: session, request: request, completionHandler: { (tempUrl, response, error) in
                            
                            if self.requestIsValid(error: error, response: response, url: tempUrl) {
                                // Save the file
                                let savedUrl = moveFileToPath(assetpath: assetpath, type: type, url: tempUrl!, text: resource.lastPathComponent)
                                
                                output.append(savedUrl)
                            }
                            // Call the recursive function to download the next object
                            serialQueue.async {
                                downloadNextResource()
                            }
                            
                        })
                        // Add the operation to the serial queue to execute it serially
                        serialQueue.async {
                            operation.start()
                        }

                    } // end of downloadNextResource

                    
                        // Start the download process by calling the recursive function
                        serialQueue.async {
                            downloadNextResource()
                        }
                    
                }
                

    
    public func getResources(assetPath: [String], type: String, sources: [String], preview: Bool = false, completion: @escaping ([URL]) -> Void) {
        var sources = sources
        if preview {
            sources = sources.map{"thumb_\($0)"}
        }
        let remoteUrls = sources.map{getRemoteAssetUrl(assetpath: assetPath, type: type, fileName: $0)}
        self.getRemoteResources(assetpath: assetPath, type: type, urls: remoteUrls, completion: { localUrls in
            completion(localUrls)
        })

    }
        
            } // extension
