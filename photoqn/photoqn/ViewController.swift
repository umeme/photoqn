import UIKit
import Photos


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MDCSwipeToChooseDelegate {
    
    var photoAssets = [PHAsset]()
    private var swipeLabel: UILabel!
    let manager: PHImageManager = PHImageManager()
    var photoNo: Int = 0
    
    @IBOutlet weak var photoView: UIImageView!
    
    
    @IBAction func addButton(sender: AnyObject) {
        self.pickImageFromCamera()
        self.pickImageFromLibrary()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.likedText = "Keep"
        options.likedColor = UIColor.blueColor()
        options.nopeText = "Delete"
        options.onPan = { state -> Void in
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
                print("Photo deleted!")
            }
        }

        
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
        favPhoto()
        if photoAssets.count > photoNo + 1 {
            photoNo++
            showPhoto()
        }
        print("Tapped!:end")
        
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer){
        print("Swiped up!:start")
        if photoAssets.count > photoNo + 1 {
            photoNo++
            showPhoto()
        }
        print("Swiped up!:end")
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer){
        print("Swiped down!:start")
        if 0 < photoNo - 1 {
            photoNo--
            showPhoto()
        }
        print("Swiped down!:end")
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer){
        print("Swiped Right!:start")
        print("Swiped Right!:end")
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer){
        print("Swiped Left!:start")
        deleteImage()
    
        
               print("Swiped Left!:end")
    }
    
    // 写真を取得
    private func getAllPhotosInfo() {
        // 初期化
        photoAssets = []
        // 画像をすべて取得
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let assets: PHFetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
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
                self.photoView.contentMode = UIViewContentMode.ScaleAspectFill
                self.photoView.image = image
                
        }
    }
    
    // 写真をふぁぼ
    private func favPhoto() {
        let favTargetAsset = photoAssets[photoNo]
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            // Create a change request from the asset to be modified.
            let request = PHAssetChangeRequest(forAsset: favTargetAsset)
            // Set a property of the request to change the asset itself.
            request.favorite = !favTargetAsset.favorite
            
            }, completionHandler: { success, error in
                print("fav!")
        })
    }
    
    
    // 写真を削除
    private func deleteImage() {
        let delTargetAsset = photoAssets[photoNo]
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            // 削除などの変更はこのblocks内でリクエストする
            PHAssetChangeRequest.deleteAssets([delTargetAsset])
            }, completionHandler: { (success, error) -> Void in
                // 完了時の処理をここに記述
                print("削除")
                self.photoAssets.removeAtIndex(self.photoNo)
                print("removeされた")
                if 0 < self.photoNo - 1 {
                    self.photoNo--
                }
                self.showPhoto()
                print("次の写真表示された")
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