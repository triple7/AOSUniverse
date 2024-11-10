//
//  AOSUniverse+legacyDownload.swift
//  
//
//  Created by Yuma decaux on 4/11/2023.
//

import Foundation
import Zip

extension AOSUniverse {

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
}

