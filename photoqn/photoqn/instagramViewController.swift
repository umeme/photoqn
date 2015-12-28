import UIKit
import Photos
import SwiftyJSON
import Alamofire

class instagramViewController: UIViewController {
    
    var photoAssets = [PHAsset]()
    private var swipeLabel: UILabel!
    let manager: PHImageManager = PHImageManager()
    var photoNo: Int = 0
    var images = [UIImage]()
    var photoX : CGFloat = 0.0
    var photoY : CGFloat = 0.0
    
    
    
    
    @IBOutlet weak var photoView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoX = photoView.center.x
        photoY = photoView.center.y
        
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
        
        
        let urlString = "https://api.instagram.com/v1/users/self/follows"
        // TODO クライアントIDとアクセストークンについて、認証させる。
        let param = ["client_id": "c7a3c7e767a04403a0b427f094301144","access_token":"2324960265.c7a3c7e.2094777cde3a42a3a54c1e08c02a4c0f"]
        let req = request(.GET, urlString, parameters: param)
        
        var userList = [String]()
        
        dispatch_async_global { // ここからバックグラウンドスレッド
            req.response { (request, response, responseData, error) -> Void in
                if error == nil {
                    if let data = responseData {
                        let json = JSON(data: data)
                        if let array = json["data"].array {
                            for d in array {
                                userList.append(d["id"].string!)
                                print(d["username"].string)
                                print(d["id"].string)
                            }
                        }
                    }
                    
                    print("ここまで１")
                    print(userList.count)
                    
                    for userId in userList {
                        print(userId)
                        let userPhotoListUrl = "https://api.instagram.com/v1/users/\(userId)/media/recent/"
                        let userPhotoListParam = ["access_token":"2324960265.c7a3c7e.2094777cde3a42a3a54c1e08c02a4c0f","count":"100"]
                        let req2 = Alamofire.request(.GET, userPhotoListUrl, parameters: userPhotoListParam)
                        
                        req2.response { (request, response, responseData, error) -> Void in
                            if error == nil {
                                if let data = responseData {
                                    let json = JSON(data: data)
                                    var cnt = 0
                                    if let array = json["data"].array {
                                        for photo in array {
                                            print(photo["images"]["standard_resolution"]["url"].string)
                                            print("test1")
                                            let photoUrl = photo["images"]["standard_resolution"]["url"].string
                                            
                                            let url = NSURL(string:photoUrl!)
                                            let req = NSURLRequest(URL:url!)
                                            print("test2")
                                            //非同期で変換
                                            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                                            let session = NSURLSession(configuration: config)
                                            let task = session.dataTaskWithRequest(req, completionHandler: {
                                                (data, resp, err) in
                                                print("test3")
                                                let iimage = UIImage(data:data!)
                                                self.images.append(iimage!)
                                                
                                                print(cnt)
                                                if cnt == 0 {
                                                    self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
                                                    self.photoView.image = self.images[self.photoNo]
                                                }
                                                cnt++
                                            })
                                            print("test4")
                                            task.resume()
                                            print("test5")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            
            self.dispatch_async_main { // ここからメインスレッド
                self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
                if self.images.count != 0 {
                    self.photoView.image = self.images[self.photoNo]
                } else {
                    let image = UIImage(named: "wait.png")
                    self.photoView.image = image
                }
            }
        }
        
        
        //        req.response { (request, response, responseData, error) -> Void in
        //            if error == nil {
        //                if let data = responseData {
        //                    let json = JSON(data: data)
        //                    if let array = json["data"].array {
        //                        for d in array {
        //                            userList.append(d["id"].string!)
        //                            print(d["username"].string)
        //                            print(d["id"].string)
        //                        }
        //                    }
        //                }
        //
        //                print("ここまで１")
        //                print(userList.count)
        //
        //                for userId in userList {
        //                    print(userId)
        //                    let userPhotoListUrl = "https://api.instagram.com/v1/users/\(userId)/media/recent/"
        //                    let userPhotoListParam = ["access_token":"2324960265.c7a3c7e.2094777cde3a42a3a54c1e08c02a4c0f","count":"1"]
        //                    let req2 = Alamofire.request(.GET, userPhotoListUrl, parameters: userPhotoListParam)
        //
        //                    req2.response { (request, response, responseData, error) -> Void in
        //                        if error == nil {
        //                            if let data = responseData {
        //                                let json = JSON(data: data)
        //                                var cnt = 0
        //                                if let array = json["data"].array {
        //                                    for photo in array {
        //                                        print(photo["images"]["standard_resolution"]["url"].string)
        //                                        print("test1")
        //                                        let photoUrl = photo["images"]["standard_resolution"]["url"].string
        //
        //                                        let url = NSURL(string:photoUrl!)
        //                                        let req = NSURLRequest(URL:url!)
        //                                        print("test2")
        //                                        //非同期で変換
        //                                        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        //                                        let session = NSURLSession(configuration: config)
        //                                        let task = session.dataTaskWithRequest(req, completionHandler: {
        //                                            (data, resp, err) in
        //                                        print("test3")
        //                                            let iimage = UIImage(data:data!)
        //                                            self.images.append(iimage!)
        //
        //                                            print(cnt)
        //                                            if cnt == 0 {
        //                                                self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
        //                                                self.photoView.image = self.images[self.photoNo]
        //                                            }
        //                                            cnt++
        //                                        })
        //                                        print("test4")
        //                                        task.resume()
        //                                        print("test5")
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //
        //            }
        //
        //        }
        
    }
    
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
    
    // MARK: - Gesture Handlers
    func handleTap(sender: UITapGestureRecognizer){
        print("Tapped!:start")
        print("Tapped!:end")
        
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer){
        print("Swiped up!:start")
        if images.count > photoNo {
            photoNo++
            // アニメーション処理
            UIView.animateWithDuration(NSTimeInterval(CGFloat(0.6)),
                animations: {() -> Void in
                    // 移動先の座標を指定する.
                    self.photoView.center = CGPoint(x: self.photoView.center.x, y: -self.view.frame.height);
                }, completion: {(Bool) -> Void in
                    self.photoView.center = CGPointMake(self.photoView.center.x, self.photoY);
                    self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
                    print("photoNo;\(self.photoNo)")
                    print("imageCnt;\(self.images.count)")
                    if self.images.count > self.photoNo {
                        self.photoView.image = self.images[self.photoNo]
                        self.photoView.fadeIn(.Slow)
                    } else {
                        let image = UIImage(named: "noimage.jpeg")
                        self.photoView.image = image
                    }
                    
            })
        }
        print("Swiped up!:end")
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer){
        print("Swiped down!:start")
        if 0 < photoNo {
            print("photoNo;\(photoNo)")
            photoNo--
            // アニメーション処理
            UIView.animateWithDuration(NSTimeInterval(CGFloat(0.6)),
                animations: {() -> Void in
                    // 移動先の座標を指定する.
                    self.photoView.center = CGPoint(x: self.photoView.center.x, y: +self.view.frame.height*2);
                }, completion: {(Bool) -> Void in
                    self.photoView.center = CGPointMake(self.photoView.center.x, self.photoY);
                    self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
                    self.photoView.image = self.images[self.photoNo]
                    self.photoView.fadeIn(.Slow)
            })
        }
        print("Swiped down!:end")
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer){
        print("Swiped Right!:start")
        let targetImage = self.images[photoNo]
        UIImageWriteToSavedPhotosAlbum(targetImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
        if images.count > photoNo {
            
            photoNo++
            // アニメーション処理
            UIView.animateWithDuration(NSTimeInterval(CGFloat(0.6)),
                animations: {() -> Void in
                    // 移動先の座標を指定する.
                    self.photoView.center = CGPoint(x: self.photoView.center.x, y: -self.view.frame.height);
                }, completion: {(Bool) -> Void in
                    self.photoView.center = CGPointMake(self.photoView.center.x, self.photoY);
                    self.photoView.contentMode = UIViewContentMode.ScaleAspectFit
                    print("photoNo;\(self.photoNo)")
                    print("imageCnt;\(self.images.count)")
                    if self.images.count > self.photoNo {
                        self.photoView.image = self.images[self.photoNo]
                        self.photoView.fadeIn(.Slow)
                    } else {
                        let image = UIImage(named: "noimage.jpeg")
                        self.photoView.image = image
                    }
            })
        }
        print("Swiped Right!:end")
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer){
        print("Swiped Left!:start")
        print("Swiped Left!:end")
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        var title = "保存完了"
        var message = "アルバムへの保存完了"
        
        if error != nil {
            title = "エラー"
            message = "アルバムへの保存に失敗しました"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
