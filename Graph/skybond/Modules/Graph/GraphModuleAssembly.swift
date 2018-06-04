//
//  GraphModuleAssembly.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright (c) 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

class GraphModuleAssembly: ViperModuleAssembly {
    
    func setup(container: Container) {
        container.storyboardInitCompleted(GraphModuleView.self) { resolver, view in
            let interactor = GraphModuleInteractor()
            interactor.loader = TickGenerator()
            interactor.formatter = PeriodFormatter()
            interactor.dateProvider = Provider()
            
            let presenter = GraphModulePresenter()
            presenter.interactor = interactor
            presenter.view = view
            
            view.output = presenter
        }
    }
}

class Provider: CurrentDateProvider {
    var date: Date {
        return Date()
    }
}
