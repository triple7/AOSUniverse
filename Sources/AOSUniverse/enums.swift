//
//  File.swift
//  
//
//  Created by Yuma decaux on 13/4/2023.
//

import Foundation

public typealias AOSType = AOSUniverseObject

public enum AOSUniverseObject:String, Codable, CaseIterable {
    case None
    case CATS
    case Derelict
    case MAST
    case NGC
    case TESS
    case Asteroid
    case BlackHole
    case Comet
    case Constellation
    case Exoplanet
    case Earth
    case EarthSat
    case Faststar
    case Kylonova
    case Messier
    case NaturalSat
    case Planet
    case Satellite
    case Star
    case Supernova
    case Tidaldisruption
    case SolarSystem
    
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


