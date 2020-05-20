import UIKit
import Alamofire
class ViewController: UIViewController {

    
    @IBOutlet weak var pictureView: UIImageView!
    
    @IBOutlet weak var camBtn: UIButton!
    @IBOutlet weak var galBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }

    

    @IBAction func camButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController() // 1
        imagePicker.delegate = self // 2
        imagePicker.sourceType = UIImagePickerController.SourceType.camera // 3
        
        // для выбора только фотокамеры, не для записи видео
        imagePicker.showsCameraControls = true // 4
        
        self.present(imagePicker, animated: true, completion: nil) // 5
    }
    
    
    @IBAction func galButtonTapped(_ sender: UIButton) {
        pictureView.image! = pictureView.image!.resizeWithWidth(width: 300)!
        let data = pictureView.image!.pngData()!

        let httpHeaders = ["auth-token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1ZGFkYmZiN2FjNTJlNzFiOTQ3M2I5YmMiLCJpYXQiOjE1ODYzNDQzMzJ9.dlF3RUZU2zcdCceR1kY2LRTNUEwXNNXzYx9OAzaTwHo"]

                          upload(multipartFormData: { multipartFormData in
                            multipartFormData.append(data, withName: "imagefile", fileName: "image.jpg", mimeType: "image/jpeg")
                          }, to: "http://b6e31e15.ngrok.io/api/user", headers: httpHeaders, encodingCompletion: { encodingResult in
                              switch encodingResult {
                              case .success(let uploadRequest, let streamingFromDisk, let streamFileURL):
                                  print(uploadRequest)
                                  print(streamingFromDisk)
                                  print(streamFileURL ?? "streamFileURL is NIL")

                                  uploadRequest.validate().responseJSON() { responseJSON in
                                      switch responseJSON.result {
                                      case .success(let value):
                                          print(value)

                                      case .failure(let error):
                                          print(error)
                                      }
                                  }

                              case .failure(let error):
                                  print(error)
                              }
                          })
        
    }
 
    
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        let activityItems = [pictureView.image!]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }


    
    private func configureButton(btn: UIButton) {
        btn.backgroundColor = UIColor(red: 27/255, green: 89/255, blue: 147/255, alpha: 1.0)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .highlighted)
        
        btn.layer.cornerRadius = 4.0
        
        btn.layer.shadowOpacity = 0.6
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowRadius = 2
    }
}




extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           let imageFromPC = info[UIImagePickerController.InfoKey.originalImage] as! UIImage // 1

        pictureView.image = imageFromPC // 2
        self.dismiss(animated: true, completion: nil) // 3
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
