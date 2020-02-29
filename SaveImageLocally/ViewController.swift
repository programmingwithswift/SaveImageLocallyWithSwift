//
//  ViewController.swift
//  SaveImageLocally
//
//  Created by ProgrammingWithSwift on 2020/02/29.
//  Copyright © 2020 ProgrammingWithSwift. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum StorageType {
        case userDefaults
        case fileSystem
    }

    @IBOutlet weak var imageToSaveImageView: UIImageView! {
        didSet {
            imageToSaveImageView.image = UIImage(named: "building")
        }
    }
    
    @IBOutlet weak var saveImageButton: UIButton! {
        didSet {
            saveImageButton.addTarget(self,
                                      action: #selector(ViewController.save),
                                      for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var savedImageDisplayImageView: UIImageView!
    @IBOutlet weak var displaySaveImageButton: UIButton! {
        didSet {
            displaySaveImageButton.addTarget(self,
                                             action: #selector(ViewController.display),
                                             for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func store(image: UIImage,
                       forKey key: String,
                       withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                if let filePath = filePath(forKey: key) {
                    do {
                        try pngRepresentation.write(to: filePath,
                                                    options: .atomic)
                    } catch let err {
                        print("Saving results in error: ", err)
                    }
                }
            case .userDefaults:
                UserDefaults.standard.set(pngRepresentation,
                                          forKey: key)
            }
        }
    }
    
    private func retrieveImage(forKey key: String,
                               inStorageType storageType: StorageType) -> UIImage? {
        switch storageType {
        case .fileSystem:
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData) {
                return image
            }
        case .userDefaults:
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        
        return nil
    }
    
    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: .userDomainMask).first else {
                                                    return nil
        }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    @objc
    private func save() {
        if let buildingImage = UIImage(named: "building") {
            DispatchQueue.global(qos: .background).async {
                self.store(image: buildingImage,
                           forKey: "buildingImage",
                           withStorageType: .fileSystem)
            }
        }
    }
    
    @objc
    private func display() {
        DispatchQueue.global(qos: .background).async {
            if let savedImage = self.retrieveImage(forKey: "buildingImage",
                                                   inStorageType: .fileSystem) {
                DispatchQueue.main.async {
                    self.savedImageDisplayImageView.image = savedImage
                }
            }
        }
    }
    
}

