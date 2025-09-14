//
//  SelectorType.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 16/2/2025.
//


public enum SelectorType:String, Codable, Identifiable, CaseIterable {
    case exo_question
    case exo
    case sat1_polygon
    case sat2_square
    case sat3_polygon_lines
    case selector
    case simple_circle
    case star_6_cross_4lines
    case star4_5lines_circle
    case star4lines_circle

public var id:String {
return self.rawValue
}
    
    
    public var idx:Int {
        switch self {
        case .exo_question: return 0
        case .exo: return 1
        case .sat1_polygon: return 2
        case .sat2_square: return 3
        case .sat3_polygon_lines: return 4
        case .selector: return 5
        case .simple_circle: return 6
        case .star_6_cross_4lines: return 7
        case .star4_5lines_circle: return 8
        case .star4lines_circle: return 9
        }
    }
}
