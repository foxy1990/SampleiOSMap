import UIKit
import MapKit
import CoreLocation

struct Annotation {
    let address: String
    let title: String?
    let subtitle: String?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var myLocationManager:CLLocationManager!
    
    //ロングタップしたときに立てるピンを定義
    var pinByLongPress:MKPointAnnotation!
    
    // ViewControllerのviewがロードされた後
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 完全に遷移が行われ、スクリーン上に表示された時
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startUpdatingLocation()
        
        //        let annotation = Annotation(
        //            address: "東京都新宿区新宿３丁目", title: "YYYY", subtitle: "ZZZ")
        //        add(with: annotation)
        
    }
    
    // 初期設定
    private func configureSubviews() {
        // CLLocationManagerのインスタンス生成
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = 100
        myLocationManager.startUpdatingLocation()
        
        // MKMapViewのdelegate
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
        mapView.userTrackingMode = .followWithHeading
        
    }
    
    private func startUpdatingLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
        default:
            break
        }
        myLocationManager.startUpdatingLocation()
    }
    
    //    // TODO: ピン作成参考実装,後日削除
    //    private func add(with annotation: Annotation) {
    //        // 現在位置取得
    //        CLGeocoder().geocodeAddressString(annotation.address) { [weak self] (placeMarks, error) in
    //            guard let placeMark = placeMarks?.first,
    //                let latitude = placeMark.location?.coordinate.latitude,
    //                let longitude = placeMark.location?.coordinate.longitude else { return }
    //
    //            // ピンの生成
    //            let point = MKPointAnnotation()
    //            point.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    //            point.title = annotation.title
    //            point.subtitle = annotation.subtitle
    //            // MapViewにピン追加
    //            self?.mapView.addAnnotation(point)
    //        }
    //    }
    
    //ロングタップを感知したときに呼び出されるメソッド
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer) {
        
        if(sender.state != UIGestureRecognizer.State.began){
            return
        }
        
        //ロングタップから位置情報を取得
        let location:CGPoint = sender.location(in: mapView)
        
        //取得した位置情報をCLLocationCoordinate2D（座標）に変換
        let longPressedCoordinate:CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        
        // インスタンス作成
        pinByLongPress = MKPointAnnotation()
        
        //ロングタップした位置の座標をピンに入力
        pinByLongPress.coordinate = longPressedCoordinate
        pinByLongPress.title = "LongPressPin"
        pinByLongPress.subtitle = "sub"
        //ピンを追加する（立てる）
        mapView.addAnnotation(pinByLongPress)
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    // アノテーションビューを返すメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // 現在地表示かピンか区別
        if annotation is MKUserLocation {
            return nil
        }

        // アノテーションビューを作成する
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)

        // 吹き出しを表示可能にする
        pinView.canShowCallout = true

        let button = UIButton()
        button.frame = CGRect(x:0,y:0,width:40,height:40)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.green
        button.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)

        // 右側にボタンを追加
        pinView.rightCalloutAccessoryView = button
        return pinView
    }

    // OKボタン押下時の処理
    @objc func sendLocation(){
        let alert = UIAlertController(title: "OKボタン押下後", message: "OKボタン押下後のポップアップ", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title:"OK", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}


// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("位置情報の取得に成功しました")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: nil, message: "位置情報の取得に失敗しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

