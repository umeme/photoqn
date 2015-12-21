import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   var photoAssets = [PHAsset]()
    
    @IBAction func addButton(sender: AnyObject) {
        self.pickImageFromCamera()
        self.pickImageFromLibrary()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //        self.checkAuthorizationStatus()
        
        
        // ユーザーに許可を促す.
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            
            switch(status){
            case .Authorized:
                print("Authorized")
                
            case .Denied:
                print("Denied")
                
            case .NotDetermined:
                print("NotDetermined")
                
            case .Restricted:
                print("Restricted")
            }
            
        }
        
        getAllPhotosInfo()
        
        let asset = photoAssets[0]
        
        let manager: PHImageManager = PHImageManager()
        manager.requestImageForAsset(asset,
            targetSize: CGSizeMake(70, 70),
            contentMode: .AspectFill,
            options: nil) { (image, info) -> Void in
                // 取得したimageをUIImageViewなどで表示する
                print("一枚目表示")
                
                // UIImage インスタンスの生成
                let image:UIImage? = UIImage(named:"hoge.jpg")
                
                // UIImageView 初期化
                let imageView = UIImageView(image:image)
                // 画像の中心を187.5, 333.5 の位置に設定、iPhone6
                imageView.center = CGPointMake(187.5, 333.5)
                
                // UIImageViewのインスタンスをビューに追加
                self.view.addSubview(imageView)
        }
        
        
        let status = PHPhotoLibrary.authorizationStatus();
        switch status {
        case PHAuthorizationStatus.NotDetermined:
            // ユーザーはまだ、このアプリに与える権限を選択をしていない
            print("status == PHAuthorizationStatus.NotDetermined")
            
//            self.getAuth(status);
            
            break;
            
        case PHAuthorizationStatus.Restricted:
            // PhotoLibraryへのアクセスが許可されていない
            // parental controlなどで制限されていて、ユーザーはアプリのアクセスの許可を変更できない
             print("status == PHAuthorizationStatus.Restricted")
            break;
            
        case PHAuthorizationStatus.Denied:
            // ユーザーが明示的に、アプリが写真のデータへアクセスすることを拒否した
            print("status == PHAuthorizationStatus.Denied")
            break;
        case PHAuthorizationStatus.Authorized:
            // ユーザーが、アプリが写真のデータへアクセスすることを許可している
            print("status == PHAuthorizationStatus.Authorized")
            break;

        }
    }
    
    
    private func getAllPhotosInfo() {
        // 初期化
        photoAssets = []
        
        // 画像をすべて取得
        let assets: PHFetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        assets.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            self.photoAssets.append(asset as! PHAsset)
        }
        print(photoAssets)
    }
    

//    func getAuth(:PHAuthorizationStatus) {
//     PHPhotoLibrary.requestAuthorization(<#T##handler: (PHAuthorizationStatus) -> Void##(PHAuthorizationStatus) -> Void#>)
//    }
    
    
//    private func checkAuthorizationStatus() {
//        let status = PHPhotoLibrary.authorizationStatus()
//        
//        switch status {
//        case .Authorized:
//            self.prepareAnnotations()
//        default:
//            PHPhotoLibrary.requestAuthorization{ status in
//                if status == .Authorized {
//                    self.prepareAnnotations()
//                }
//            }
//        }
//    }
    
//    private func prepareAnnotations() {
//        // 処理
//    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // 写真を撮ってそれを選択
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    // 写真を選択した時に呼ばれる
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        if info[UIImagePickerControllerOriginalImage] != nil {
//            let image = info[UIImagePickerControllerOriginalImage] as UIImage
//            println(image)
//        }
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    
//    // フォトライブラリを使用できるか確認
//    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
//    // フォトライブラリの画像・写真選択画面を表示
//    let imagePickerController = UIImagePickerController()
//    imagePickerController.sourceType = .PhotoLibrary
//    imagePickerController.allowsEditing = true
//    imagePickerController.delegate = self
//    presentViewController(imagePickerController, animated: true, completion: nil)
//    }
    

}

//extension ViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        
//        // 選択した画像・写真を取得し、imageViewに表示
//        if let info = editingInfo, let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
//            imageView.image = editedImage
//        }else{
//            imageView.image = image
//        }
//        
//        // フォトライブラリの画像・写真選択画面を閉じる
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//}