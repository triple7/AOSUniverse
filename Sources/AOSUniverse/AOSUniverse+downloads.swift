//
//  File.swift
//  
//
//  Created by Yuma decaux on 13/4/2023.
//

import Foundation
import SceneKit

extension AOSUniverse {

//    @MainActor
//    public func downloadModel(_ name: String, _ type: AOSType) async -> SCNScene{
//        let fileName = "\(name).zip"
//        let url = getAssetUrl(fileName, type)
//                let (data, _) = try await URLSession.shared.data(from: url)
//            }

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
