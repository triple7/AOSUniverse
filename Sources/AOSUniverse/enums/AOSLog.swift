//
//  AOSLog.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 6/10/2025.
//

import ArgumentParser

public enum AOSLog:String, Codable, CaseIterable, ExpressibleByArgument {
// user patterns
     case StateChanged
    case ObjectSelect
    case SetLocation
    
    // Network API calls
    case NoSuchObject
    case RequestError
    case DataCorrupted
    case Ok
}

