//
//  ImageHelper.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 11/8/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//




func getImageFromURL(_ urlString:String) -> UIImage? {
    if let image = loadImageFromPath(path: getStoragePath(urlString)) {
        return image
    } else {
        let url = URL(string: urlString)
        if let data = try? Data(contentsOf: url!) {
            saveImage(data: data as NSData, path: getStoragePath(urlString))
            return UIImage(data: data)
        } else {
            print("no image")
            return nil
        }
    }
}

func saveImage(data: NSData, path: String ) -> Bool {
    let fullPath = imageInDocumentsDirectory(path)
    //    let pngImageData = UIImagePNGRepresentation(data)
    var result = false
    result = data.write(toFile: fullPath, atomically: true)
    if result == true {
        addSkipBackupAttributeToItemAtURL(path)
    }
    
    print("saved result: \(result)")
    return result
}



func loadImageFromPath(path: String) -> UIImage? {
    let fullPath = imageInDocumentsDirectory(path)
    if let data = NSData(contentsOfFile: fullPath) {
        let image = UIImage(data: data as Data)
        if image == nil {
            print("missing image at: \(fullPath)")
        } else {
            //        print("Loading image from path: \(fullPath)")
        }
        return image
    } else {
        return nil
    }
}

//------------------------------Helper Functions---------------------------------------------
//-------------------------------------------------------------------------------------------

func imageInDocumentsDirectory(_ filename: String) -> String {
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL!.path
}

func getDocumentsURL() -> NSURL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsURL as NSURL
}

func addSkipBackupAttributeToItemAtURL(_ filePath:String) -> Bool
{
    let filePath = imageInDocumentsDirectory(filePath)
    
    let URL:NSURL = NSURL.fileURL(withPath: filePath) as NSURL
    
    if FileManager.default.fileExists(atPath: filePath) == false {
        return false
    }
    assert(FileManager.default.fileExists(atPath: filePath), "File \(filePath) does not exist")
    
    var success: Bool
    do {
        try URL.setResourceValue(true, forKey:URLResourceKey.isExcludedFromBackupKey)
        success = true
    } catch let error as NSError {
        success = false
        print("Error excluding \(URL.lastPathComponent) from backup \(error)");
    }
    
    return success
}

func getStoragePath(_ string:String) -> String {
    return string.replacingOccurrences(of: "/", with: "SLASH")
}
