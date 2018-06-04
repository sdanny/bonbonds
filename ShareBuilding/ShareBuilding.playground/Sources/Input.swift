import Foundation

/**
 Генерация входных данных любого размера
 */

public func inputData(ofCount count: Int) -> [Float] {
    var input: [Float] = []
    for _ in 0..<count {
        let item = Float.random(upTo: 6)
        input.append(item)
    }
    return input
}

extension Float {
    
    static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    static func random(upTo max: Float) -> Float {
        return .random * max
    }
}
