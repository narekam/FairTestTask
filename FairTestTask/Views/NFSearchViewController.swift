//
//  NFSearchViewController.swift
//  FairTestTask
//
//  Created by Narek Fidanyan on 10/25/18.
//  Copyright © 2018 Narek Fidanyan. All rights reserved.
//

import UIKit
import CoreLocation
import SkyFloatingLabelTextField
import FontAwesome_swift
import DateToolsSwift

class NFSearchViewController: UIViewController {
    
    enum SearchVCTextFieldType: Int {
        case addressTF = 1000
        case pickupTF = 1001
        case dropoffTF = 1002
    }
    
    @IBOutlet weak var addressTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var pickupDateTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var dropoffDateTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var searchButton: UIButton!
    
    private var pickupDate: Date = Date()
    private var dropoffDate: Date = Date()
    private var pickupLocation: CLLocation?
    private var activeTextField: SearchVCTextFieldType = .addressTF
    private var dateFormatter: DateFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Localization
        localizeView()
        
        // Prepare textfields
        setupTextFields()
        
        // Some init
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "E, MMM d, h:mm a"
    }
    
    private func localizeView() {
        addressTextField.placeholder = NSLocalizedString("k_address_label", comment: "")
        pickupDateTextField.placeholder = NSLocalizedString("k_pickup_date", comment: "")
        dropoffDateTextField.placeholder = NSLocalizedString("k_dropoff_date", comment: "")
        searchButton.setTitle(NSLocalizedString("k_search", comment: "").uppercased(), for: .normal)
    }
    
    private func setupTextFields() {
        addressTextField.iconFont = UIFont.fontAwesome(ofSize: 20)
        pickupDateTextField.iconFont = UIFont.fontAwesome(ofSize: 17)
        dropoffDateTextField.iconFont = UIFont.fontAwesome(ofSize: 17)
        addressTextField.iconText = " \u{f124}"
        pickupDateTextField.iconText = " \u{f133}"
        dropoffDateTextField.iconText = " \u{f133}"
    }
    
    private func showAddressPicker() {
        let alert = UIAlertController(style: .actionSheet)
        alert.addLocationPicker { location in
            self.pickupLocation = location?.location
            self.addressTextField.text = location?.shortAddress
        }
        alert.addAction(title: NSLocalizedString("k_done", comment: "").uppercased(), style: .cancel)
        alert.show()
    }
    
    private func showDatePicker(date: Date, minDate: Date, maxDate: Date, message: String) {
        
        let alert = UIAlertController(style: .actionSheet, title: NSLocalizedString("k_please_select", comment: ""))
        alert.addDatePicker(mode: .dateAndTime, date: date, minimumDate: minDate, maximumDate: maxDate) { date in
            
            switch self.activeTextField {
            case .pickupTF:
                self.pickupDate = date
                self.pickupDateTextField.text = self.dateFormatter?.string(from: date)
                
            case .dropoffTF:
                self.dropoffDate = date
                self.dropoffDateTextField.text = self.dateFormatter?.string(from: date)
                
            default:
                break
            }
        }
        alert.set(message: message, font: .systemFont(ofSize: 16), color: .black)
        alert.addAction(title: NSLocalizedString("k_done", comment: "").uppercased(), style: .cancel)
        alert.show()
    }
    
    internal func validateSearchParams(location: CLLocation?, pickupDate: String?, dropoffDate: String?) -> Bool {
        if let _ = location, pickupDate?.count > 0, dropoffDate?.count > 0 {
            return true
        }
        return false
    }

    @IBAction func searchPressed(_ sender: Any) {
        if validateSearchParams(location: pickupLocation, pickupDate: pickupDateTextField.text, dropoffDate: dropoffDateTextField.text) {
            navigateToResultListVC()
        } else {
            let alert = UIAlertController(style: .alert, title: NSLocalizedString("k_fill_all_fields", comment: ""), message: nil)
            alert.addAction(title: NSLocalizedString("k_ok", comment: ""), style: .cancel)
            alert.show()
        }
    }
    
    private func navigateToResultListVC() {
        if let nvc = self.navigationController, let resultsVC = self.storyboard?.instantiateViewController(withIdentifier: "NFResultsListViewController") as? NFResultsListViewController {
            
            resultsVC.networkProvider = NetworkManager()
            resultsVC.pickupDate = pickupDate
            resultsVC.dropoffDate = dropoffDate
            resultsVC.pickupLocation = pickupLocation?.coordinate
            
            nvc.pushViewController(resultsVC, animated: true)
        }
    }
}

extension NFSearchViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeTextField = SearchVCTextFieldType.init(rawValue: textField.tag)!
        
        switch activeTextField {
        case .addressTF:
            showAddressPicker()
            
        case .pickupTF:
            showDatePicker(date: pickupDate, minDate: Date(), maxDate: Date().add(1.years), message: NSLocalizedString("k_pickup_date", comment: ""))
            
        case .dropoffTF:
            showDatePicker(date: dropoffDate, minDate: pickupDate.add(1.days), maxDate: pickupDate.add(3.months), message: NSLocalizedString("k_dropoff_date", comment: ""))
        }
        
        return false
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SkyFloatingLabelTextFieldWithIcon {
    func addPadding() {
        let paddingView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 12, height: 1))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
