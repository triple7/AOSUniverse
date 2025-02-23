//
//  File.swift
//  
//
//  Created by Yuma decaux on 17/10/2023.
//

import Foundation
import SceneKit

public enum SpectralType: String, Codable, Identifiable, CaseIterable {
    case O, B, A, F, G, K, M  // Main sequence and giants
    case C, R, N, S           // Carbon and cool stars
    case WC, WN, WR, NO, SC, FO // Wolf-Rayet and exotic stars
    case Unknown
    
    public var id:String {
        return self.rawValue
    }
    
}

extension SCNVector3: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let x = try values.decode(CGFloat.self, forKey: .x)
        let y = try values.decode(CGFloat.self, forKey: .y)
        let z = try values.decode(CGFloat.self, forKey: .z)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }

    private enum CodingKeys: String, CodingKey {
        case x,y,z
    }
}

public struct AOSBody:Codable {
    public let name:String
    public let id:Int
    public let type:AOSType
    public let parent:String
    public var coordinates:[SCNVector3]
    public var coordinateTimestamps:[Double]
    public var currentCoordTimestamp:Double
    public var distanceToEarth:Float
    public var radiusOfGeometry:Float
    public var epoch0:Int?

    //    Semi Major axis length
    public var orbitSemiMajorAxis:Float
    //    Eccentricity of the orbit, indicating how much the orbit deviates from being circular.
    public var orbitEccentricity:Float
    //    Inclination of the orbit, the tilt of the orbit relative to the equatorial plane.
    public var orbitInclination:Float
    //    Argument of pericenter, the angle from the ascending node to the orbit's closest point to the reference body.
    public var orbitArgPericenter:Float
    //    Right ascension of the ascending node, the angle from the reference direction to the ascending node of the orbit.
    public var orbitRightAscension:Float
    //Mark: Initialiser for earth sats and Asteroids
    public init(name: String, id: Int, type: AOSType, parent: String = "SolarSystem", coordinates: [SCNVector3] = [], coordinateTimestamps: [Double] = []){
        self.id = id
        self.name = name
        self.type = type
        if type == .Asteroid {
            self.parent = parent
        } else if type == .EarthSat {
            self.parent = "NEOs"
        } else {
            self.parent = parent
        }
        self.coordinates = coordinates
        self.coordinateTimestamps = coordinateTimestamps
        self.currentCoordTimestamp = 0.0
        self.distanceToEarth = 0.0
        self.radiusOfGeometry = 0.0
        self.orbitSemiMajorAxis = 0.0
        self.orbitEccentricity = 0.0
        self.orbitInclination = 0.0
        self.orbitArgPericenter = 0.0
        self.orbitRightAscension = 0.0
    }
    
    public func earthSatId() -> Int {
        switch self.type {
        case .EarthSat: return self.id + Int(10e8)
        default: return self.id
        }
    }
    
    public func getModelName()->String {
        return "\(id)_scn.zip"
    }
    
    public mutating func setRadiusOfGeometry(radiusGeometry: Float) {
        self.radiusOfGeometry = radiusGeometry
    }

    public mutating func setCurrentCoordTimestamp(currentCoordTimestamp: Double) {
        self.currentCoordTimestamp = currentCoordTimestamp
    }

    public mutating func setOrbitParameters(SemiMajorAxis: Float, Eccentricity: Float, Inclination: Float, ArgPericenter: Float, RightAscension: Float) {
        self.orbitSemiMajorAxis = SemiMajorAxis
        self.orbitEccentricity = Eccentricity
        self.orbitInclination = Inclination
        self.orbitArgPericenter = ArgPericenter
        self.orbitRightAscension = RightAscension
    }
}

extension AOSBody:Equatable, Comparable{
public static     func ==(lhs: AOSBody, rhs: AOSBody)->Bool{
        return lhs.id == rhs.id
    }
    
    public static func <(lhs: AOSBody, rhs: AOSBody) -> Bool{
        return lhs.id < rhs.id
    }
    
}

public struct AOSMb:Codable {
    public let type:AOSType
    public let id:Int
    public let distanceToEarth:Float // per object as scaling occurs
    public var radiusOfGeometry:Float

    public init( _ type: AOSType, _ id: Int, _ distanceToEarth: Float) {
        self.type = type
        self.id = id
        self.distanceToEarth = distanceToEarth
        self.radiusOfGeometry = 0.0
    }
    
    public mutating func setRadiusOfGeometry(radiusGeometry: Float) {
        self.radiusOfGeometry = radiusGeometry
    }

}

public struct AOSBoundingBox:Codable {
    public let type:AOSType
    
    public init( _ type: AOSType) {
        self.type = type
    }
}

public struct AOSStar:Codable {
    
    public let type:AOSType
    public let id:Int
    public let starCategory:Int
    public let spectral:SpectralType
    public let distanceToEarth:Float // per object as scaling occurs in 3D space
    public var radiusOfGeometry:Float
    public let proper: String // proper star name
    public var hip: Int? // for exoplanet query
    public var hd:Int? // for exoplanet query
    public var greek:String?
    public var plural:String?
    
    public init(_ type: AOSType, _ id: Int, _ hd: Int?, _ hip: Int?, _ proper: String, _ starCategory: Int, _ spectral: String, _ distanceToEarth: Float, _ greek: String, _ plural: String) {
        self.type = type
        self.id = id
        self.hd = hd
        self.hip = hip
        self.proper = proper
        self.starCategory = starCategory
        self.spectral = SpectralType(rawValue: spectral) ?? .Unknown
        self.distanceToEarth = distanceToEarth
        self.greek = greek
        self.plural = plural
        self.radiusOfGeometry = 0.0
    }
    
    public mutating func setRadiusOfGeometry(radiusGeometry: Float) {
        self.radiusOfGeometry = radiusGeometry
    }
    
    public mutating func setGreek(greek: String) {
        self.greek = greek
    }
    
    public func mastId() -> String {
        if let hip = self.hip {
            return "HIP\(hip)"
        } else if let hd = self.hd {
            return "HD\(hd)"
        } else if proper != "" {
            return proper
        } else {
            return ""
        }
    }
    
    public func starIdentification() -> [String] {
        var output = [String]()
        if let hip = self.hip {
            output.append("HIP\(hip)")
        }
        if proper != "" {
            output.append(proper)
        }
        output.append("spectral")
        output.append(spectral.id)
        return output
    }
    
    public func starNames() -> [String] {
        var output = [String]()
        if proper != "" {
            output.append(proper)
        }
        if let symbol = greek {
            let pluralLower = plural?.replacingOccurrences(of: " ", with: "")
            if output.count > 0 {
                output.append(contentsOf: ["or", symbol, pluralLower!])
            } else {
                output.append(contentsOf: [symbol, pluralLower!])
            }
        }
        if output.count == 0 {
            output.append(spectral.id)
        }
        return output
    }

            public func getSpectralBrightness() -> CGFloat {
                switch self.spectral {
                case .O: return 1.0000
                case .B: return 0.9906
                case .A: return 0.9812
                case .F: return 0.9719
                case .G: return 0.9625
                case .K: return 0.9531
                case .M: return 0.9437
                case .C: return 0.9344
                case .R: return 0.9250
                case .N: return 0.9156
                case .S: return 0.9062
                case .WC: return 0.8969
                case .WN: return 0.8875
                case .WR: return 0.8781
                case .NO: return 0.8687
                case .SC: return 0.8594
                case .FO: return 0.8500
                default: return 0.85
                }
            }
        

}

public struct AOSConstellation:Codable {
    public let type:AOSType
    public let constellationDistance:Float
    public let constellationLYDistance:Float
    public let constLineIndex:Int
    public let constShort:String
    
    
    public init( _ type: AOSType, _ constellationDistance: Float, _ constellationLYDistance: Float, _ constLineIndex: Int, _ constShort: String) {
        self.type = type
        self.constellationDistance = constellationDistance
        self.constellationLYDistance = constellationLYDistance
        self.constLineIndex = constLineIndex
        self.constShort = constShort
        
    }

}

public struct AOSBlackHole:Codable {
    public let type:AOSType
    public let distanceToEarth:Float
    public var radiusOfGeometry:Float

    public init( _ type: AOSType, _ distanceToEarth: Float) {
        self.type = type
        self.distanceToEarth = distanceToEarth
        self.radiusOfGeometry = 0.0
    }
    
    public mutating func setRadiusOfGeometry(radiusGeometry: Float) {
        self.radiusOfGeometry = radiusGeometry
    }

}

public struct AOSGreek:Codable {
    public let name:String
    public let unicode:String
}


public enum AssetQuality:String, Identifiable, Codable {
    case FullScene
    case ObjectOnly
    case MaterialOnly
    case Unknown
    
    public var id:String {
        return self.rawValue
    }
}

public enum MaterialQuality:String, Identifiable, Codable {
    case Normal
    case Lower
    case Lowest
    
    public var id:String {
        return self.rawValue
    }
}

public struct Texture:Codable {
    let normal:String
    let lower:String
    let lowest:String
    
    public func fileName(resolution: MaterialQuality) -> String {
        switch resolution {
        case .Lowest: return self.lowest
        case .Lower: return self.lower
        case .Normal: return self.normal
        }
    }
}

public struct AssetPayload:Codable {
    let assetQuality:AssetQuality
    let modelFiles:[String: String]
    let textureFiles:[String: Texture]
    var mtl:String?

    public func payload( folder: String, resolution: MaterialQuality) -> [String: [URL]] {
        switch self.assetQuality {
        case .FullScene:
            return [
                "model": self.modelFiles.keys.map{Foundation.URL(fileURLWithPath: self.modelFiles[$0]!)},
                "diffuse": [Foundation.URL(fileURLWithPath: self.textureFiles[resolution.id]!.fileName(resolution: resolution))],
                "bump": [Foundation.URL(fileURLWithPath: self.textureFiles[resolution.id]!.fileName(resolution: resolution))],
                "mtl": [Foundation.URL(fileURLWithPath: self.mtl!)]
            ]
        case .ObjectOnly:
            return [
                "model": self.modelFiles.keys.map{Foundation.URL(fileURLWithPath: self.modelFiles[$0]!)}
]
        case .MaterialOnly:
            return [
                "diffuse": [Foundation.URL(fileURLWithPath: self.textureFiles[resolution.id]!.fileName(resolution: resolution))],
                "bump": [Foundation.URL(fileURLWithPath: self.textureFiles[resolution.id]!.fileName(resolution: resolution))],
            ]
        case .Unknown:
            return [:]
        }
    }
}

