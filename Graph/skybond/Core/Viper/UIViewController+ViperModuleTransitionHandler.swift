//
//  UIViewController+ViperModuleTransitionHandler.swift
//  news
//
//  Created by Daniyar Salakhutdinov on 20.05.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit

extension UIViewController: SelfAware, ViperModuleTransitionHandler {
    
    // MARK: method swizzling
    class func awake() {
        // check isn't a subclass
        guard self === UIViewController.self else { return }
        // swizzle method
        let oSelector = #selector(prepare(for:sender:))
        let sSelector = #selector(swizzledPrepare(for:sender:))
        let original = class_getInstanceMethod(self, oSelector)
        let swizzled = class_getInstanceMethod(self, sSelector)
        let didAddMethod = class_addMethod(self, oSelector, method_getImplementation(swizzled!), method_getTypeEncoding(swizzled!))
        if didAddMethod {
            class_replaceMethod(self, sSelector, method_getImplementation(original!), method_getTypeEncoding(original!))
        } else {
            method_exchangeImplementations(original!, swizzled!)
        }
    }
    
    @objc fileprivate func swizzledPrepare(for segue: UIStoryboardSegue, sender: Any?) {
        // call original method
        swizzledPrepare(for: segue, sender: sender)
        // check if not a subclass
        guard let promise = sender as? ViperOpenModulePromise else { return }
        // get destination controller
        let destination: UIViewController?
        if let navigation = segue.destination as? UINavigationController { // in case they push navigation controller
            destination = navigation.topViewController
        } else { // push single controller
            destination = segue.destination
        }
        // get module input
        let moduleInput: ViperModuleInput?
        if let transition = destination {
            moduleInput = transition.moduleInput
        } else {
            moduleInput = nil
        }
        //
        destination?.loadViewIfNeeded()
        //
        promise.moduleInput = moduleInput
    }
    
    // MARK: transition handler
    private struct AssociatedKey {
        static var ModuleInputKeyName = "viper_ModuleInputKeyName"
    }
    
    var moduleInput: ViperModuleInput? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.ModuleInputKeyName) as? ViperModuleInput
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.ModuleInputKeyName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func performSegue(with identifier: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: identifier, sender: nil)
        }
    }
    
    func openModule(usingSegue identifier: String) -> ViperOpenModulePromise {
        let promise = ViperOpenModulePromise()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: identifier, sender: promise)
        }
        return promise
    }
    
    func pushModule(factory: ViperModuleFactoryProtocol, animated: Bool) -> ViperOpenModulePromise {
        let promise = ViperOpenModulePromise()
        let destinationHandler = factory.instantiateModuleTransitionHandler()
        promise.moduleInput = destinationHandler.moduleInput
        promise.postLinkAction = {
            let destination = destinationHandler as! UIViewController
            self.navigationController?.pushViewController(destination, animated: animated)
        }
        return promise
    }
    
    func closeModule(animated: Bool) {
        // dismiss from parent view/viewcontroller
        if let navigation = parent as? UINavigationController {
            if navigation.viewControllers.first === self {
                // dismiss navigation controller
                navigation.dismiss(animated: animated, completion: nil)
            } else {
                navigation.popViewController(animated: animated)
            }
        } else if presentingViewController != nil { // in modal presentation
            dismiss(animated: animated, completion: nil)
        } else if view.superview != nil { // is a subview
            removeFromParentViewController()
            view.removeFromSuperview()
        }
    }
}
