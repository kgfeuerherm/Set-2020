//
//  ViewController.swift
//  Set 2020
//
//  Created by Karljürgen Feuerherm on 2020-04-12.
//  Copyright © 2020 Karljürgen Feuerherm. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet var cardButtons: [ UIButton ]!
    {
        didSet
        {
            cardButtons.forEach
            {
                // Round the cards.
                $0.layer.cornerRadius   =   8

                // Set to a preferred font; 25pt works nicely.
                $0.titleLabel?.font = UIFont( name: "Body", size: 25.0 )
            }
        }
    }
    
    @IBAction func selectCard( _ sender: UIButton )
    {
        // Determine which card was selected and act on it.
        game.selectCard( chosenSlot: cardButtons.firstIndex( of: sender )! )
        
        updateViewFromModel()
    }
    
    // Need this outlet in order to be able to enable/disable dealing
    // as required.
    @IBOutlet weak var dealCardsButton: UIButton!
    
    @IBAction func dealCards( _ sender: UIButton )
    {
        // Attempt to deal cards as requested.
        game.dealCards()
 
        updateViewFromModel()
    }
    
    @IBAction func newGame( _ sender: UIButton )
    {
        game = SetGame( numberOfCardSlots: cardButtons.count )
        
        // Reshuffle the buttons.
        cardButtons.shuffle()
        
        updateViewFromModel()
    }
    
    private lazy var game = SetGame( numberOfCardSlots: cardButtons.count )
    
    // Refresh the view in light of the current state of the game.
    func updateViewFromModel()
    {
        // Update the score.
        scoreLabel.text = "Score: \( game.score )"
        
        // Process each button in turn.
        for index in 0 ..< cardButtons.count
        {
            if game.slots[ index ].card ==  nil
            {
                // Unoccupied card slots may or may not have had cards in the
                // last round, so ensure that those slots are vacated by
                // resetting the background and foreground colours as well as
                // removing a potential border.
                cardButtons[ index ].backgroundColor    =    #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                
                // It seems that a simple '.setTitle' will not remove something
                // previously displayed using NSAttributedString, so use the
                // same feature here.
                let attributes  :
                    [ NSAttributedString.Key : Any ]    =
                    [ .foregroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ]
                
                cardButtons[ index ].setAttributedTitle( NSAttributedString(
                    string      :   String( "" ),
                    attributes  :   attributes ), for: UIControl.State.normal )
                
                cardButtons[ index ].layer.borderWidth  =   0.0
            }
            else
            {
                // Occupied slot; set the background for the card.
                cardButtons[ index ].backgroundColor    =   #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

                // Set the border (selection colour), if any.
                if let selection = game.slots[ index ].selection
                {
                    // Set border width and colour.
                    cardButtons[ index ].layer.borderWidth  =   borderWidth
                    
                    switch selection
                    {
                    case .initial   :   cardButtons[ index ].layer.borderColor  =   initialSelectionColour
                    case .match     :   cardButtons[ index ].layer.borderColor  =   matchSelectionColour
                    case .noMatch   :   cardButtons[ index ].layer.borderColor  =   noMatchSelectionColour
                    }
                }
                else
                {
                    // Remove the border.
                    cardButtons[ index ].layer.borderWidth  =   0.0
                }
                
                // Extract the current card for simplicity of reference.
                let currentCard = game.slots[ index ].card!
                
                // Set up the text attributes.
                //     The colour will be altered below if the card is striped.
                var attributes  :   [ NSAttributedString.Key : Any ]    =
                    [ .strokeColor : currentCard.colour.rawValue ]
                        
                switch currentCard.shading
                {
                case .open      :   attributes[ .strokeWidth     ]      =   5.0     // Positive: outline.
                case .solid     :   attributes[ .strokeWidth     ]      =   -1.0    // Negative: fill.
                                    attributes[ .foregroundColor ]      =   currentCard.colour.rawValue
                case .striped   :   attributes[ .foregroundColor ]      =
                    currentCard.colour.rawValue.withAlphaComponent( 0.25 )
                }

                // Set the text along with the attributes.
                cardButtons[ index ].setAttributedTitle( NSAttributedString(
                    string      :   String( repeating   :   currentCard.shape.rawValue,
                                            count       :   currentCard.number.rawValue ),
                    attributes  :   attributes ), for: UIControl.State.normal )
            }
        }
        
        // Finally, enable or disable the button for dealing cards
        // depending on the state of the game.
        dealCardsButton.isEnabled = game.dealingPossible
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Randomize the button order. This is not required, but
        // makes for a more pleasing user experience.
        cardButtons.shuffle()
        
        // Set up the intial view.
        updateViewFromModel()
    }
}
