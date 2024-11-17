//
//  AOSUniverse+legacyDownload.swift
//  
//
//  Created by Yuma decaux on 4/11/2023.
//

import Foundation
import Zip

extension AOSUniverse {
    
    /** request returned data check
     */
    private func requestIsValid(error: Error?, response: URLResponse?, url: URL? = nil) -> Bool {
        var gotError = false
        if error != nil {
            print(error!.localizedDescription)
            self.sysLog.append(AOSSysLog(log: .RequestError, message: error!.localizedDescription))
            gotError = true
        }
        if (response as? HTTPURLResponse) == nil {
            self.sysLog.append(AOSSysLog(log: .RequestError, message: "response timed out"))
            gotError = true
        }
        let urlResponse = (response as! HTTPURLResponse)
        if urlResponse.statusCode != 200 {
            let error = NSError(domain: "com.error", code: urlResponse.statusCode)
            self.sysLog.append(AOSSysLog(log: .RequestError, message: error.localizedDescription))
            gotError = true
        }
        if !gotError {
            let message = url != nil ? url!.absoluteString : "data"
            self.sysLog.append(AOSSysLog(log: .Ok, message: "\(message) downloaded"))
        }
        return !gotError
    }
    
    public func downloadAssetModel(bodies: [AOSBody], completion: @escaping (Bool) -> Void) {
        let serialQueue = DispatchQueue(label: "AOSUniverseDownloadQueue")
        
        var remainingBodies = bodies
        
        // Create a recursive function to handle the download
        func downloadNextBody() {
            guard !remainingBodies.isEmpty else {
                // All URLs have been downloaded, call the completion handler
                completion(true)
                return
            }
            
            let body = remainingBodies.removeFirst()
            let modelUrl = getRemoteAssetUrl(body.getModelName(), .model, body.type)
            
            let operation = ModelDownloadOperation(session: URLSession.shared, dataTaskURL: modelUrl, completionHandler: { (data, response, error) in
                if self.requestIsValid(error: error, response: response) {
                    self.unpackModel(at: modelUrl, body: body)
                    self.models.append(self.getSCNScene(body: body))
                    self.sysLog.append(AOSSysLog(log: .Ok, message: "\(modelUrl.lastPathComponent) downloaded"))
                    completion(true)
                } else {
                    // get generic model for given body type
                    self.models.append(self.getGenericModel(type: body.type))
                    completion(true)
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
                let dateFormatter = getGmtDateFormatter()
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
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
          
            if self.requestIsValid(error: error, response: response) {
                let text = String(data: data!, encoding: .utf8)
                print(text)
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
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        let task = session.downloadTask(with: url) { tempUrl, response, error in
            
            if self.requestIsValid(error: error, response: response, url: tempUrl) {
                completion(tempUrl)
                return
            }
            completion(nil)
        }
        task.resume()
    }
    
    public func updateResource(assetPath: [String], type: String, result: @escaping (Bool) -> Void ) {
        
        let localManifest = getManifest(assetpath: assetPath, type: type).manifest
        var url = URL(string: baseUrl)!
        for path in assetPath {
            url = url.appendingPathComponent(path, isDirectory: true)
        }
        url = url.appendingPathComponent(type, isDirectory: true)
        url = url.appending(component: "manifest.json")
        
        getRemoteManifest(url: url, completion: { payload in
            // compare lastModified and add new resources
            if let payload = payload {
                let remoteManifest = payload.manifest
                
                print(localManifest)
                let localLastModified = localManifest.map{getLastModifiedDate(dateString: $0.name)}
                let remoteLastModified = remoteManifest.map{getLastModifiedDate(dateString: $0.lastModified)}
                
                var updates = [String]()
                if localLastModified.count == 0 {
                    // First manifest, download everything
                    updates = remoteManifest.map{$0.name}
                } else {
                    for (i, lastModified) in remoteLastModified.enumerated() {
                        let remoteModified = remoteLastModified[i]
                        if max(lastModified!, remoteModified!) == remoteModified! {
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
                    self.getRemoteResources(assetpath: assetPath, type: type, urls: updatedUrls, completion: { success in
                        print("All assets downloaded")
                    })
                }
            }
                                       })
                    
                }
                
                
                public func getRemoteResources(assetpath: [String], type: String, urls: [URL], completion: @escaping (Bool) -> Void ) {
                    let serialQueue = DispatchQueue(label: "resourcesDownloadQueue")
                    
                    var remainingUrls = [URL]()
                    
                    // Create a recursive function to handle the download
                    func downloadNextResource() {
                        guard !remainingUrls.isEmpty else {
                            // All resources have been downloaded, call the completion handler
                            completion(true)
                            return
                        }
                        
                        let resource = remainingUrls.removeFirst()
                        let request = URLRequest(url: resource)
                        
                        let operation = AOSDirectDownloadTask(session: URLSession.shared, request: request, completionHandler: { (tempUrl, response, error) in
                            
                            if self.requestIsValid(error: error, response: response, url: tempUrl) {
                                // Save the file
                                let _ = moveFileToPath(assetpath: assetpath, type: type, url: tempUrl!, text: resource.lastPathComponent)
                                
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
                        
                        // Start the download process by calling the recursive function
                        serialQueue.async {
                            downloadNextResource()
                        }
                    }
                    
                }
                
                
            } // extension
