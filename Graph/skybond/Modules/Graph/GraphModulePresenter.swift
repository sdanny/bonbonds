//
//  GraphModulePresenter.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright (c) 2018 Daniyar Salakhutdinov. All rights reserved.
//
//

import UIKit

struct GraphModel {
    let title: String
    let value: Float
}

protocol GraphModuleViewInput: class {
    func reloadGraph(models: [GraphModel])
}

protocol GraphModuleInteractorInput {
    func loadValues(for isin: String, completion: @escaping (Error?) -> Void)
    
    func nearestValues(for period: Period, isYield: Bool) -> [Float]
    func titleForComponent(_ component: Int, in period: Period) -> String
}

enum Period {
    case week
    case month
    case threeMonths
    case sixMonths
    case year
    case twoYears
}

class GraphModulePresenter: GraphModuleViewOutput {
    
    weak var view: GraphModuleViewInput?
    var interactor: GraphModuleInteractorInput!
    weak var moduleOutput: ViperModuleOutput?
    
    private var period: Period = .week
    private var isYield = true
    
    // MARK: view output methods
    func viewWillAppear() {
        interactor.loadValues(for: "isin") { [weak self] (error) in
            guard let `self` = self else { return }
            if let error = error {
                // present error (maybe someday)
            } else {
                self.reloadGraph()
            }
        }
    }
    
    private func reloadGraph() {
        var models = [GraphModel]()
        let values = self.interactor.nearestValues(for: self.period, isYield: self.isYield)
        for index in 0..<values.count {
            let title = self.interactor.titleForComponent(index, in: self.period)
            let value = values[index]
            let model = GraphModel(title: title, value: value)
            models.append(model)
        }
        self.view?.reloadGraph(models: models)
    }
    
    func didSelectYield() {
        isYield = true
        reloadGraph()
    }
    
    func didSelectPrice() {
        isYield = false
        reloadGraph()
    }
    
    func didChangePeriod(to value: Period) {
        self.period = value
        reloadGraph()
    }
    
}
