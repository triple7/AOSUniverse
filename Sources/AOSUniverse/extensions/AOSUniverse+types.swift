//
//  File.swift
//  
//
//  Created by Yuma decaux on 17/10/2023.
//

import Foundation


struct AOSMb:Codable {
    let type:AOSType
    let id:Int
}

struct AOSStar:Codable {
    
    let type:AOSType
    let starCategory:Int
    let spectral:String // spectral category BUG should be enum
    let distanceToEarth:Float // per object as scaling occurs in 3D     let proper: String // proper star name
    var hip: Int? // for exoplanet query
    var hd:Int? // for exoplanet query
}

struct AOSConstellation:Codable {
    let type:AOSType
    let constellationDistance:Float
    let constellationLYDistance:Float
    let constLineIndex:Int
    let constShort:String
    
    
}
