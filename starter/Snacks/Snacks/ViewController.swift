import UIKit
import CoreMedia
import CoreML
import Vision

class ViewController: UIViewController {
  
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var cameraButton: UIButton!
  @IBOutlet var photoLibraryButton: UIButton!
  @IBOutlet var resultsView: UIView!
  @IBOutlet var resultsLabel: UILabel!
  @IBOutlet var resultsConstraint: NSLayoutConstraint!

  var firstTime = true
  lazy var classificationRequest: VNCoreMLRequest = {
      do{
          let classifier = try Snacks(configuration: MLModelConfiguration())
          
          let model = try VNCoreMLModel(for: classifier.model)
          let request = VNCoreMLRequest(model: model, completionHandler: {
              [weak self] request,error in
              self?.processObservations(for: request, error: error)
          })
          request.imageCropAndScaleOption = .centerCrop
          return request
          
          
      } catch {
          fatalError("Failed to create request")
      }
  }()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    resultsView.alpha = 0
    resultsLabel.text = "choose or take a photo"
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Show the "choose or take a photo" hint when the app is opened.
    if firstTime {
      showResultsView(delay: 0.5)
      firstTime = false
    }
  }
  
  @IBAction func takePicture() {
    presentPhotoPicker(sourceType: .camera)
  }

  @IBAction func choosePhoto() {
    presentPhotoPicker(sourceType: .photoLibrary)
  }

  func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = sourceType
    present(picker, animated: true)
    hideResultsView()
  }

  func showResultsView(delay: TimeInterval = 0.1) {
    resultsConstraint.constant = 100
    view.layoutIfNeeded()

    UIView.animate(withDuration: 0.5,
                   delay: delay,
                   usingSpringWithDamping: 0.6,
                   initialSpringVelocity: 0.6,
                   options: .beginFromCurrentState,
                   animations: {
      self.resultsView.alpha = 1
      self.resultsConstraint.constant = -10
      self.view.layoutIfNeeded()
    },
    completion: nil)
  }

  func hideResultsView() {
    UIView.animate(withDuration: 0.3) {
      self.resultsView.alpha = 0
    }
  }

  func classify(image: UIImage) {
    guard let imageCI = CIImage(image: image)
    else { return }
    let orientation = CGImagePropertyOrientation(image.imageOrientation)
    DispatchQueue.main.async {
      let handler = VNImageRequestHandler(ciImage: imageCI, orientation: orientation, options: [:] )
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        print("Failed to perform classification: \(error)")
      }
    }
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)

    let image = info[.originalImage] as! UIImage
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    classify(image: image)
  }
}

extension ViewController {
  func processObservations(for request: VNRequest, error: Error?) {
    if let results = request.results as? [VNClassificationObservation] {
      if results.isEmpty {
        self.resultsLabel.text = "Nothing found"
      } else {
        let result = results[0].identifier
        let confidence = results[0].confidence
        if confidence * 100 < 60 {
          self.resultsLabel.text = "I'm not sure.Perhaps it's not a food."
        }
        else {
          self.resultsLabel.text = result.appendingFormat(", confidence: %.1f%%", confidence * 100)
        }
        self.showResultsView()
        print(result)
      }
    } else if let error = error {
      self.resultsLabel.text = "Error: \(error.localizedDescription)"
    } else {
      self.resultsLabel.text = "???"
    }
  }
}
