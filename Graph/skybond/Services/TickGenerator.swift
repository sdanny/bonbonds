//
//  TickGenerator.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit
import SwiftDate

class TickGenerator: TickLoader {
    
    
    func loadTicks(isin: String, completion: @escaping (Response<[Tick]>) -> Void) {
        var yield: Float = .random(upTo: 16) + 0.1
        var price: Float = .random(upTo: 16) + 0.1
        DispatchQueue.global(qos: .utility).async {
            var ticks = [Tick]()
            var date = Date().add(components: [.year : -2])
            while date.compare(to: Date(), granularity: .day) != .orderedDescending {
                yield += .randomStep
                price += .randomStep
                let tick = Tick(date: date, yield: abs(yield), price: abs(price))
                ticks.append(tick)
                date = date.add(components: [.day : 1])
            }
            DispatchQueue.main.async {
                completion(.success(ticks))
            }
        }
    }
}

fileprivate extension Float {
    
    static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    static func random(upTo value: Float) -> Float {
        return .random * value
    }
    
    static var randomStep: Float {
        let multiplier: Float = Float.random > 0.5 ? 1 : -1
        return .random * multiplier
    }
}
