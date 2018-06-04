import UIKit

/**
 Исходный код и описание алгоритма расположены в файле Sources/Calculation
 */

let input: [Float] = [1.5, 3, 6, 1.5] // inputData(ofCount: Constant.maxInputArrayCount)

let startedAt = Date()
let output = try? calculatePercentage(from: input)
let benchmark = Date().timeIntervalSince(startedAt)
