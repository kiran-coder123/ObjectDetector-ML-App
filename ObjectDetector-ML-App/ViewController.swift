//
//  ViewController.swift
//  ObjectDetector-ML-App
//
//  Created by Kiran Sonne on 13/10/22.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    private let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = ""
        
     }
    
    lazy var request: VNCoreMLRequest = {
       
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("can't load model")
        }
        let request = VNCoreMLRequest(model: model) {[weak self] (request,error) in
             
            guard let strongSelf = self else { return }
            
            //if there is any error
            if let error = error {
                print("Error making request")
            } else {
                strongSelf.process(request: request)
            }
            
        }
         return request
        
    }()
    
    func process(request: VNRequest){
        guard let result = request.results as? [VNClassificationObservation], let dominantResult = result.first else {
            fatalError("error getting dominant result")
        }
        DispatchQueue.main.async {
            self.resultLabel.text = "\(Int(dominantResult.confidence * 100))% \(dominantResult.identifier)"
        }
    }
    
    func detectImage(image: UIImage) {
        
        resultLabel.text = ""
        guard let ciImage = CIImage(image: image) else {
            print("unable to create CIImage")
            return
        }
        resultLabel.text = "Detecting..."

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try  handler.perform([self.request])
            } catch   {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
      //MARK: Actions
    
    @IBAction func findImageButtonTapped(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Please Select Device", message: "there is no device found", preferredStyle: .alert)
         
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    
//        imagePicker.sourceType = .camera
//        imagePicker.delegate = self
//        present(imagePicker, animated: true, completion: nil)
    }
    
}
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            objectImageView.image = pickedImage
            detectImage(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
