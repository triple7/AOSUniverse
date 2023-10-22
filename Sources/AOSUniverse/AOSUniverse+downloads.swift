//
//  File.swift
//  
//
//  Created by Yuma decaux on 13/4/2023.
//

/*
import Foundation

extension AOSUniverse {

    @MainActor
    func attachPayload( _ payload: inout Payload) async throws {
        let assets = payload.assets
        for (i, asset) in assets.enumerated() {
            var request = URLRequest(url: asset.url)
            request.httpMethod = "HEAD"
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let modifiedDateString =
               httpResponse.allHeaderFields["Last-Modified"] as? String,
                  let modifiedDate = DateFormatter().date(from:  modifiedDateString) else {
                throw URLError(URLError.badURL)
               }
            if asset.fileExists() && !(asset.getLastModified() <= modifiedDate) {
                payload.removeAsset(at: i)
            }
        }
        self.payload = payload
    }

    @MainActor
    func download(_ asset: Asset) async throws {
        guard downloads[asset.url] == nil else { return }
        let download = Download(url: asset.url, downloadSession: downloadSession)
        downloads[asset.url] = download
        payload?[asset.id]?.isDownloading = true
        for await event in download.events {
            process(event, for: asset)
        }
        downloads[asset.url] = nil
    }

    func pauseDownload(for asset: Asset) {
        downloads[asset.url]?.pause()
    }

    func resumeDownload(for asset: Asset) {
        downloads[asset.url]?.resume()
        payload?[asset.id]?.isDownloading = true
    }

}

*/
