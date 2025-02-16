//
//  SelectorType.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 16/2/2025.
//


public enum SelectorType:String, Codable, Identifiable, CaseIterable {
case selector
case confirmedExoPlanet
case ticCandidate


public var id:String {
return self.rawValue
}
}
