//
//  GraphModuleInteractorSpec.swift
//  skybondTests
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import XCTest
import Quick
import Nimble
import SwiftDate
@testable import skybond

class GraphModuleInteractorSpec: QuickSpec {
    
    private class FakeLoader: TickLoader {
        
        var ticks: [Tick] = []
        var didLoad: (() -> Void)?
        
        func loadTicks(isin: String, completion: @escaping (Response<[Tick]>) -> Void) {
            DispatchQueue.main.async {
                completion(.success(self.ticks))
                self.didLoad?()
            }
        }
    }
    
    private class FakeFormatter: PeriodFormatterProtocol {
        
        var component: Calendar.Component?
        var value: Int?
        
        func titleForDateBeforeCurrent(subtracting component: Calendar.Component, value: Int) -> String {
            self.component = component
            self.value = value
            return ""
        }
        
    }
    
    private class FakeProvider: CurrentDateProvider {
        var date = Date()
    }
    
    override func spec() {
        super.spec()
        // dependencies
        let loader = FakeLoader()
        let formatter = FakeFormatter()
        let provider = FakeProvider()
        // object
        var interactor: GraphModuleInteractor!
        
        beforeEach {
            loader.ticks = []
            loader.didLoad = nil
            formatter.component = nil
            formatter.value = nil
            provider.date = Date()
            // create interactor
            interactor = GraphModuleInteractor()
            interactor.loader = loader
            interactor.formatter = formatter
            interactor.dateProvider = provider
        }
        
        describe("Graph module interactor") {
            it("calculates components for title in week period") {
                _ = interactor.titleForComponent(0, in: .week)
                expect(formatter.component).to(equal(.day))
                expect(formatter.value).to(equal(6))
            }
            it("calculates components for title in year period") {
                _ = interactor.titleForComponent(5, in: .year)
                expect(formatter.component).to(equal(.month))
                expect(formatter.value).to(equal(0))
            }
            it("calculates values grouped by period") {
                // configure loader
                let date = Date()
                let tick0 = Tick(date: date.add(components: [.day: -1]), yield: 3, price: 3)
                let tick1 = Tick(date: date.add(components: [.day: -1]), yield: 5, price: 5)
                let tick2 = Tick(date: date.add(components: [.day: -2]), yield: 19, price: 11)
                loader.ticks = [tick0, tick1, tick2]
                var value: Float?
                interactor.loadValues(for: "some", completion: { (_) in
                    let values = interactor.nearestValues(for: .week, isYield: true)
                    value = values.last
                })
                expect(value).toEventually(beCloseTo(4))
            }
        }
    }
}
