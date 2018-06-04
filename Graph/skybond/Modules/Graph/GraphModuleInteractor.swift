//
//  GraphModuleInteractor.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright (c) 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit
import SwiftDate

enum Response<Value> {
    case failure(Error)
    case success(Value)
}

struct Tick {
    let date: Date
    let yield: Float
    let price: Float
}

protocol TickLoader {
    func loadTicks(isin: String, completion: @escaping (Response<[Tick]>) -> Void)
}

protocol PeriodFormatterProtocol {
    func titleForDateBeforeCurrent(subtracting component: Calendar.Component, value: Int) -> String
}

protocol CurrentDateProvider {
    var date: Date { get }
}

class GraphModuleInteractor: GraphModuleInteractorInput {
    
    var loader: TickLoader!
    var formatter: PeriodFormatterProtocol!
    var dateProvider: CurrentDateProvider!
    private var ticks: [Tick] = []
    
    func loadValues(for isin: String, completion: @escaping (Error?) -> Void) {
        loader.loadTicks(isin: isin) { (response) in
            switch response {
            case .failure(let error):
                completion(error)
            case .success(let ticks):
                self.ticks = ticks
                completion(nil)
            }
        }
    }
    
    private func numberOfComponents(in period: Period) -> Int {
        switch period {
        case .week:
            return 7
        case .month:
            return 4
        case .threeMonths:
            return 6
        case .sixMonths:
            return 6
        case .year:
            return 6
        case .twoYears:
            return 6
        }
    }
    
    private func calendarComponentsInComponent(inPeriod period: Period) -> (Calendar.Component, Int) {
        let calendarComponent: Calendar.Component
        let value: Int
        switch period {
        case .week:
            calendarComponent = .day
            value = 1
        case .month:
            calendarComponent = .weekOfYear
            value = 1
        case .threeMonths:
            calendarComponent = .weekOfYear
            value = 2
        case .sixMonths:
            calendarComponent = .month
            value = 1
        case .year:
            calendarComponent = .month
            value = 2
        case .twoYears:
            calendarComponent = .month
            value = 4
        }
        return (calendarComponent, value)
    }
    
    func nearestValues(for period: Period, isYield: Bool) -> [Float] {
        let components = numberOfComponents(in: period)
        let value = calendarComponentsInComponent(inPeriod: period)
        let current = dateProvider.date
        var results = [Float]()
        for component in 0..<components {
            let start = current.add(components: [value.0 : (component * value.1) - components])
            let end = current.add(components: [value.0 : ((component + 1) * value.1) - components])
            let ticks = self.ticks.filter { $0.date.isBetween(date: start, and: end, orEqual: true) }
            if ticks.isEmpty {
                if let last = results.last {
                    results.append(last)
                } else {
                    results.append(0)
                }
            } else {
                let values: [Float]
                if isYield {
                    values = ticks.map { $0.yield }
                } else {
                    values = ticks.map { $0.price }
                }
                let sum = values.reduce(0, +)
                results.append(sum / Float(ticks.count))
            }
        }
        return results
    }
    
    func titleForComponent(_ component: Int, in period: Period) -> String {
        let value = calendarComponentsInComponent(inPeriod: period)
        let count = numberOfComponents(in: period)
        return formatter.titleForDateBeforeCurrent(subtracting: value.0, value: (count - component - 1) * value.1)
    }
}
