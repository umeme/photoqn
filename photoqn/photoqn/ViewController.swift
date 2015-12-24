import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   var photoAssets = [PHAsset]()
   private var swipeLabel: UILabel!
    
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
        
        let asset = photoAssets[1]
        
        print(asset)
        
        let manager: PHImageManager = PHImageManager()
        manager.requestImageForAsset(asset,
            targetSize: CGSizeMake(70, 70),
            contentMode: .AspectFill,
            options: nil) { (image, info) -> Void in
                // 取得したimageをUIImageViewなどで表示する
                print("一枚目表示")
                
                let imageView = UIImageView(image:image)
                
                self.view.addSubview(imageView)
                
//                // UIImage インスタンスの生成
//                let image:UIImage? = UIImage(named:"hoge.jpg")
//                
//                // UIImageView 初期化
//                let imageView = UIImageView(image:image)
//                // 画像の中心を187.5, 333.5 の位置に設定、iPhone6
//                imageView.center = CGPointMake(187.5, 333.5)
//                
//                // UIImageViewのインスタンスをビューに追加
//                self.view.addSubview(imageView)
        }
        
        
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
        print("Tapped!")
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer){
        print("Swiped up!")
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer){
        print("Swiped down!")
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer){
        print("Swiped Right!")
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer){
        print("Swiped Left!")
    }
    
    
    internal func makeMyLabel(title: NSString, color: UIColor, myX: CGFloat, myY: CGFloat) -> UILabel{
        let myLabel: UILabel = UILabel()
        myLabel.frame = CGRectMake(0,0,80,80)
        myLabel.backgroundColor = color
        myLabel.textColor = UIColor.whiteColor()
        myLabel.layer.masksToBounds = true
        myLabel.text = title as String
        myLabel.textAlignment = NSTextAlignment.Center
        myLabel.layer.cornerRadius = 40.0
        myLabel.layer.position = CGPoint(x: myX, y: myY)
        myLabel.numberOfLines = 2
        return myLabel
    }
    
    private func getAllPhotosInfo() {
        // 初期化
        photoAssets = []
        
        // 画像をすべて取得
        let assets: PHFetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        assets.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            self.photoAssets.append(asset as! PHAsset)
        }
        print("写真取得完了")
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