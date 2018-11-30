//
//  NFCarDetailsViewController.swift
//  FairTestTask
//
//  Created by Narek Fidanyan on 11/11/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import UIKit
import CoreLocation
import SkyFloatingLabelTextField

class NFCarDetailsViewController: UIViewController {
    
    @IBOutlet weak var providerNameTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var acrissCodeTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var transmissionTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var airConditionerTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var vehicleTypeTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var priceTF: SkyFloatingLabelTextFieldWithIcon!
    
    public var carInfo: AMCar!
    public var pickupLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCarInfo()
    }
    
    private func setupCarInfo() {
        providerNameTF.text  = String(format: "%@ - %.2f miles away", carInfo.carProviderName, carInfo.carDistanceFromCurrentLocation)
        acrissCodeTF.text  = carInfo.acrissCode
        transmissionTF.text = carInfo.transmission
        airConditionerTF.text = carInfo.airConditioning ? "YES" : "NO"
        vehicleTypeTF.text = carInfo.type
        priceTF.text = String.init(format: "$ %d", carInfo.price)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func directionsPressed(_ sender: Any) {
        if let nvc = self.navigationController, let directionsVC = self.storyboard?.instantiateViewController(withIdentifier: "NFDirectionsViewController") as? NFDirectionsViewController {
            directionsVC.sourceLocation = pickupLocation
            directionsVC.destinationLocation = carInfo.carProviderLocation
            nvc.pushViewController(directionsVC, animated: true)
        }
    }
}
