//
//  AddRestaurantVC.swift
//  FoodWorld


import UIKit

class AddRestaurantVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var lblCuisinesName: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    var imgPicker = UIImagePickerController()
    var imgPicker1 = OpalImagePickerController()
    var isImageSelected : Bool = false
    var isURLChange: Bool = false
    var imageURL = ""
    var img = UIImage()
    var data : RestaurantModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer()
        tap.addAction {
            self.openOptions()
        }
        self.imgProfile.addGestureRecognizer(tap)
        self.imgProfile.isUserInteractionEnabled = true
        self.btnAdd.layer.cornerRadius = 10.0
        
        
        let tap1 = UITapGestureRecognizer()
        tap1.addAction {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: CuisinesVC.self){
                vc.modalPresentationStyle = .pageSheet
                vc.completionHandlerSend = { (arrData : [String]) in
                    let strData = arrData.joined(separator: ", ")
                    self.lblCuisinesName.text = strData
                }
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
        self.lblCuisinesName.addGestureRecognizer(tap1)
        self.lblCuisinesName.isUserInteractionEnabled = true
        
        if data != nil {
            self.txtName.text = data.name
            self.txtAddress.text = data.address
            self.imgProfile.setImgWebUrl(url: data.imageURL, isIndicator: true)
            self.lblCuisinesName.text = data.cuisineName
            self.isImageSelected = true
            self.btnAdd.setTitle("Update Restaurant", for: .normal)
        }
    }
    
    
    func validation(name: String, address: String, cuisines: String,description: String) -> String{
        
        if !self.isImageSelected {
            return "Please select image"
        }else if name.isEmpty {
            return "Please enter name"
        }else if address.isEmpty {
            return "Please enter address"
        }else if description.isEmpty {
            return "Please enter description"
        }else if cuisines.isEmpty {
            return "Please enter cuisines names"
        }
        
        
        return ""
    }
    
    @IBAction func btnAdd(_ sender: UIButton){
        let error =  self.validation(name: self.txtName.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "", cuisines: self.lblCuisinesName.text?.trim() ?? "", description: self.txtDescription.text ?? "")
        
        if error.isEmpty {
            self.uploadImagePic(img1: self.img, name: self.txtName.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "", cuisines: self.lblCuisinesName.text?.trim() ?? "", description: self.txtDescription.text ?? "")
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
extension AddRestaurantVC: UIImagePickerControllerDelegate, OpalImagePickerControllerDelegate {
    func uploadImagePic(img1 :UIImage, name: String, address:String, cuisines:String, description: String){
        if isURLChange {
            let data = img1.jpegData(compressionQuality: 0.8)! as NSData
            // set upload path
            let imagePath = GFunction.shared.UTCToDate(date: Date())
            let filePath = "restaurant/\(imagePath)" // path where you wanted to store img in storage
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let storageRef = Storage.storage().reference(withPath: filePath)
            storageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
                if let error = error {
                    return
                }
                storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                    self.imageURL = url?.absoluteString ?? ""
                    print(url?.absoluteString) // <- Download URL
                    
                    if self.data != nil {
                        self.updateData(data: self.data, name: name, address: address, cuisines: cuisines, imageURL: self.imageURL, description: description)
                    }else{
                        self.addRestaurant(name: name, address: address, cuisines: cuisines, imageURL: self.imageURL, description: description)
                    }
                    
                })
            }
        }else{
            if data != nil {
                self.updateData(data: self.data, name: name, address: address, cuisines: cuisines, imageURL: data.imageURL, description: description)
            }
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
                self.isURLChange = true
                self.isImageSelected = true
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
    
    func addRestaurant(name: String, address: String, cuisines: String, imageURL: String, description: String){
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(fRestaurant).addDocument(data:
                                                                        [
                                                                            fName: name,
                                                                            fCuisine: cuisines,
                                                                            fAddress : address,
                                                                            fImageURL: imageURL,
                                                                            fDescription: description,
                                                                        ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                Alert.shared.showAlert(message: "You have added restaurant successfully", completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func updateData(data: RestaurantModel,name: String, address: String, cuisines: String, imageURL: String, description: String) {
        let ref = AppDelegate.shared.db.collection(fRestaurant).document(data.docID)
        ref.updateData([
            fName: name,
            fCuisine: cuisines,
            fAddress : address,
            fImageURL: imageURL,
            fDescription: description,
        ]){  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
               self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
