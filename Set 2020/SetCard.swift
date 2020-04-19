//
//  SetCard.swift
//  Set 2020
//
//  Created by Karljürgen Feuerherm on 2020-04-16.
//  Copyright © 2020 Karljürgen Feuerherm. All rights reserved.
//

import Foundation
import UIKit

typealias SetCard  =
(
    colour  :   Colour  ,
    number  :   Number  ,
    shading :   Shading ,
    shape   :   Shape
)

enum Colour     :   CaseIterable
{
    case red
    case green
    case purple
}

// This extension was found at https://stackoverflow.com/questions/49192068/how-to-use-uicolor-as-rawvalue-of-an-enum-type-in-swift/49192862#49192862
extension Colour    :   RawRepresentable
{
    typealias RawValue                  =   UIColor

    var rawValue    :   RawValue
    {
        switch self
        {
        case .red   :   return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case .green :   return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .purple:   return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        }
    }

    init?( rawValue: RawValue )
    {
        switch rawValue
        {
        case #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)     :   self    =   .red
        case #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)     :   self    =   .green
        case #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)     :   self    =   .purple
        // The switch must be exhaustive, and we cannot guarantee
        // that someone else wouldn't try to initialize a
        // Colour incorrectly.
        default     :   return nil
        }
    }
}

enum Number         :   Int, CaseIterable
{
    case one                            =   1
    case two                            =   2
    case three                          =   3
}

enum Shading    :   CaseIterable
{
    case open
    case solid
    case striped
}

enum Shape      :   String, CaseIterable
{
    case diamond                        =   "▲"
    case oval                           =   "●"
    case tilde                          =   "■"
}

