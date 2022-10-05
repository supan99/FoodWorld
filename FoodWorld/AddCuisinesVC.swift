//
//  AddCuisinesVC.swift
//  FoodWorld

import UIKit

class AddCuisinesVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    var imgPicker = UIImagePickerController()
    var imgPicker1 = OpalImagePickerController()
    var isImageSelected : Bool = false
    var isURLChange: Bool = false
    var imageURL = ""
    var img = UIImage()
    var data: CuisineModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer()
        tap.addAction {
            self.openOptions()
        }
        self.imgProfile.addGestureRecognizer(tap)
        self.imgProfile.isUserInteractionEnabled = true
        self.btnAdd.layer.cornerRadius = 10.0
        // Do any additional setup after loading the view.
        
        
        if data != nil {
            self.imgProfile.setImgWebUrl(url: data.imageURL, isIndicator: true)
            self.txtName.text = data.name
            self.imageURL = data.imageURL
            self.isImageSelected = true
            self.btnAdd.setTitle("Update Cuisine", for: .normal)
        }
    }
    
    func validation(name: String) -> String{
        
        if !self.isImageSelected {
            return "Please select image"
        }else if name.isEmpty {
            return "Please enter name"
        }
        return ""
    }
    
    @IBAction func btnAdd(_ sender: UIButton){
        let error =  self.validation(name: self.txtName.text?.trim() ?? "")
        
        if error.isEmpty {
            self.uploadImagePic(img1: self.img, name: self.txtName.text?.trim() ?? "")
        }else{
            Alert.shared.showAlert(message: error, completion: nil)
        }
    }
    
    func openOptions(){
        
        let actionSheet = UIAlertController(title: nil, message: "Select Image", preferredStyle: .actionSheet)
        
        let cameraPhoto = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return Alert.shared.showAlert(message: "Camera not Found", completion: nil)
            }
            GFunction.shared.isGiveCameraPermissionAlert(self) { (isGiven) in
                if isGiven {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.imgPicker.mediaTypes = ["public.image"]
                        self.imgPicker.sourceType = .camera
                        self.imgPicker.cameraDevice = .rear
                        self.imgPicker.allowsEditing = true
                        self.imgPicker.delegate = self
                        self.present(self.imgPicker, animated: true)
                    }
                }
            }
        })
        
        let PhotoLibrary = UIAlertAction(title: "Gallary", style: .default, handler:
                                            { [self]
            (alert: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .denied || photos == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({status in
                        if status == .authorized {
                            DispatchQueue.main.async {
                                self.imgPicker1 = OpalImagePickerController()
                                self.imgPicker1.imagePickerDelegate = self
                                self.imgPicker1.isEditing = true
                                present(self.imgPicker1, animated: true, completion: nil)
                            }
                        }
                    })
                }else if photos == .authorized {
                    DispatchQueue.main.async {
                        self.imgPicker1 = OpalImagePickerController()
                        self.imgPicker1.imagePickerDelegate = self
                        self.imgPicker1.isEditing = true
                        present(self.imgPicker1, animated: true, completion: nil)
                    }
                    
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            
        })
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        actionSheet.addAction(cameraPhoto)
        actionSheet.addAction(PhotoLibrary)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
}


//MARK:- UIImagePickerController Delegate Methods
extension AddCuisinesVC: UIImagePickerControllerDelegate, OpalImagePickerControllerDelegate {
    func uploadImagePic(img1 :UIImage, name: String){
        if isURLChange {
            let data = img1.jpegData(compressionQuality: 0.8)! as NSData
            let imagePath = GFunction.shared.UTCToDate(date: Date())
            let filePath = "cuisines/\(imagePath)"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let storageRef = Storage.storage().reference(withPath: filePath)
            storageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
                if error != nil {
                    return
                }
                storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                    self.imageURL = url?.absoluteString ?? ""
                    if self.data != nil {
                        self.updateData(data: self.data, name: name, imageURL: self.imageURL)
                    } else {
                        self.addCuisines(name: name, imageURL: self.imageURL)
                        
                    }
                })
            }
        }else{
            self.updateData(data: self.data, name: name, imageURL: self.data.imageURL)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        if let image = info[.editedImage] as? UIImage {
            self.img = image
            self.isImageSelected = true
            self.isURLChange = true
            self.imgProfile.image = image
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        do { picker.dismiss(animated: true) }
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]){
        for image in assets {
            if let image = getAssetThumbnail(asset: image) as? UIImage {
                self.img = image
                self.imgProfile.image = image
                self.isImageSelected = true
                self.isURLChange = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: (asset.pixelWidth), height: ( asset.pixelHeight)), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func imagePickerDidCancel(_ picker: OpalImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    func addCuisines(name: String, imageURL: String){
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(fCuisine).addDocument(data:
                                                                            [
                                                                                fNamE: name,
                                                                                fImageURL: imageURL,
                                                                            ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                Alert.shared.showAlert(message: "You have added cuisine successfully", completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func updateData(data: CuisineModel,name: String, imageURL: String) {
        let ref = AppDelegate.shared.db.collection(fCuisine).document(data.docID)
        ref.updateData([
            fNamE: name,
            fImageURL: imageURL,
        ]){  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
