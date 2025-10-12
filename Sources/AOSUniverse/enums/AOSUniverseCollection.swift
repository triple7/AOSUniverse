//
//  AOSUniverseCollection.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 12/10/2025.
//

import ArgumentParser

public enum AOSUniverseCollection: String, CaseIterable, Codable, ExpressibleByArgument {
    case constellationNodes
    case skyMap
    case blackHoles
    case solarSystem
    case satellites
}
