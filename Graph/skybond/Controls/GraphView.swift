//
//  GraphView.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func numberOfComponentsInGraphView(_ graphView: GraphView) -> Int
    func graphView(_ graphView: GraphView, titleFor component: Int) -> String
    func graphView(_ graphView: GraphView, valueFor component: Int) -> Float
}

class GraphView: UIView {
    
    private struct Constant {
        static let horInsets: CGFloat = 20
        static let vertInsets: CGFloat = 40
        static let titleSize = CGSize(width: 40, height: 16)
    }
    
    weak var dataSource: GraphViewDataSource?
    
    // MARK: sublayers
    private var netLayer = CALayer()
    private var graphLayer = CALayer()
    private var valuesLayer = CALayer()
    private var graphTitlesLayer = CALayer()
    
    // MARK: design
    private var netColor: UIColor = UIColor.lightGray.withAlphaComponent(0.7)
    private var titleColor: UIColor = .darkText
    private var lineColor: UIColor = .red
    
    // MARK: components
    private(set) var numberOfComponents: Int = 0
    private(set) var values: [Float] = []
    private(set) var titles: [String] = []
    private var min: Float = 0
    private var max: Float = 0
    private let lock = NSLock()
    private let drawLock = NSLock()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // add layers
        layer.addSublayer(netLayer)
        layer.addSublayer(graphLayer)
        layer.addSublayer(valuesLayer)
        layer.addSublayer(graphTitlesLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // add layers
        layer.addSublayer(netLayer)
        layer.addSublayer(graphLayer)
        layer.addSublayer(valuesLayer)
        layer.addSublayer(graphTitlesLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        netLayer.frame = layer.bounds
        graphLayer.frame = layer.bounds
        valuesLayer.frame = layer.bounds
        graphTitlesLayer.frame = layer.bounds
        
        redraw()
    }
    
    func reloadData() {
        guard let dataSource = dataSource else { return }
        
        lock.lock()
        
        numberOfComponents = dataSource.numberOfComponentsInGraphView(self)
        values = []
        titles = []
        
        for index in 0..<numberOfComponents {
            let title = dataSource.graphView(self, titleFor: index)
            titles.append(title)
            let value = dataSource.graphView(self, valueFor: index)
            values.append(value)
        }
        min = values.min() ?? 0
        max = values.max() ?? 0
        
        lock.unlock()
        
        redraw()
    }
    
    private func redraw() {
        drawLock.lock()
        defer { drawLock.unlock() }
        
        netLayer.removeSublayers()
        graphLayer.removeSublayers()
        valuesLayer.removeSublayers()
        graphTitlesLayer.removeSublayers()
        
        let xSpace: CGFloat = (bounds.width - Constant.horInsets * 2) / CGFloat(numberOfComponents + 1)
        let ySpace: CGFloat = (bounds.height - Constant.vertInsets * 2) / 3
        guard xSpace > 0, ySpace > 0 else { return }
        
        drawVerticalLines(xSpace: xSpace)
        drawHorizontalLines(xSpace: xSpace, ySpace: ySpace)
        drawGraph(xSpace: xSpace, ySpace: ySpace)
    }
    
    private func drawVerticalLines(xSpace: CGFloat) {
        var x: CGFloat = Constant.horInsets + xSpace
        for index in 0..<numberOfComponents {
            let shape = lineLayer(from: CGPoint(x: x, y: 0), to: CGPoint(x: x, y: bounds.height))
            netLayer.addSublayer(shape)
            // add title layer
            let text = titleTextLayer(string: titles[index])
            text.alignmentMode = "center"
            let origin = CGPoint(x: x, y: bounds.height)
            text.frame = CGRect(origin: origin, size: Constant.titleSize)
            text.anchorPoint = CGPoint(x: 1, y: 1)
            netLayer.addSublayer(text)
            x += xSpace
        }
    }
    
    private func drawHorizontalLines(xSpace: CGFloat, ySpace: CGFloat) {
        var y: CGFloat = Constant.vertInsets + ySpace
        for index in 0..<3 {
            let shape = lineLayer(from: CGPoint(x: 0, y: y), to: CGPoint(x: bounds.width, y: y))
            netLayer.addSublayer(shape)
            // add title layer
            let value: Float
            switch index {
            case 0:
                value = max
            case 1:
                value = (max - min) / 2 + min
            case 2:
                value = min
            default:
                return
            }
            let string = String(format: "%.1f", value)
            let text = titleTextLayer(string: string)
            text.alignmentMode = "right"
            let origin = CGPoint(x: Constant.horInsets + xSpace / 3, y: y)
            text.frame = CGRect(origin: origin, size: Constant.titleSize)
            text.anchorPoint = CGPoint(x: 1, y: 1)
            netLayer.addSublayer(text)
            y += ySpace
        }
    }
    
    private func drawGraph(xSpace: CGFloat, ySpace: CGFloat) {
        let path = UIBezierPath()
        let minY = Constant.vertInsets
        let maxY = bounds.height - Constant.vertInsets - ySpace
        var x: CGFloat = Constant.horInsets + xSpace
        for index in 0..<numberOfComponents {
            let value = values[index]
            guard value > 0 else { continue }
            // add line
            let ratio = (value - min)/(max - min)
            let y = bounds.height - CGFloat(ratio) * (maxY - minY) - minY
            let point = CGPoint(x: x, y: y)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
                // add title
                let string = String(format: "%.1f", value)
                let text = titleTextLayer(string: string)
                text.shadowColor = UIColor.white.cgColor
                text.shadowRadius = 0
                text.shadowOpacity = 1
                text.shadowOffset = CGSize(width: 0, height: 1)
                text.alignmentMode = "center"
                let origin = CGPoint(x: point.x - Constant.titleSize.width/2, y: point.y - Constant.titleSize.height/2)
                text.frame = CGRect(origin: origin, size: Constant.titleSize)
                graphTitlesLayer.addSublayer(text)
            }
            x += xSpace
        }
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = nil
        shape.strokeColor = lineColor.cgColor
        shape.lineWidth = 2
        graphLayer.addSublayer(shape)
    }
    
    private func lineLayer(from point0: CGPoint, to point1: CGPoint) -> CALayer {
        let path = UIBezierPath()
        path.move(to: point0)
        path.addLine(to: point1)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = nil
        shape.strokeColor = netColor.cgColor
        shape.lineWidth = 1
        return shape
    }
    
    private func titleTextLayer(string: String) -> CATextLayer {
        let text = CATextLayer()
        text.fontSize = 12
        text.string = string
        text.foregroundColor = titleColor.cgColor
        text.alignmentMode = kCAAlignmentLeft
        text.contentsScale = UIScreen.main.scale
        return text
    }

}

extension CALayer {
    
    func removeSublayers() {
        guard let layers = sublayers else { return }
        for layer in layers {
            layer.removeFromSuperlayer()
        }
    }
}
