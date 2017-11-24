//
//  ResultController.swift
//  Not Hotdog
//
//  Created by Charles Kenney on 11/23/17.
//  Copyright © 2017 Charles Kenney. All rights reserved.
//

import Foundation
import UIKit

class ResultController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard let img = self.image else { return }
            imageView.image = img
            process(img)
        }
    }
    
    var classification: String? {
        didSet {
            presentResult()
        }
    }
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "DeleteIcon"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let resultView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let isHotdogLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 30)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 18)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupImageView()
        setupDismissButton()
        setupResultView()
        setupResultLabel()
        setupIsHotdogLabel()
    }
    
}


// MARK: - View Preperations

fileprivate extension ResultController {
    
    func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(dismissButton)
        view.addSubview(resultView)
    }
    
    func setupImageView() {
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    func setupDismissButton() {
        dismissButton.addTarget(self, action: #selector(dismissView(_:)), for: .touchUpInside)
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupResultView() {
        resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        resultView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        resultView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        resultView.addSubview(resultLabel)
        resultView.addSubview(isHotdogLabel)
    }
    
    func setupResultLabel() {
        resultLabel.widthAnchor.constraint(equalTo: resultView.widthAnchor).isActive = true
        resultLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        resultLabel.topAnchor.constraint(equalTo: resultView.topAnchor).isActive = true
    }
    
    func setupIsHotdogLabel() {
        isHotdogLabel.heightAnchor.constraint(equalToConstant: 100)
        isHotdogLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor).isActive = true
        isHotdogLabel.widthAnchor.constraint(equalTo: resultView.widthAnchor).isActive = true
    }
    
}


// MARK: - Actions

@objc extension ResultController {
    
    func dismissView(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    func process(_ image: UIImage) {
        // get buffer
        guard let pixelBuffer = image.pixelBuffer(width: 299, height: 299) else { return }
        // get prediction
        let model = Inceptionv3()
        do {
            let output = try model.prediction(image: pixelBuffer)
            let probs = output.classLabelProbs.sorted { $0.value > $1.value }
            if let prob = probs.first {
                classification = prob.key.components(separatedBy: ",").first ?? prob.key
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func presentResult() {
        // get classification
        guard let classification = self.classification else { return }
        let isHotdog = classification == "hotdog"
        resultView.backgroundColor = isHotdog ? .green : .red
        isHotdogLabel.text = isHotdog ? "It's a hotdog!" : "It's a not-hotdog!"
        resultLabel.text = classification
        // animate view in
        UIView.animate(withDuration: 0.5, animations: {
            self.resultView.alpha = 1
        })
        
    }
    
}
