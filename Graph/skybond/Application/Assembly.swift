//
//  Assembly.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit
import Swinject

class Assembly: ViperModuleAssembly {
    
    let graphModule = GraphModuleAssembly()

    func setup(container: Container) {
        // setup services
        
        // setup submodules
        graphModule.setup(container: container)
    }

}
