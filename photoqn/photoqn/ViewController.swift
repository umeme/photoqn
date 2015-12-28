import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MDCSwipeToChooseDelegate
    
    var photoAssets = [PHAsset]()
    private var swipeLabel: UILabel!
    let manager: PHImageManager = PHImageManager()
    var photoNo: Int = 0
    var photoX : CGFloat = 0.0
    var photoY : CGFloat = 0.0

    var audioPlayer:AVAudioPlayer!
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var photoView: UIImageView!
    
    @IBAction func addButton(sender: AnyObject) {
        self.pickImageFromCamera()
        self.pickImageFromLibrary()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        photoX = photoView.center.x
        photoY = photoView.center.y
        
        //        let options = MDCSwipeToChooseViewOptions()
        //        options.delegate = self
        //        options.likedText = "Keep"
        //        options.likedColor = UIColor.blueColor()
        //        options.nopeText = "Delete"
        //        options.onPan = { state -> Void in
        //            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
        //                print("Photo deleted!")
        //            }
        //        }
        
        
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
        
        let himage = UIImage(named: "heart.gif")
        myImageView.image = himage
        myImageView.alpha = 0
        self.view.addSubview(myImageView)

        
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
        print("Tapped!:end")
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer){
        print("Swiped up!:start")
        if photoAssets.count > photoNo + 1 {
            photoNo++
            // アニメーション処理
            UIView.animateWithDuration(NSTimeInterval(CGFloat(0.8)),
                animations: {() -> Void in
                    // 移動先の座標を指定する.
                    self.photoView.center = CGPoint(x: self.photoView.center.x, y: -self.view.frame.height);
                }, completion: {(Bool) -> Void in
                    self.showPhoto()
            })
        }
        print("Swiped up!:end")
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer){
        print("Swiped down!:start")
        if 0 < photoNo  {
            photoNo--
            // アニメーション処理
            UIView.animateWithDuration(NSTimeInterval(CGFloat(0.8)),
                animations: {() -> Void in
                    // 移動先の座標を指定する.
                    self.photoView.center = CGPoint(x: self.photoView.center.x, y: +self.view.frame.height*2);
                }, completion: {(Bool) -> Void in
                    self.showPhoto()
            })
        }
        print("Swiped down!:end")
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer){
        print("Swiped Right!:start")
        if photoAssets.count != 0 {
            favPhoto()
            
            UIView.animateWithDuration(
                NSTimeInterval(CGFloat(0.8)),
                animations: {() -> Void in
                    self.myImageView.alpha = 1
                }
                , completion: {(Bool) -> Void in
                    self.myImageView.alpha = 0
            })

            if photoAssets.count > photoNo + 1 {
                photoNo++
                // アニメーション処理
                UIView.animateWithDuration(NSTimeInterval(CGFloat(0.8)),
                    animations: {() -> Void in
                        // 移動先の座標を指定する.
                        self.photoView.center = CGPoint(x: self.photoView.center.x, y: -self.view.frame.height);
                    }, completion: {(Bool) -> Void in
                        self.showPhoto()
                        
                })
                
            }
        }
        print("Swiped Right!:end")
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer){
        print("Swiped Left!:start")
        if photoAssets.count != 0 {
            deleteImage()
        }
        
        print("Swiped Left!:end")
    }
    
    
    func degreesToRadians(degrees: Float) -> Float {
        return degrees * Float(M_PI) / 180.0
    }
    
    func vibrated(vibrated:Bool, view: UIView) {
        if vibrated {
            var animation: CABasicAnimation
            animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.duration = 0.15
            animation.fromValue = degreesToRadians(3.0)
            animation.toValue = degreesToRadians(-3.0)
            animation.repeatCount = Float.infinity
            animation.autoreverses = true
            view.layer .addAnimation(animation, forKey: "VibrateAnimationKey")
        }
        else {
            view.layer.removeAnimationForKey("VibrateAnimationKey")
        }
    }
    
    // 写真を取得
    func getAllPhotosInfo() {
        // 初期化
        photoAssets = []
        photoAssets.removeAll()
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
    func showPhoto() {
        vibrated(false, view: photoView)
        print("表示１")
        print("assetCnt:\(self.photoAssets.count)")
        print("assetCnt:\(self.photoNo)")
        
        if photoAssets.count != 0 && photoNo >= 0 {
        // Assetsあり、写真あり
            print("表示２")
            print("assetCnt:\(self.photoAssets.count)")
            print("assetCnt:\(self.photoNo)")
            let asset = photoAssets[photoNo]
            manager.requestImageForAsset(asset,
                targetSize: CGSize(width: 100.0, height: 100.0),
                contentMode: .AspectFit,
                options: nil) { (image, info) -> Void in
                    // 取得したimageをUIImageViewなどで表示する
                    self.photoView.center = CGPointMake(self.photoView.center.x, self.photoY);
                    self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
                    self.photoView.image = image
                    self.photoView.fadeIn(.Slow)
            }
        } else if photoAssets.count != 0 && photoNo >= photoAssets.count {
            // Assetsあり、最後の画像の場合
            print("表示２")
            print("assetCnt:\(self.photoAssets.count)")
            print("assetCnt:\(self.photoNo)")
            photoNo = photoAssets.count - 1
            let asset = photoAssets[photoNo]
            manager.requestImageForAsset(asset,
                targetSize: CGSize(width: 100.0, height: 100.0),
                contentMode: .AspectFit,
                options: nil) { (image, info) -> Void in
                    // 取得したimageをUIImageViewなどで表示する
                    self.photoView.center = CGPointMake(self.photoView.center.x, self.photoY);
                    self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
                    self.photoView.image = image
                    self.photoView.fadeIn(.Slow)
            }
        } else {
            print("表示４")
            print("assetCnt:\(self.photoAssets.count)")
            print("assetCnt:\(self.photoNo)")
            let image = UIImage(named: "noimage.jpeg")
            photoView.image = image
        }
    }
    
    
    // 写真をふぁぼ
    func favPhoto() {
//        vibrated(true, view: photoView)
//        let audioPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sample", ofType: "mp3")!)
//        
//        let audioError:NSError?
//        audioPlayer = AVAudioPlayer(contentsOfURL: audioPath, fileTypeHint:&audioError)
//        if let error = audioError {
//            print("Error \(error.localizedDescription)")
//        }
//        audioPlayer.play()
        
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
            
            print("assetCnt:\(self.photoAssets.count)")
            print("assetCnt:\(self.photoNo)")
            
            PHAssetChangeRequest.deleteAssets([delTargetAsset])
            }, completionHandler: { (success, error) -> Void in
                // 完了時の処理をここに記述
                print("削除")
                print("b\(self.photoAssets.count)")
                self.photoAssets.removeAtIndex(self.photoNo)
                print("c\(self.photoAssets.count)")
                print("removeされた")
                
                // 0枚ではない時
                if 0 != self.photoAssets.count {
                    print("d\(self.photoAssets.count)")
                    // 再取得
                    self.photoAssets.removeAll()
                    self.getAllPhotosInfo()
                    print("e\(self.photoAssets.count)")
                    // 写真枚数と配列番号が同じ場合（最後の写真以外の場合）
                    print("assetCnt:\(self.photoAssets.count)")
                    print("assetCnt:\(self.photoNo)")
                    if self.photoAssets.count != self.photoNo + 1 && self.photoNo != 0 {
                        self.photoNo--
                    }
                }
                // 非同期のため、ここで表示
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

