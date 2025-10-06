//
//  GaiaBin.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 6/10/2025.
//

import Foundation

public enum GaiaBin: String, Codable, Identifiable, CaseIterable {
    case Default
    case Medium
    case Large
    case XLarge

    public var id:String {
        return self.rawValue
    }
}
