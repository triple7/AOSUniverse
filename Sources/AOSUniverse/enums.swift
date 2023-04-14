//
//  File.swift
//  
//
//  Created by Yuma decaux on 13/4/2023.
//

import Foundation

public typealias AOSType = AOSUniverseObject

public enum AOSUniverseObject:String, Identifiable, CaseIterable {
    case CATS
    case MAST
    case NGC
    case TESS
    case asteroid
    case blackHole
    case comet
    case constellation
    case exoplanet
    case faststar
    case kylonova
    case messier
    case naturalSat
    case planet
    case satellite
    case supernova
    case tidaldisruption
    
    public var id:String {
        return self.rawValue.lowercased()
    }
    
    func directoryUrl(_ assetType: AssetType)->URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathExtension(assetType.id).appendingPathExtension(self.id)
    }
}

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

