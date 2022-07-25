//
//  ViewController.swift
//  ScrollableStackView
//
//  Created by 정준현 on 2022/07/05.
//

import UIKit

class ViewController: UIViewController {
    private let scrollView: ScrollableStackView = {
        let view: ScrollableStackView = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let dataNum = 3000
    let dataMinValue: Float = 0
    let dataMaxValue: Float = 100
    
    var _dataPointsList: [[Float]] = []
    var dataPointsList: [[Float]] {
        if (_dataPointsList.isEmpty) {
            for _ in 0...0 {
                var dataPoints: [Float] = []
                for _ in 0..<dataNum {
                    dataPoints.append(Float.random(in: dataMinValue...dataMaxValue))
                }
                _dataPointsList.append(dataPoints)
            }
        }
        return _dataPointsList
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpView()
        setScrollViewConstraint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let config = GraphConfig()
        config.dataPointsList = self.dataPointsList
        scrollView.setConfig(config)
    }
    
    private func setUpView() {
        view.addSubview(scrollView)
    }
    
    private func setScrollViewConstraint() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 300),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
    }
}
