//
//  ModuleTransitionHandler.swift
//  news
//
//  Created by Daniyar Salakhutdinov on 20.05.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit

typealias ViperModuleClosure = () -> Void

struct ModalPresentation {
    let transitionStyle: UIModalTransitionStyle
    let presentationStyle: UIModalPresentationStyle
}

/// Based on Rambler Viper architecture
protocol ViperModuleTransitionHandler : class {
    
    var moduleInput: ViperModuleInput? { get set }
    
    /** 
     Performs segue without any actions, useful for unwind segues
     
     - parameter identifier: segue identifier
     */
    func performSegue(with identifier: String)
    
    /**
     Opens module using segue
     
     - parameter identifier: segue id
     
     - returns: viper module promise object
     */
    func openModule(usingSegue identifier: String) -> ViperOpenModulePromise
    
    /**
     Opens module using factory and navigation controller
     
     - parameter factory: factory of a destination controller
     - parameter animated: flag
     
     - returns: viper module promise object
    */
    func pushModule(factory: ViperModuleFactoryProtocol, animated: Bool) -> ViperOpenModulePromise
    
    /** 
     Closes current module
     
     - parameter animated: flag
     */
    func closeModule(animated: Bool)
}
