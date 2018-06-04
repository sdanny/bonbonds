//
//  ViperOpenModulePromise.swift
//  news
//
//  Created by Daniyar Salakhutdinov on 20.05.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import Foundation

typealias PostLinkActionClosure = () -> Void
typealias ViperModuleLinkClosure = (ViperModuleInput) -> ViperModuleOutput?

class ViperOpenModulePromise: NSObject {
    
    var moduleInput : ViperModuleInput? {
        didSet {
            performLink()
        }
    }
    var postLinkAction : PostLinkActionClosure?
    fileprivate var linkClosure: ViperModuleLinkClosure?
    
    func thenChain(using closure: @escaping ViperModuleLinkClosure) {
        linkClosure = closure
        performLink()
    }
    
    fileprivate func performLink() {
        guard let linkClosure = linkClosure, let input = moduleInput else { return }
        // set output
        input.moduleOutput = linkClosure(input)
        // run post link closure if having
        postLinkAction?()
    }
}
