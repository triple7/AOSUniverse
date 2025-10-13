//
//  SelectorType.swift
//  AOSUniverse
//
//  Created by Yuma decaux on 16/2/2025.
//


#if os(iOS)
import UIKit
public typealias Color = UIColor
#elseif os(macOS)
import AppKit
public typealias Color = NSColor
#endif

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

    private func colorFromCG(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> Color {
        // let cg = CGColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: 1.0)
        // return Color(cgColor: cg)!
        return Color(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }

    public var color:Color {
        switch self {
        case .exo_question:            return colorFromCG(125, 217,  87)  // light fresh green
        case .exo:                     return colorFromCG( 30, 173, 111)  // deeper teal-green

        case .sat1_polygon:            return colorFromCG(255, 169,  77)  // soft orange
        case .sat2_square:             return colorFromCG(255, 146,  43)  // richer orange
        case .sat3_polygon_lines:      return colorFromCG(255, 127,  10)  // strong orange

        case .selector:                return colorFromCG(255,  95,   0)  // bright saturated orange

        case .simple_circle:           return colorFromCG( 77, 163, 255)  // distinct blue (free choice)

        case .star_6_cross_4lines:     return colorFromCG(224,  49,  49)  // red
        case .star4_5lines_circle:     return colorFromCG(214,  51, 108)  // magenta-pink
        case .star4lines_circle:       return colorFromCG(112,  72, 232)  // purple
        }
    }

}
