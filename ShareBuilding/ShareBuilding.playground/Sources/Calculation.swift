import Foundation

/**
 Сложность работы алгоритма и объем занимаемой памяти линейны - O(n)
 Учитывая примерные вычислительные свойства процессоров, встраеваемых в популярные серии iPhone (в среднем 1 Ггц), размер входного массива должен ограничиваться числом, близким к 1.5 миллионам
 Сам алгоритм прост в своем исполнении. Сперва находится сумма элементов, затем для каждого из них высчитывается доля в процентах и создается строка необходимого формата
 */

public struct Constant {
    public static let maxInputArrayCount = 1_500_000
}

public enum PortionsCalculationError: Error {
    case inputArrayIsTooBig
}

public func calculatePercentage(from portions: [Float]) throws -> [String] {
    guard portions.count <= Constant.maxInputArrayCount else {
        throw PortionsCalculationError.inputArrayIsTooBig
    }
    let sum = portions.reduce(0, +)
    var results = [String]()
    for portion in portions {
        let percentage = (portion / sum) * 100
        let string = String(format: "%.3f", percentage)
        results.append(string)
    }
    return results
}
