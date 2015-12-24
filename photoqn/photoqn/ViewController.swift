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
    
    // 写真を撮ってそれを選択
    private func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから写真を選択する
    private func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}