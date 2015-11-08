//
//  ViewController.swift
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate
{
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  
  // Debe de ser P indicando que es pasaporte. Index[0]
  var documentType = ""
  // Pais que expide el pasaporte (Debe ser Mexico) Index[2-4]
  var issuingCountry = ""
  // Apellidos y nombre Index[5-43]
  var surName = ""
  var givenName = ""
  // Numero de Pasaporte Index[0-8]
  var passportNumber = ""
  // Nacionalidad. Index[10-12]
  var nationality = ""
  // Fecha de nacimiento. YYMMDD. Index[13-18]
  var birthDate = ""
  // Sexo. M o F o < Index[20]
  var sex = ""
  // Personal Number
  var personalNumber = ""
  // Fecha de expiración del pasaporte. YYMMDD. Index[21-26]
  var expDate = ""
  
  var valoresABC: [String: Int] =
  ["1":1, "2":2,"3":3, "4":4,
    "5":5, "6":6, "7":7, "8":8,
    "9":9, "0":0,
    "A":10, "B":11,"C":12, "D":13,
    "E":14, "F":15, "G":16, "H":17,
    "I":18, "J":19,"K":20, "L":21,
    "M":22, "N":23, "O":24, "P":25,
    "Q":26, "R":27,"S":28, "T":29,
    "U":30, "V":31, "W":32, "X":33,
    "Y":34 ,"Z":35, "<":0]
  
  var activityIndicator:UIActivityIndicatorView!
  var originalTopMargin:CGFloat!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool)
  {
    super.viewDidAppear(animated)
    
    originalTopMargin = topMarginConstraint.constant
  }
  
  @IBAction func takePhoto(sender: AnyObject)
  {
    // 1
    view.endEditing(true)
    moveViewDown()
    
    // 2
    let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
      message: nil, preferredStyle: .ActionSheet)
    
    // 3
    if UIImagePickerController.isSourceTypeAvailable(.Camera)
    {
      let cameraButton = UIAlertAction(title: "Take Photo", style: .Default)
        {
          (alert) -> Void in
          let imagePicker = UIImagePickerController()
          imagePicker.delegate = self
          imagePicker.sourceType = .Camera
          self.presentViewController(imagePicker, animated: true, completion: nil)
      }
      imagePickerActionSheet.addAction(cameraButton)
    }
    
    // 4
    let libraryButton = UIAlertAction(title: "Choose Existing", style: .Default)
      {
        (alert) -> Void in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    imagePickerActionSheet.addAction(libraryButton)
    
    // 5
    let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel)
      {
        (alert) -> Void in
    }
    
    imagePickerActionSheet.addAction(cancelButton)
    
    // 6
    presentViewController(imagePickerActionSheet, animated: true, completion: nil)
  }
  
  @IBAction func sharePoem(sender: AnyObject)
  {
    // 1
    if textView.text.isEmpty
    {
      return
    }
    
    // 2
    let activityViewController = UIActivityViewController(activityItems: [textView.text], applicationActivities: nil)
    
    // 3
    let excludeActivities = [ UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
      UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
    
    activityViewController.excludedActivityTypes = excludeActivities
    
    // 4
    presentViewController(activityViewController, animated: true, completion: nil)
  }
  
  @IBAction func backgroundTapped(sender: AnyObject)
  {
    view.endEditing(true)
    moveViewDown()
  }
  
  // Separa los nombres y quita los '<' sobrantes
  func checkName(strName: String)
  {
    var strSurName = ""
    var strLocalName = ""
    
    let strTemp = strName.stringByReplacingOccurrencesOfString("<<", withString: "+")
    let index = strTemp.characters.indexOf("+")
    
    if(index != nil)
    {
      strLocalName = strTemp.substringFromIndex(index!)
      strSurName = strTemp.substringToIndex(index!)
    }
    strLocalName = strLocalName.stringByReplacingOccurrencesOfString("+", withString: " ")
    strSurName = strSurName.stringByReplacingOccurrencesOfString("<", withString: " ")
    
    self.givenName = strLocalName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    self.surName = strSurName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
  
  // Checa la fecha de nacimiento. No puede ser mayor a la actual.
  func checkBirthDate(strDate: String) -> Bool
  {
    // Checa Fecha de nacimiento
    if Int(strDate[0...1]) > 15 && Int(strDate[0...1]) < 30
    {
      return false
    }
    return true
  }
  
  // Checa la fecha de expiración. Si es anterior a la fecha actual, manda una alerta de vencimiento.
  func checkExpirationDate(strDate: String) -> Bool
  {
    // Checa Fecha de expiracion
    if Int(strDate[0...1]) < 15
    {
      return false
    }
    return true
  }
  
  // Calcula el numero de verificacion para comprarlo contra el que se leyo
  func CheckNumVerif (str: String) -> Int
  {
    var Suma = 0
    var vuelta = 1
    
    for var i = 0; i < str.characters.count; i++
    {
      if vuelta == 1
      {
        Suma += valoresABC[str[i]]! * 7
        vuelta++
      }
      else if vuelta == 2
      {
        Suma += valoresABC[str[i]]! * 3
        vuelta++
      }
      else if vuelta == 3
      {
        Suma += valoresABC[str[i]]! * 1
        vuelta = 1
      }
    }
    return Suma % 10
  }
  
  // Checa todos los datos que se leyeron del pasaporte
  func checkData(var strDatos: String)
  {
    strDatos = strDatos.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    strDatos = strDatos[0...43] + strDatos[46...strDatos.characters.count - 1]
    // Checa que se tenga la cantidad de caracteres correcta
    if strDatos.characters.count < 88 || strDatos.characters.count > 88
    {
      print(strDatos.characters.count, separator: " ", terminator: "\n")
      errorInValidation("Cantidad de caracteres incorrecta")
    }
      
    else
    {
      // Separa los datos en 2 lineas
      let strFirstRow = strDatos[0...43]
      let strSecondRow = strDatos[44...87]
      
      // Checa que el tipo de documento sea pasaporte
      if strFirstRow[0] != "P"
      {
        errorInValidation("Tipo de documento invalido")
        return
      }
      else
      {
        documentType = "P"
      }
      
      // Checa el issuing Country
      if strFirstRow[2...4] != "MEX"
      {
        errorInValidation("No es un pasaporte mexicano")
        return
      }
      else
      {
        issuingCountry = "MEX"
      }
      
      // Checa los nombres y apellidos de las personas
      checkName(strFirstRow[5...43])
      
      // Checa el numero de pasaporte y su numero verificador
      let strPassportNumber = strSecondRow[1...9].stringByReplacingOccurrencesOfString("O", withString: "0")
      if CheckNumVerif(strSecondRow[0].stringByReplacingOccurrencesOfString("0", withString: "O") +
        strPassportNumber[0...7]) != Int(strPassportNumber[8])!
      {
        errorInValidation("Numero de pasaporte incorrecto")
        return
      }
      else
      {
        passportNumber = strSecondRow[0] + strPassportNumber[0...7]
      }
      
      // Checa la nacionalidad
      if strSecondRow[10...12] != "MEX"
      {
        errorInValidation("No es un pasaporte mexicano")
      }
      else
      {
        nationality = "MEX"
      }
      
      // Valida la fecha de nacimiento
      let strBirthDate = strSecondRow[13...19].stringByReplacingOccurrencesOfString("O", withString: "0")
      if(!(checkBirthDate(strBirthDate[0...5])) && CheckNumVerif(strBirthDate[0...5]) != Int(strBirthDate[6])!)
      {
        errorInValidation("Fecha de nacimiento invalida")
        return
      }
      else
      {
        birthDate = strBirthDate[0...5]
      }
      
      // Valida el Sexo
      if strSecondRow[20] != "F" && strSecondRow[20] != "M" && strSecondRow[20] != "<"
      {
        errorInValidation("Error en el sexo")
        return
      }
      else
      {
        sex = strSecondRow[20]
      }
      
      // Valida la fecha de expiracion
      let strExpDate = strSecondRow[21...27].stringByReplacingOccurrencesOfString("O",withString: "0")
      if (!(checkExpirationDate(strExpDate[0...5])) && CheckNumVerif(strExpDate[0...5]) != Int(strExpDate[6])!)
      {
        errorInValidation("Fecha de Expiracion invalida")
        return
      }
      else
      {
        expDate = strExpDate[0...5]
      }
      
      // Checa el personal Number
      if CheckNumVerif(strSecondRow[28...41]) !=
        Int(strSecondRow[42].stringByReplacingOccurrencesOfString("O", withString: "0"))!
      {
        errorInValidation("Personal number invalido")
        return
      }
      else
      {
        personalNumber = strSecondRow[28...41]
      }
      
      var secondPart = strSecondRow[1...9] + strSecondRow[13...19] + strSecondRow[21...43]
      secondPart = secondPart.stringByReplacingOccurrencesOfString("O", withString: "0")
      
      let firstPart = "" + strSecondRow[0].stringByReplacingOccurrencesOfString("0", withString: "O")
      
      if CheckNumVerif(firstPart + secondPart[0...37]) != Int(secondPart[38])
      {
        errorInValidation("Error en el CheckNumber")
        return
      }
    }
  }
  
  func errorInValidation(strError: String)
  {
    print(strError, separator: " ", terminator: "\n")
  }
  
  func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage
  {
    
    var scaledSize = CGSizeMake(maxDimension, maxDimension)
    var scaleFactor:CGFloat
    
    if image.size.width > image.size.height
    {
      scaleFactor = image.size.height / image.size.width
      scaledSize.width = maxDimension
      scaledSize.height = scaledSize.width * scaleFactor
    }
    else
    {
      scaleFactor = image.size.width / image.size.height
      scaledSize.height = maxDimension
      scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
  
  // Metodos del Activity Indicator
  func addActivityIndicator()
  {
    activityIndicator = UIActivityIndicatorView(frame: view.bounds)
    activityIndicator.activityIndicatorViewStyle = .WhiteLarge
    activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
  }
  
  func removeActivityIndicator()
  {
    activityIndicator.removeFromSuperview()
    activityIndicator = nil
  }
  
  // Metodos para el resign del Teclado
  func moveViewUp()
  {
    if topMarginConstraint.constant != originalTopMargin
    {
      return
    }
    
    topMarginConstraint.constant -= 135
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func moveViewDown()
  {
    if topMarginConstraint.constant == originalTopMargin
    {
      return
    }
    
    topMarginConstraint.constant = originalTopMargin
    UIView.animateWithDuration(0.3, animations:
      { () -> Void in
        self.view.layoutIfNeeded()
    })
  }
  
  func performImageRecognition(image: UIImage)
  {
    // 1
    let tesseract = G8Tesseract()
    
    // 2
    tesseract.language = "eng"
    tesseract.charWhitelist = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ<"
    // 3
    tesseract.engineMode = .TesseractCubeCombined
    
    // 4
    tesseract.pageSegmentationMode = .Auto
    
    // 5
    tesseract.maximumRecognitionTime = 60.0
    
    // 6
    tesseract.image = image.g8_blackAndWhite()
    tesseract.recognize()
    
    // 7
    textView.text = tesseract.recognizedText
    textView.editable = true
    
    checkData(textView.text)
    print(documentType + issuingCountry + surName + givenName + passportNumber + nationality + birthDate + sex + personalNumber + expDate, separator: " ", terminator: "\n")
    
    // 8
    removeActivityIndicator()
  }
  
}
extension ViewController: UITextFieldDelegate
{
  func textFieldDidBeginEditing(textField: UITextField)
  {
    moveViewUp()
  }
  
  @IBAction func textFieldEndEditing(sender: AnyObject)
  {
    view.endEditing(true)
    moveViewDown()
  }
  
  func textViewDidBeginEditing(textView: UITextView)
  {
    moveViewDown()
  }
}

extension ViewController: UIImagePickerControllerDelegate
{
  func imagePickerController(picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String: AnyObject])
  {
    let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
    let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
    
    addActivityIndicator()
    
    dismissViewControllerAnimated(true, completion: { self.performImageRecognition(scaledImage) })
  }
}

extension String
{
  subscript (i: Int) -> Character
  {
    return self[self.startIndex.advancedBy(i)]
  }
  
  subscript (i: Int) -> String
  {
    return String(self[i] as Character)
  }
  
  subscript (r: Range<Int>) -> String
  {
    return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
  }
}