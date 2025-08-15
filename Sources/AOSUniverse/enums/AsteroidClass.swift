//
//  AsteroidClass.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 9/6/2025.
//


enum AsteroidClass: String, Codable {
    case ast = "AST"   // General asteroid
    case amo = "AMO"   // Amor asteroids (near-Earth, do not cross Earth's orbit)
    case mca = "MCA"   // Mars-crossing asteroids
    case tjn = "TJN"   // Trojan asteroids (e.g., Jupiter Trojans)
    case com = "COM"   // General comet
    case mba = "MBA"   // Main-belt asteroid
    case imb = "IMB"   // Inner main-belt asteroid
    case apo = "APO"   // Apollo asteroids (Earth-crossing)
    case jfc = "JFC"   // Jupiter-family comet
    case jFc = "JFc"   // (Possible lowercase variant of JFC)
    case omb = "OMB"   // Outer main-belt asteroid
    case ctc = "CTc"   // Centaur/comet transition object
    case cen = "CEN"   // Centaur
    case tno = "TNO"   // Trans-Neptunian object
    case htc = "HTC"   // Halley-type comet
    case etc = "ETc"   // Earth Trojan candidate
    case ate = "ATE"   // Aten asteroids (Earth-crossing with a < 1 AU)

    var description: String {
        switch self {
        case .ast:
            return "General asteroid"
        case .amo:
            return "Amor asteroids (near-Earth, do not cross Earth's orbit)"
        case .mca:
            return "Mars-crossing asteroids"
        case .tjn:
            return "Trojan asteroids (e.g., Jupiter Trojans)"
        case .com:
            return "General comet"
        case .mba:
            return "Main-belt asteroid"
        case .imb:
            return "Inner main-belt asteroid"
        case .apo:
            return "Apollo asteroids (Earth-crossing)"
        case .jfc:
            return "Jupiter-family comet"
        case .jFc:
            return "(Possible lowercase variant of JFC)"
        case .omb:
            return "Outer main-belt asteroid"
        case .ctc:
            return "Centaur/comet transition object"
        case .cen:
            return "Centaur"
        case .tno:
            return "Trans-Neptunian object"
        case .htc:
            return "Halley-type comet"
        case .etc:
            return "Earth Trojan candidate"
        case .ate:
            return "Aten asteroids (Earth-crossing with a < 1 AU)"
        }
    }
}
