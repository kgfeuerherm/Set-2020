//
//  CardSlot.swift
//  Set 2020
//
//  Created by Karljürgen Feuerherm on 2020-04-18.
//  Copyright © 2020 Karljürgen Feuerherm. All rights reserved.
//

import Foundation

// A given slot in the spread either contains a card or not, and
// when it does, the card has either been selected by the player
// or not.
typealias   CardSlot            =
(
    card        :   SetCard? ,
    selection   :   Selection?  // Defined below.
)

enum Selection
{
    case initial                // User has just chosen the card.
    case match                  // Card belongs to a matched set.
    case noMatch                // Card belongs to an unmatched set.
}
