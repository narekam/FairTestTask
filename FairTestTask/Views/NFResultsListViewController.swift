//
//  ResultsListViewController.swift
//  FairTestTask
//
//  Created by Narek Fidanyan on 10/28/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import UIKit
import CoreLocation
import NVActivityIndicatorView

class NFResultsListViewController: UIViewController {
    
    public var networkProvider: NetworkManager!
    public var pickupDate: Date!
    public var dropoffDate: Date!
    public var pickupLocation: CLLocationCoordinate2D!
    
    enum SortType: Int {
        case company = 2000
        case distance = 2001
        case price = 2002
    }
    private var currentSortType: SortType = .company
    private var isOrderDescending = true

    @IBOutlet weak var sortCompanyButton: UIButton!
    @IBOutlet weak var sortDistanceButton: UIButton!
    @IBOutlet weak var sortPriceButton: UIButton!
    @IBOutlet weak var sortTypeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let cellIndentifier = "Cell"
    
    private var rawDataSource: [AMRentalBranch] = []
    private var dataSource: [AMCar] = []
    private var closestProviderLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Localization
        localizeView()
        
        // Fetch data from remote
        fetchData()
    }
    
    private func localizeView() {
        sortCompanyButton.setTitle(NSLocalizedString("k_sort_company", comment: ""), for: .normal)
        sortDistanceButton.setTitle(NSLocalizedString("k_sort_distance", comment: ""), for: .normal)
        sortPriceButton.setTitle(NSLocalizedString("k_sort_price", comment: ""), for: .normal)
    }
    
    private func fetchData() {
        // Show loader
        let activityData = ActivityData.init(size: nil, message: nil, messageFont: nil, messageSpacing: nil, type: .circleStrokeSpin, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        
        // Get data from remote
        networkProvider?.getCars(pickupDate: pickupDate, dropoffDate: dropoffDate, location: pickupLocation, completion: { (result) in
            
            self.rawDataSource = result
            self.prepareData()
            
            self.sortTypePressed(self.sortTypeButton)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        })
    }
    
    private func changeButtonsAppearance() {
        let orangeColor = UIColor(hexString: "FE5A00")
        sortCompanyButton.borderColor = currentSortType == .company ? orangeColor : UIColor.black
        sortDistanceButton.borderColor = currentSortType == .distance ? orangeColor : UIColor.black
        sortPriceButton.borderColor = currentSortType == .price ? orangeColor : UIColor.black
        
        let orderButtonImage = isOrderDescending ? UIImage.init(named: "sort-up") : UIImage.init(named: "sort-down")
        sortTypeButton.setImage(orderButtonImage, for: .normal)
    }

    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func directionsPressed(_ sender: Any) {
        if let nvc = self.navigationController, let directionsVC = self.storyboard?.instantiateViewController(withIdentifier: "NFDirectionsViewController") as? NFDirectionsViewController {
            directionsVC.sourceLocation = pickupLocation
            directionsVC.destinationLocation = closestProviderLocation
            nvc.pushViewController(directionsVC, animated: true)
        }
    }
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        currentSortType = SortType.init(rawValue: button.tag)!
        changeButtonsAppearance()
        
        switch currentSortType {
        case .company:
            if isOrderDescending {
                dataSource.sort(by: { $0.carProviderName > $1.carProviderName })
            } else {
                dataSource.sort(by: { $0.carProviderName < $1.carProviderName })
            }
            
        case .distance:
            if isOrderDescending {
                dataSource.sort(by: { $0.carDistanceFromCurrentLocation > $1.carDistanceFromCurrentLocation })
            } else {
                dataSource.sort(by: { $0.carDistanceFromCurrentLocation < $1.carDistanceFromCurrentLocation })
            }
            
        case .price:
            if isOrderDescending {
                dataSource.sort(by: { $0.price > $1.price })
            } else {
                dataSource.sort(by: { $0.price < $1.price })
            }
        }

        tableView.reloadData()
    }
    
    @IBAction func sortTypePressed(_ sender: Any) {
        isOrderDescending = !isOrderDescending
        
        let button = UIButton()
        button.tag = currentSortType.rawValue
        sortButtonPressed(button)
    }
}

extension NFResultsListViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath)
        
        let aCar = dataSource[indexPath.row]
        let distance = String.init(format: "%.1f m", aCar.carDistanceFromCurrentLocation)
        let price = String.init(format: "$ %d", aCar.price)
        cell.textLabel?.text = "\(aCar.carProviderName) - \(aCar.acrissCode) - \(distance) - \(price)"
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let nvc = self.navigationController, let carDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "NFCarDetailsViewController") as? NFCarDetailsViewController {
            carDetailsVC.carInfo = dataSource.item(at: indexPath.row)
            carDetailsVC.pickupLocation = pickupLocation
            nvc.pushViewController(carDetailsVC, animated: true)
        }
    }
}

extension NFResultsListViewController {
    fileprivate func prepareData() {
        for aBranch in rawDataSource {
            for var aCar in aBranch.cars {
                aCar.carProviderName = aBranch.providerName
                aCar.carProviderLocation = aBranch.providerLocation
                
                let providerCLLocation = CLLocation.init(latitude: aBranch.providerLocation.latitude, longitude: aBranch.providerLocation.longitude)
                let pickupCLLocation = CLLocation.init(latitude: pickupLocation.latitude, longitude: pickupLocation.longitude)
                aCar.carDistanceFromCurrentLocation = pickupCLLocation.distance(from: providerCLLocation) / 1609  // Convert to miles
                
                dataSource.append(aCar)
            }
        }
        
        // Get closest branch Location
        let closestCar: AMCar? = dataSource.min(by: { (a, b) -> Bool in
            return a.carDistanceFromCurrentLocation < b.carDistanceFromCurrentLocation
        })
        closestProviderLocation = closestCar?.carProviderLocation
    }
}
