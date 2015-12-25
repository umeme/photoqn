import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photoAssets = [PHAsset]()
    private var swipeLabel: UILabel!
    let manager: PHImageManager = PHImageManager()
    var photoNo: Int = 0
    
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
        showPhoto()
        
        // single tap
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.view.addGestureRecognizer(tapGesture)
        
        // single swipe up
        let swipeUpGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeUp:")
        swipeUpGesture.numberOfTouchesRequired = 1  // number of fingers
        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUpGesture)
        
        // single swipe down
        let swipeDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeDown:")
        swipeDownGesture.numberOfTouchesRequired = 1
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDownGesture)
        
        // single swipe right
        let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeRight:")
        swipeRightGesture.numberOfTouchesRequired = 1  // number of fingers
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRightGesture)
        
        // single swipe left
        let swipeLeftGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeLeft:")
        swipeLeftGesture.numberOfTouchesRequired = 1  // number of fingers
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeftGesture)
    }
    
    // MARK: - Gesture Handlers
    func handleTap(sender: UITapGestureRecognizer){
        print("Tapped!:start")
        if photoAssets.count > photoNo + 1 {
            photoNo++
            showPhoto()
        }
        print("Tapped!:end")
        
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer){
        print("Swiped up!:start")
        print("Swiped up!:end")
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer){
        print("Swiped down!:start")
        print("Swiped down!:end")
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer){
        print("Swiped Right!:start")
        print("Swiped Right!:end")
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer){
        print("Swiped Left!:start")
        deleteImage()
        getAllPhotosInfo()
        photoNo--
        showPhoto()
        print("Swiped Left!:end")
    }
    
    // 写真を取得
    private func getAllPhotosInfo() {
        // 初期化
        photoAssets = []
        // 画像をすべて取得
        let assets: PHFetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        assets.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            self.photoAssets.append(asset as! PHAsset)
        }
    }
    
    // 写真を表示
    private func showPhoto() {
        let asset = photoAssets[photoNo]
        
        manager.requestImageForAsset(asset,
            targetSize: CGSize(width: 100.0, height: 100.0),
            contentMode: .AspectFill,
            options: nil) { (image, info) -> Void in
                // 取得したimageをUIImageViewなどで表示する
                
                let imageView = UIImageView(image:image)
                self.view.addSubview(imageView)
        }
    }
    
    
    // 写真を削除
    private func deleteImage() {
        let delTargetAsset = photoAssets[photoNo]
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            // 削除などの変更はこのblocks内でリクエストする
            PHAssetChangeRequest.deleteAssets([delTargetAsset])
            }, completionHandler: { (success, error) -> Void in
                // 完了時の処理をここに記述
        })
        
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