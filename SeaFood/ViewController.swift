//
//  ViewController.swift
//  SeaFood
//
//  Created by Yogesh Sehgal on 20/04/20.
//  Copyright © 2020 Yogesh Sehgal. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var showData: UILabel!
    
    let imagePicker=UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate=self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing=false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage=info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image=userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could Not Convert to CIImage")
            }
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    
    }
    
    func detect(image:CIImage){
        guard let model = try?VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading CoreML Failed")
        }
        
        let request = VNCoreMLRequest(model: model){ (request,error) in
            guard let results = request.results?.first as? VNClassificationObservation else{
                fatalError("Could Not Classify")
            }

        
            
            let opt=results.identifier
            
            let search=opt.components(separatedBy:",")
                
            self.requestInfo(objectName: search[0])
            
            self.navigationItem.title=search[0].capitalized
            self.navigationItem.backBarButtonItem?.title = ""
            
            //print(search[0])
            
            //print(results as Any)
            
        }
        
        let handler=VNImageRequestHandler(ciImage: image)
        
        do{
        try handler.perform([request])
        }
        catch{
            print(error)
        }
    }
    
    
    func requestInfo(objectName:String){
        
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts",
        "exintro" : "",
        "explaintext" : "",
        "titles" : objectName,
        "indexpageids" : "",
        "redirects" : "1",
        ]

        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess{
                //print(JSON(response.result.value as Any))
                
                let objectJSON : JSON = JSON(response.result.value!)
                print(objectJSON)
                
                let pageid = objectJSON["query"]["pageids"][0].stringValue
                
                let data = objectJSON["query"]["pages"][pageid]["extract"].stringValue
                
                self.showData.text=data
            }
            else{
                self.showData.text="Not Connected to Internet, Connect for More Info."
            }
        }
        
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        
        present(imagePicker,animated: true,completion: nil)
        
    }
    
}

