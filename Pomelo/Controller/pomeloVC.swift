//
//  pomeloVC.swift
//  Pomelo
//
//  Created by Unnikrishnan Parameswaran on 23/06/20.
//  Copyright © 2020 Unnikrishnan Parameswaran. All rights reserved.
//


import UIKit
import CoreLocation
import NVActivityIndicatorView
import GSMessages

class pomeloVC: UIViewController ,NVActivityIndicatorViewable{
    //MARK:- variables
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet var tbl: UITableView!
    private let presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
    var currentSortCategories = [String]()
    var locationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var toolbar: UIToolbar!
    var latitude :Double!
    var longitude:Double!
    var allLocations = [Location]()
    var selectedRow  =  -1
    var ascending = false
    let size = CGSize(width: 50, height: 50)
    var barBtnLocation = UIBarButtonItem()
    var selectedIndicatorIndex = 32//indicator type
    
    //MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    override func viewWillAppear(_ animated: Bool) {
        lblStatus.isHidden = true
        loadTable()
    }
   
}
extension pomeloVC{
    //MARK:- Actions
    @IBAction func refreshAction(_ sender: Any) {
         loadTable()
       }
    @IBAction func sortAction(_ sender: Any) {
        if latitude != nil{
            sortbtnAction()
        }else{
            self.showMessage("Please fetch your current location", type: .warning)
        }
    }
    @objc func getCurrentLocation(sender: UIButton!) {
           scanLocation()
       }
}
extension pomeloVC{
     //MARK:- Private methods
    fileprivate func show_NVActivityAlert(Text:String){
        stop_NVActivity()
        let indicatorType = presentingIndicatorTypes[selectedIndicatorIndex]
        startAnimating(size, message: Text, type: indicatorType, fadeInAnimation: nil)
        NVActivityIndicatorPresenter.sharedInstance.setMessage(Text)
    }
    fileprivate func stop_NVActivity(){
        stopAnimating()
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    fileprivate func scanLocation(){
        if NetworkReachability.sharedNetwork.connectedToNetwork(){
            if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                show_NVActivityAlert(Text: "Fetching current location")
                locationManager.requestLocation()
                break
            default:
                break
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            //"Location services are not enabled"
        }
        }else{
            self.tbl.isHidden = true
            lblStatus.isHidden = false
            self.showMessage("No network", type: .warning)
        }
    }
    fileprivate func setupNavBar() {
        navigationItem.title = "Pomelo"
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        barBtnLocation = UIBarButtonItem(image: UIImage(named: "pin"), style: .plain, target: self, action: #selector(getCurrentLocation(sender:)))
        self.navigationItem.rightBarButtonItems = [barBtnLocation]
        self.toolbar.backgroundColor = .white
         self.toolbar.barTintColor = .white
    }
}
extension pomeloVC{
    //MARK:- Helpers
    func syncLocations(locations: [CLLocation]) {
        let tempLocation = allLocations
        allLocations = []
        var active = Bool()
        var address1 = ""
        var city = ""
        var alias = ""
        var dlongitude = Double()
        var dlatitude =  Double()
        let current_location:CLLocation = locations[0]
        
        latitude = current_location.coordinate.latitude
        longitude = current_location.coordinate.longitude
        
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        for element in tempLocation{
            alias = element.alias!
            active = element.active!
            address1 = element.address1!
            city = element.city!
            dlongitude = element.longitude!
            dlatitude = element.latitude!
            let DestinationLocation = CLLocation(latitude: dlatitude, longitude: dlongitude)
            let totalDistance = currentLocation.distance(from: DestinationLocation) / 1000
            allLocations.append(Location.init(address1: address1, city: city, active: active, latitude: dlatitude, longitude: dlongitude, alias: alias, distance: totalDistance)!)
        }
        self.ascending = true
        self.allLocations = self.allLocations.sorted { $0.distance! < $1.distance!}
        stop_NVActivity()
        DispatchQueue.main.async {
            self.tbl.reloadData()
        }
    }
    func loadTable(){
        self.tbl.isHidden = false
         lblStatus.isHidden = true
        if NetworkReachability.sharedNetwork.connectedToNetwork(){
            show_NVActivityAlert(Text: "")
        self.allLocations = []
        Service.sharedService.fetchLocations{ (Locations, succeed) in
            if succeed == false{
                self.stop_NVActivity()
                self.tbl.isHidden = true
                self.lblStatus.text = "Server unavailable"
                self.lblStatus.isHidden = false
                self.showMessage("Server unavailable", type: .warning)
                return
            }
            for element in Locations{
                var active = Bool()
                var address1 = ""
                var city = ""
                var alias = ""
                var longitude = Double()
                var latitude =  Double()
                if (element["active"] != nil){
                    active = (element["active"] != nil)
                }
                if element["address1"] as? String != nil{
                    address1 = element["address1"] as! String
                }
                if element["city"] as? String != nil{
                    city = element["city"] as! String
                }
                if element["alias"] as? String != nil{
                    alias = element["alias"] as! String
                }
                if element["longitude"] as? Double != nil{
                    longitude = element["longitude"] as! Double
                }
                if element["latitude"] as? Double != nil{
                    latitude = element["latitude"] as! Double
                }
                
                self.allLocations.append(Location.init(address1: address1, city: city, active: active, latitude: latitude, longitude: longitude, alias: alias, distance: 0.0)!)
            }
            self.stop_NVActivity()
            DispatchQueue.main.async {
                self.tbl.reloadData()
            }
        }
        }else{
            self.tbl.isHidden = true
            lblStatus.isHidden = false
            self.lblStatus.text = "No network"
            self.showMessage("No network", type: .warning)
        }
    }
    @objc func sortbtnAction() {
           var SortAlert = UIAlertController()
        SortAlert = UIAlertController(title: "Sort by distance from your current location", message: nil, preferredStyle:(UIDevice.current.userInterfaceIdiom == .pad) ? .alert : .actionSheet)
           SortAlert.addAction(UIAlertAction(title: "Distance Ascending", style: .default, handler: { action in
               self.ascending = true
               self.allLocations = self.allLocations.sorted { $0.distance! < $1.distance!}
               DispatchQueue.main.async {
                   self.tbl.reloadData()
               }
               
           }))
           SortAlert.addAction(UIAlertAction(title: "Distance Descending", style: .default, handler: { action in
               self.ascending = false
               self.allLocations = self.allLocations.sorted { $0.distance! > $1.distance!}
               DispatchQueue.main.async {
                   self.tbl.reloadData()
               }
           }))
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
           cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
           SortAlert.addAction(cancelAction)
           if latitude != nil{
               if ascending{
                   SortAlert.actions[0].setValue(true, forKey: "checked")
               }else{
                   SortAlert.actions[1].setValue(true, forKey: "checked")
               }
           }
           self.present(SortAlert, animated: true, completion: nil)
       }
}

extension pomeloVC: UITableViewDelegate,UITableViewDataSource{
    //MARK:- Tableview delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLocations.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  80
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        var lblTitle = UILabel()
        var lblSubTitle = UILabel()
        var lblBottomTitle = UILabel()
        var lblDistance = UILabel()
        var imageView = UIImageView()
        
        lblTitle = cell?.viewWithTag(100) as! UILabel
        lblSubTitle = cell?.viewWithTag(101) as! UILabel
        lblBottomTitle = cell?.viewWithTag(102) as! UILabel
        lblDistance = cell?.viewWithTag(103) as! UILabel
        imageView = cell?.viewWithTag(50) as! UIImageView
        
        if allLocations.count > 0{
            let locationData = allLocations[indexPath.row]
            lblTitle.text = "City: " + locationData.city!
            lblSubTitle.text = "Address: " + locationData.address1!
            lblBottomTitle.text = "Alias : " + locationData.alias!
            let doubleStr = String(format: "%.2f", locationData.distance ?? 0.0)
            lblDistance.text = doubleStr + " km"
            if selectedRow == indexPath.row{
                imageView.image = UIImage(named: "correct")
            }else{
                imageView.image = UIImage(named: "dot")
            }
        }
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        cell!.selectedBackgroundView = view
        cell!.backgroundColor = .white
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRow == indexPath.row{
            selectedRow = -1
        }else{
            selectedRow = indexPath.row
        }
        DispatchQueue.main.async {
            self.tbl.reloadData()
        }
    }
}
extension pomeloVC: CLLocationManagerDelegate{
    //MARK:- Location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let userLocation =  locations.last! as CLLocation
        syncLocations(locations: [userLocation])
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.stop_NVActivity()
    }
    
}
