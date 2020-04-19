//
//  Set.swift
//  Set 2020
//
//  Created by Karljürgen Feuerherm on 2020-04-12.
//  Copyright © 2020 Karljürgen Feuerherm. All rights reserved.
//

import Foundation

struct SetGame
{
    //****************************************************
    // Properties available to the outside world follow. *
    //****************************************************
    
    // Current game score.
    private( set ) var score            : Int
    
    // Flag indicating whether or not the deck has been exhausted.
    var deckIsEmpty                     : Bool
    {
        return setDeck.count   ==  0
    }
    
    // Current state of the available slots.
    private( set ) var slots                        =   [ CardSlot ]()
    
    //****************************************************
    // Properties for strictly internal usage follow.    *
    //****************************************************
    
    // Number of slots available; passed at initialization time
    // and based on the architecture of the view where cards
    // will be displayed.
    private var slotCount               : Int
    
    // Deck of unplayed cards.
    private var setDeck                             =   [ SetCard ]()
    
    // Number of cards in slots.
    private var numberOfCardsInSlots    : Int
    {
        // Generate a list of indices into the current spread of
        // existing cards, then count them.
        return slots.indices.filter { slots[ $0 ].card != nil }.count
    }
    
    // Indices of currently selected cards, if any.
    private var indicesOfSelectedCards  : [ Int ]
    {
        // Obtain a list of indices of selected cards. Note that
        // vacant slots cannot be selected, so no separate test is
        // required for that.
        return slots.indices.filter { slots[ $0 ].selection != nil }
    }
    
    // Array of currently selected cards.
    private var selectedCards           : [ SetCard ]
    {
        return indicesOfSelectedCards.map { slots[ $0 ].card! }
    }
    
    // Derived from 'indicesOfSelectedCards'.
    private var numberOfSelectedCards   :   Int
    {
        return indicesOfSelectedCards.count
    }
    
    // Derived from the previous item.
    private var threeCardSetExists      :   Bool
    {
        return numberOfSelectedCards    ==  3
    }
    
    // Derived from the two previous items.
    private var matchedSetExists        :   Bool
    {
        // True if we have a three card set and any card in the set
        // is set to '.match'---they are all set the same way.
        return threeCardSetExists &&
            slots[ indicesOfSelectedCards[ 0 ] ].selection!
                                        == .match
    }
    
    // Flag indicating whether or not we have vacant slots.
    private var vacanciesExist          :   Bool
    {
        return numberOfCardsInSlots     <   slotCount
    }

    // Flag indicating whether or not it is possible to deal
    // cards from the deck; this requires that cards be available
    // and that there be slots to place them into.
    var dealingPossible                 : Bool
    {
        return !deckIsEmpty &&
            ( vacanciesExist || matchedSetExists )
    }
    
    // Attempt to deal three more cards; if this is not possible,
    // do nothing.
    mutating func dealCards()
    {
        // Make sure we have cards in the deck.
        if deckIsEmpty
        {
            return
        }
        
        // When there is a matched set, deal over those cards.
        if matchedSetExists
        {
            // No problem.
            for index in indicesOfSelectedCards
            {
                // Deal a card into each slot and mark it as unselected.
                slots[ index ]  =   ( setDeck.remove( at: 0 ), nil )
            }
            // Done!
            return
        }

        // No matched set, so check for available slots.
        if !vacanciesExist
        {
            // Insufficiently many slots available.
            return
        }

        // We have slots available; obtain the first 3.
        for _ in 1 ... 3
        {
            // Get the first available slot.
            let index       =   slots.firstIndex(
                                    where: { $0.card == nil } )
            
            // Deal a card into that slot and mark it as unselected.
            slots[ index! ] =   ( setDeck.remove( at: 0 ), nil )
        }
    }
    
    // Attempt to select a card. Assuming that a valid slot has been
    // chosen, there are a number of possibilities:
    //  1. The selection was made within a matched or unmatched set.
    //      a. In the case of a matched set, replace the set with new
    //         cards if possible and vacate the slots otherwise. No
    //         cards are selected either way.
    //      b. In the case of an unmatched set, deselect all the cards
    //         and then set the chosen card to initial selection.
    //  2. A previously selected card was selected, so deselect it and
    //     apply a penalty.
    //  3. A completely fresh card has been chosen, but there is an
    //     existing set. We must:
    //      a. Replace a matched set with new cards if possible and
    //         vacate the slots otherwise.
    //      b. Deselect an unmatched set.
    //      c. Initially select the chosen card.
    //  4. A fresh card has been chosen and there is no existing set.
    //      a. Set the card as initially selected.
    //      b. Test for a matched set.
    //          i. In the event of a matched set, set the selections to
    //             matched and apply the match bonus to the score.
    //         ii. In the event of a failure to match, set the selections
    //             to unmatched and apply the mismatch penalty to the score.
    mutating func selectCard( chosenSlot : Int )
    {
        // Attempt to deal cards onto a matched set. When no cards are in fact
        // dealt, vacate the slots in question.
        func dealOrVacate()
        {
            if deckIsEmpty
            {
                for index in indicesOfSelectedCards
                {
                    slots[ index ].card         =   nil
                    slots[ index ].selection    =   nil
                }
            }
            else
            {
                // This function will deal over a matched set as its first
                // preference, which is what we want.
                dealCards()
            }
        }

        if slots[ chosenSlot ].card == nil
        {
            // Location is vacant; do nothing.
            return
        }

        if threeCardSetExists, indicesOfSelectedCards.contains( chosenSlot )
        {
            // Case 1: a selection was made within an existing set of three cards.
            if slots[ chosenSlot ].selection!   == .match
            {
                // Case 1 a): matched set; replace the cards if possible and
                // vacate the slots otherwise. In either case, no cards remain
                // selected.
                dealOrVacate()
            }
            else
            {
                // Case 1 b): unmatched set; deselect the existing set and
                // then initially set the chosen card.
                for index in indicesOfSelectedCards
                {
                    slots[ index ].selection    =   nil
                }
                slots[ chosenSlot ].selection   =   .initial
            }
        }
        else
        {
            if slots[ chosenSlot ].selection    !=  nil
            {
                // Case 2: a previously selected card is to be deselected
                // and a penalty is to be applied.
                slots[ chosenSlot ].selection   =   nil
                score                           -=  deselectionPenalty
            }
            else
            {
                // We have a fresh card altogether.
                if threeCardSetExists
                {
                    // Case 3: we're dealing with a completely fresh card outside
                    // an existing set.
                    if matchedSetExists
                    {
                        // Case 3 a): attempt to replace a matched set and
                        // vacate the slots otherwise.
                        dealOrVacate()
                    }
                    else
                    {
                        // Case 3 b): deselect an unmatched set.
                        for index in indicesOfSelectedCards
                        {
                            slots[ index ].selection    =   nil
                        }
                    }
                    // Case 3 c): Initially select the chosen card.
                    slots[ chosenSlot ].selection   =   .initial
                }
                else
                {
                    // Case 4: we have a fresh card and no pre-existing set.
                    // Case 4 a): set the chosen card as initially selected.
                    slots[ chosenSlot ].selection   =   .initial
                    if threeCardSetExists
                    {
                        // Case 4 b): test the set for a match.
                        if potentialSetMatches()
                        {
                            // Case 4 b) i): we have a new matched set; mark it
                            // and apply the match bonus to the score.
                            for index in indicesOfSelectedCards
                            {
                                slots[ index ].selection    =   .match
                            }
                            score   +=  matchBonus
                        }
                        else
                        {
                            // Case 4 b) ii): we have a failed match; mark the
                            // set and apply the mismatch penalty to the score.
                            for index in indicesOfSelectedCards
                            {
                                slots[ index ].selection    =   .noMatch
                            }
                            score   -=  noMatchPenalty
                        }
                    }
                }
            }
        }
    }
    
    // Check to see whether a selected set of cards qualifies as a
    // match.
    func potentialSetMatches() -> Bool
    {
        // For each attribute, all cards must share the characteristic or all
        // must be different.
        
        // Test each attribute for conformity to the rules of matching a set.
        //     First, extract the attribute from the cards, then condense the resulting
        // array to a set. When the set contains only one element, the cards are identical
        // with regards to that attribute, and when it contains three elements, all cards
        // are diffent; in either case, we have a potential match. Otherwise, the test
        // fails and the cards do not form a matched set.
        let matchSet = [ 1, 3 ]
        
        if !matchSet.contains( Set( selectedCards.map { $0.colour } ).count )
        {
            return false
        }
        
        if !matchSet.contains( Set( selectedCards.map { $0.number } ).count )
        {
            return false
        }
        
        if !matchSet.contains( Set( selectedCards.map { $0.shading } ).count )
        {
            return false
        }
        
        if !matchSet.contains( Set( selectedCards.map { $0.shape } ).count )
        {
            return false
        }

        // All tests were successful; match!
        return true
    }

    // The initializer is passed the number of buttons in the view so that
    // the model can decide whether or not dealing more cards is an option.
    init( numberOfCardSlots :   Int )
    {
        // Keep the number of available card slots for future reference.
        slotCount = numberOfCardSlots
        
        // Initialize the score.
        score   =   0
        
        // Set up a deck with one of each type of card, initially.
        for colour in Colour.allCases
        {
            for number in Number.allCases
            {
                for shading in Shading.allCases
                {
                    for shape in Shape.allCases
                    {
                        setDeck.append( ( colour, number, shading, shape ) )
                    }
                }
            }
        }
        
        // Randomize the order of cards. This is likely computationally
        // preferable to choosing a random card each time one is drawn.
        setDeck.shuffle()
        
        // Initialize the spread, based on the number of slots available
        // to display cards.
        slots = Array( repeating    :   ( nil, nil ),
                               count        :   numberOfCardSlots )
        
        // Deal 12 cards (4 sets of 3).
        for _ in 1 ... 4
        {
            dealCards()
        }
    }
}
