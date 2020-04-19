//
//  Path.swift
//  Set 2020
//
//  Created by Karljürgen Feuerherm on 2020-04-17.
//  Copyright © 2020 Karljürgen Feuerherm. All rights reserved.
//

import Foundation
import UIKit

class DemoView: UIView
{
    func triangle()
    {
        let path = UIBezierPath()
        path.move( to: CGPoint( x: 80, y: 50 ) )
        path.addLine( to: CGPoint( x: 140, y: 150 ) )
        path.addLine( to: CGPoint( x: 10, y: 150 ) )
        path.close()
        
        UIColor.green.setFill()
        UIColor.red.setStroke()
        path.lineWidth = 3.0
    }
    
//    func oval()
//    {
//        let oval = UIBezierPath( ovalIn: CGRect )
//    }
}

