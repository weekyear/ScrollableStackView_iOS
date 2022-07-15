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
    
    private func setScrollViewConstraint() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 300),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
    }
    
    private let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        button.backgroundColor = .black
        button.setTitle("위치 변경", for: .normal)
        return button
    }()
    
    
    private func setUpView() {
        view.addSubview(scrollView)
        view.addSubview(button)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpView()
        setScrollViewConstraint()
        
        self.view.addSubview(button)

        setButtonClickListener()
    }
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    private func setButtonClickListener() {
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
    }
    
    @objc func buttonClicked() {
        print("Button Clicked")
//        let scrollX = scrollView.contentOffset.x
//        scrollView.contentOffset = CGPoint(x: max(scrollX - scrollView.frame.width * 2, 0), y: 0)
    }
}
