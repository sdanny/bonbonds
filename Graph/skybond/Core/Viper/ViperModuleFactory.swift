//
//  ViperModuleFactory.swift
//  news
//
//  Created by Daniyar Salakhutdinov on 20.05.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit

/// Based on Rambler Viper architecture
protocol ViperModuleFactoryProtocol {
    
    func instantiateModuleTransitionHandler() -> ViperModuleTransitionHandler
}

class ViperModuleFactory: NSObject, ViperModuleFactoryProtocol {
    
    let storyboard: UIStoryboard
    let restorationId: String
    
    init(storyboard: UIStoryboard, restorationId: String) {
        self.storyboard = storyboard
        self.restorationId = restorationId
        super.init()
    }
    
    // MARK: Viper module factory method
    func instantiateModuleTransitionHandler() -> ViperModuleTransitionHandler {
        let controller = storyboard.instantiateViewController(withIdentifier: restorationId)
        controller.loadViewIfNeeded()
        if let navigationController = controller as? UINavigationController {
            navigationController.topViewController?.loadViewIfNeeded()
        }
        return controller as ViperModuleTransitionHandler
    }
}
