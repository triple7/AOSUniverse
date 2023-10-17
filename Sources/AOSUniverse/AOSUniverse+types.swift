//
//  File.swift
//  
//
//  Created by Yuma decaux on 17/10/2023.
//

import Foundation
import SceneKit

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
    public var distanceToEarth:Float
    
    
    //Mark: Initialiser for earth sats and Asteroids
    public init(_ name: String, _ id: Int, _ type: AOSType){
        self.id = id
        self.name = name
        self.type = type
        if type == .Asteroid {
            self.parent = "SolarSystem"
        } else if type == .EarthSat {
            self.parent = "Earth"
        } else {
            self.parent = "SolarSystem"
        }
        self.coordinates = [SCNVector3]()
        self.distanceToEarth = 0.0
    }
    
}

extension AOSBody:Equatable{
public static     func ==(lhs: AOSBody, rhs: AOSBody)->Bool{
        return lhs.id == rhs.id
    }

    
}

public struct AOSMb:Codable {
    public let type:AOSType
    public let id:Int
    public let distanceToEarth:Float // per object as scaling occurs
    
    public init( _ type: AOSType, _ id: Int, _ distanceToEarth: Float) {
        self.type = type
        self.id = id
        self.distanceToEarth = distanceToEarth
    }
}

public struct AOSStar:Codable {
    
    public let type:AOSType
    public let id:Int
    public let starCategory:Int
    public let spectral:String // spectral category BUG should be enum
    public let distanceToEarth:Float // per object as scaling occurs in 3D space
    public let proper: String // proper star name
    public var hip: Int? // for exoplanet query
    public var hd:Int? // for exoplanet query
    
    public init(_ type: AOSType, _ id: Int, _ hd: Int?, _ hip: Int?, _ proper: String, _ starCategory: Int, _ spectral: String, _ distanceToEarth: Float) {
        self.type = type
        self.id = id
        self.hd = hd
        self.hip = hip
        self.proper = proper
        self.starCategory = starCategory
        self.spectral = spectral
        self.distanceToEarth = distanceToEarth
    }
        
}

public struct AOSConstellation:Codable {
    public let type:AOSType
    public let constellationDistance:Float
    public let constellationLYDistance:Float
    public let constLineIndex:Int
    public let constShort:String
    
    
}

public struct AOSBlackHole:Codable {
    public let type:AOSType
    public let distanceToEarth:Float
    
    public init( _ type: AOSType, _ distanceToEarth: Float) {
        self.type = type
        self.distanceToEarth = distanceToEarth
    }
}

