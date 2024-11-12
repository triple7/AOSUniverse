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
                var gotError = false
                if error != nil {
                    self.sysLog.append(AOSSysLog(log: .RequestError, message: error!.localizedDescription))
                    gotError = true
                }
                if (response as? HTTPURLResponse) == nil  {
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

    public func getUpdatedSource(assetPath: [String], type: String="interface", name:String, result: @escaping (URL) -> Void ) {
        var url = URL(string: baseUrl)!
        for path in assetPath {
            url = url.appendingPathComponent(path, isDirectory: true)
        }
        url = url.appendingPathComponent(type, isDirectory: true)
        url = url.appending(component: "\(name)_\(type)_low.mp3")
        print(url.absoluteString)
        // Get the lastModified date regardless
        fetchLastModifiedDate(for: url, dateCompletion: { remoteLastModified in
            print(remoteLastModified)
            if !fileIsInCache(assetpath: assetPath + [type], text: "\(name)_\(type)_low") {
            self.getRemoteSource(url: url, completion: { tempUrl in
                let loadedUrl = moveFileToPath(assetpath: assetPath, type: type, url: tempUrl!, text: name)
                setLastModifiedDate(for: loadedUrl, to: remoteLastModified!)

                result(loadedUrl)
                return
            })
        } else {
            // Compare local file against remote
                let localUrl = getCachedFile(assetpath: assetPath + [type], text: name)
                let localLastModified = getLastModifiedDate(for: localUrl.absoluteString)
                
                // most recent becomes cached version
                if max(remoteLastModified!, localLastModified!) == remoteLastModified {

                    self.getRemoteSource(url: url, completion: { tempUrl in
                        let loadedUrl = moveFileToPath(assetpath: assetPath, type: type, url: tempUrl!, text: name)
                        setLastModifiedDate(for: loadedUrl, to: remoteLastModified!)
                        result(loadedUrl)
                        return
                    })

                    
                } else {
                    result(localUrl)
                }
            }
            
        })

    }
    
}

