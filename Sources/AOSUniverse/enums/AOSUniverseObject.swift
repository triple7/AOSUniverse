//
//  AOSUniverseObject.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 6/10/2025.
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
    case Gaia
    case Kylonova
    case Messier
    case NaturalSat
    case Planet
    case Satellite
    case Star
    case Supernova
    case Tidaldisruption
    case SolarSystem
    
    public var id: String {
        guard let firstLetter = self.rawValue.first?.lowercased() else {
            return self.rawValue
        }
        let rest = self.rawValue.dropFirst()
        return firstLetter + rest
    }

    
    func directoryUrl(_ assetType: AssetType)->URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathExtension(assetType.id).appendingPathExtension(self.id)
    }
}

