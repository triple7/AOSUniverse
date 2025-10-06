//
//  AssetType.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 6/10/2025.
//


public enum AssetType:String, Identifiable, CaseIterable {
    case model
    case image
    case fits
    case audio
    case video
    case stream
    
    public var id:String {
        return self.rawValue
    }
    
    var media:String {
        switch self {
        case .model: return "zip"
        case .image: return "jpg"
        case .fits: return "fits"
        case .audio: return "mp3"
        case .video: return "mp4"
        case .stream: return "stream"
        }
    }
}
