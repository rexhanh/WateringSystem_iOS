//
//  ViewController.swift
//  WateringSystem
//
//  Created by Yuanrong Han on 3/21/21.
//

import UIKit
import CoreData
import CoreBluetooth
class ViewController: UIViewController {
    // Bluetooth
    private var transferCharacteristic:CBCharacteristic?
    private var centralManager:CBCentralManager!
    private var peripheral:CBPeripheral!
    
    private var safeArea : UILayoutGuide! // Quick Access to self.view.safeAreaLayoutGuide
    private var absoluteWidth : CGFloat!
    private var plantModels : [NSManagedObject] = [] // Fetched Core Data
    private let imagePickerController = UIImagePickerController()
    private var initialLoad = true
    
    //TODO: May need a delegate to exchange data after supporting more devices
    var plant : Plant!
    var needToFetch = true
    private var moistureBar : CircularProgressBar = {
        let bar = CircularProgressBar(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    private var lightBar : CircularProgressBar = {
        let bar = CircularProgressBar(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
       }()
    
    let scrollViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let imageViewContainer : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let progressView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.heightAnchor.constraint(equalToConstant: 250).isActive = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let buttonView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.backgroundColor = .clear
        return view
    }()
    
    private var imageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Home"
        self.safeArea = self.view.safeAreaLayoutGuide
        self.absoluteWidth = min(self.view.frame.width, self.view.frame.height)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        fetchData()
        setupPlant()
        setupBarValues()
        setupContainer()
        setupImage()
        setupProgressBars()
        setupBaritems()
        setupImagePickerController()
        setupButtons()
    }
    
    // MARK: View Setup Functions, and Plant Setup Funtion
    
    private func setupPlant() {
        if plantModels.count > 0 {
            let fetchedPlant = plantModels[0]
            let light = CGFloat(fetchedPlant.value(forKey: "light") as! Int16)
            let moisture = CGFloat(fetchedPlant.value(forKey: "moisture") as! Int16)
            var image : UIImage
            if let imagedata = fetchedPlant.value(forKey: "image") as? Data {
                image = UIImage(data: imagedata)!
            } else {
                image = UIImage(named: "default")!
            }
            let plantname = "Plant Name Holder"
            let p = Plant(moisture: moisture, light: light, name: plantname, plantImage: image)
            self.plant = p
        } else {
            self.plant = Plant(moisture: 0, light: 0, name: "", plantImage: UIImage(named: "default")!)
        }
    }
    
    
    private func setupBaritems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(changeImage(sender:)))
    }
    
    private func setupImagePickerController() {
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
    }

    
    
    private func setupContainer() {
        self.view.addSubview(self.scrollView)
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.addArrangedSubview(imageViewContainer)
        scrollViewContainer.addArrangedSubview(progressView)
        scrollViewContainer.addArrangedSubview(buttonView)
        
        scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor,constant: 10).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10).isActive = true
        scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: -10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        
        scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func setupImage() {
        self.imageView = UIImageView(image: self.plant.plantImage)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 95
        imageView.layer.masksToBounds = true
        
        
        self.imageViewContainer.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 190).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 190).isActive = true
        imageView.centerXAnchor.constraint(equalTo: imageViewContainer.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: imageViewContainer.centerYAnchor).isActive = true
        
    }
    
    private func setupProgressBars() {
        self.progressView.addSubview(moistureBar)
        self.progressView.addSubview(lightBar)
        
        moistureBar.color = .skyBlue
        lightBar.color = .sunYellow
        
        moistureBar.centerXAnchor.constraint(equalTo: progressView.centerXAnchor, constant: -absoluteWidth / 4).isActive = true
        moistureBar.centerYAnchor.constraint(equalTo: progressView.centerYAnchor, constant: -20).isActive = true
        moistureBar.widthAnchor.constraint(equalToConstant: absoluteWidth / 3).isActive = true
        moistureBar.heightAnchor.constraint(equalTo: moistureBar.widthAnchor).isActive = true
        
        lightBar.centerXAnchor.constraint(equalTo: progressView.centerXAnchor, constant: absoluteWidth / 4).isActive = true
        lightBar.centerYAnchor.constraint(equalTo: progressView.centerYAnchor, constant: -20).isActive = true
        lightBar.widthAnchor.constraint(equalToConstant: absoluteWidth / 3).isActive = true
        lightBar.heightAnchor.constraint(equalTo: lightBar.widthAnchor).isActive = true
    }
    
    private func setupBarValues() {
        self.lightBar.label.text = "Light\n\(Int(plant.getLightPercentage() * 100))%"
        self.moistureBar.label.text = "Moisture\n\(Int(plant.getMoisturePercentage() * 100))%"
        
        self.lightBar.progress = plant.getLightPercentage()
        self.moistureBar.progress = plant.getMoisturePercentage()
    }
    
    private func setupButtons() {
        let onoffSwitch:UISwitch = {
            let s = UISwitch()
            s.translatesAutoresizingMaskIntoConstraints = false
            return s
        }()
        self.buttonView.addSubview(onoffSwitch)
        onoffSwitch.addTarget(self, action: #selector(handleswitch(sender:)), for: .valueChanged)
        
        onoffSwitch.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor).isActive = true
        onoffSwitch.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor).isActive = true
        
    }
    // MARK: @objc Functions
    // Handles Image Button
    @objc private func changeImage(sender:UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Photo Libarary", style: .default, handler: {action in
            self.present(self.imagePickerController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {action in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Default Image", style: .default, handler: {action in
            self.plant.plantImage = UIImage(named: "default")!
            self.imageView.image = self.plant.plantImage
        }))
        self.present(alert, animated: true)
    }
    
    
    
    // Handles Switch State Change
    @objc private func handleswitch(sender: UISwitch) {
        sender.isOn ? writeValue(data: "1") : writeValue(data: "0")
    }
    
    // MARK: Fetch Core Data
    private func fetchData() {
        if (needToFetch) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchPlantRequest = NSFetchRequest<NSManagedObject>(entityName: "PlantModel")
            do {
                plantModels = try managedContext.fetch(fetchPlantRequest)
            } catch let error as NSError {
                print("Cannot fetch or data is empty. \(error), \(error.localizedDescription), \(error.userInfo)")
            }
            
            
        } else {
            //TODO: Second view returing check if needs to fetch
            needToFetch = true
        }
    }
    // MARK: Core Data Save and Delete
    // Delete Core Data before add a new one. Will be changed after supporting more devices
    private func delete() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlantModel")
        fetchRequest.includesPropertyValues = false
        do {
            let items = try managedContext.fetch(fetchRequest)
            for i in 0..<items.count{
                managedContext.delete(items[i])
            }
            try managedContext.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func save() {
        delete()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "PlantModel", in: managedContext)!
        let plant = NSManagedObject(entity: entity, insertInto: managedContext)
        plant.setValue(self.plant.light, forKey: "light")
        plant.setValue(self.plant.moisture, forKey: "moisture")
        let imagedata = self.plant.plantImage.pngData()
        plant.setValue(imagedata, forKey: "image")
        do {
            try managedContext.save()
        } catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
    }

    // MARK: Util Functions
    private func updateMoisture(to value: CGFloat) {
        self.plant.updateMoisture(to: value)
        let moisturePercent = plant.getMoisturePercentage()
        self.moistureBar.progress = moisturePercent
        self.moistureBar.label.text = "Moisture\n\(Int(moisturePercent * 100))%"
    }
    
    private func updateLight(to value: CGFloat) {
        self.plant.updateLight(to: value)
        let lightPercent = plant.getLightPercentage()
        self.lightBar.progress = lightPercent
        self.lightBar.label.text = "Light\n\(Int(lightPercent * 100))%"
    }
    
    // Write data to Peripheral
    private func writeValue(data: String) {
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        guard let peripheral = self.peripheral, let characteristic = self.transferCharacteristic else {return}
        peripheral.writeValue(valueString!, for: characteristic, type: .withoutResponse)
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.plant.plantImage = image
            self.imageView.image = image
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager.scanForPeripherals(withServices: [BLE_Device.defaultserviceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.centralManager.stopScan()
        self.centralManager.connect(self.peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral.discoverServices(nil)
    }
}

// MARK: CoreBluetooth Delegates
extension ViewController : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
        guard let services = peripheral.services else {return}
        peripheral.discoverCharacteristics(nil, for: services[0])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
        guard let characteristics = service.characteristics else {return}
        for char in characteristics {
            if char.uuid.uuidString == "FFE1" {
                self.transferCharacteristic = char
            }
            peripheral.readValue(for: char)
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == "FFE1" {
            guard let cdata = characteristic.value else {return}
            let intdata = [UInt8](cdata)
            if self.initialLoad {
                self.initialLoad = false
            } else {
                updateMoisture(to: CGFloat(Util.sensorValueRecover(from: intdata[0])))
                updateLight(to: CGFloat(Util.sensorValueRecover(from: intdata[1])))
            }
            self.moistureBar.setNeedsDisplay()
            self.lightBar.setNeedsDisplay()
        }
    }
}

