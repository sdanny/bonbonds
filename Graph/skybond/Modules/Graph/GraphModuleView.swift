//
//  GraphModuleView.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright (c) 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit

protocol GraphModuleViewOutput {
    func viewWillAppear()
    
    func didSelectYield()
    func didSelectPrice()
    
    func didChangePeriod(to value: Period)
}

class GraphModuleView: UIViewController, GraphModuleViewInput, GraphViewDataSource, ParameterViewDelegate {
  
    var output: GraphModuleViewOutput!
    
    @IBOutlet private var buttonsPanel: UIView!
    @IBOutlet private var weekButton: UIButton!
    @IBOutlet private var monthButton: UIButton!
    @IBOutlet private var threeMonthsButton: UIButton!
    @IBOutlet private var sixMonthsButton: UIButton!
    @IBOutlet private var yearButton: UIButton!
    @IBOutlet private var twoYearsButton: UIButton!
    private var prevButton: UIButton?
    private var graphView: GraphView!
    private var parameterView: ParameterView!
    
    private var models: [GraphModel] = []
  
    // MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prevButton = weekButton
        // add subviews
        graphView = GraphView(frame: .zero)
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.dataSource = self
        view.addSubview(graphView)
        NSLayoutConstraint.activate([graphView.topAnchor.constraint(equalTo: view.topAnchor),
                                     graphView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     graphView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     graphView.heightAnchor.constraint(equalToConstant: 280),
                                     graphView.bottomAnchor.constraint(equalTo: buttonsPanel.topAnchor)])
        parameterView = ParameterView.loadFromNib() as! ParameterView
        parameterView.translatesAutoresizingMaskIntoConstraints = false
        parameterView.delegate = self
        view.addSubview(parameterView)
        NSLayoutConstraint.activate([parameterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
                                     parameterView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
                                     parameterView.widthAnchor.constraint(equalToConstant: 80)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
    }
    
    // MARK: input methods
    func reloadGraph(models: [GraphModel]) {
        self.models = models
        graphView.reloadData()
    }
    
    // MARK: actions
    @IBAction func periodButtonDidTouchUpInside(_ sender: UIButton) {
        guard sender !== prevButton else { return }
        prevButton?.setTitleColor(.darkText, for: .normal)
        sender.setTitleColor(.blue, for: .normal)
        prevButton = sender
        let period: Period
        switch sender {
        case weekButton:
            period = .week
        case monthButton:
            period = .month
        case threeMonthsButton:
            period = .threeMonths
        case sixMonthsButton:
            period = .sixMonths
        case yearButton:
            period = .year
        case twoYearsButton:
            period = .twoYears
        default:
            return
        }
        output.didChangePeriod(to: period)
    }
    
    // MARK: graph view data source
    func numberOfComponentsInGraphView(_ graphView: GraphView) -> Int {
        return models.count
    }
    
    func graphView(_ graphView: GraphView, valueFor component: Int) -> Float {
        return models[component].value
    }
    
    func graphView(_ graphView: GraphView, titleFor component: Int) -> String {
        return models[component].title
    }
    
    // MARK: parameter view delegate
    func parameterViewDidSelectPrice() {
        output.didSelectPrice()
    }
    
    func parameterViewDidSelectYield() {
        output.didSelectYield()
    }
    
}
