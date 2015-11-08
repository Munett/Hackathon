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
  var documentType: String!
  // Pais que expide el pasaporte (Debe ser Mexico) Index[2-4]
  var issuingCountry: String!
  // Apellidos y nombre Index[5-43]
  var surName: String!
  var givenName: String!
  // Numero de Pasaporte Index[0-8]
  var passportNumber: String!
  // Digito de verificacion de pasaporte. Index[9]
  var passVerNumber: Int!
  // Nacionalidad. Index[10-12]
  var nationality: String!
  // Fecha de nacimiento. YYMMDD. Index[13-18]
  var dateOfBirth: Int!
  // Digito de verificacion de fecha de nacimiento. Index[19]
  var birthVerNumber: Int!
  // Sexo. M o F o < Index[20]
  var sex: String!
  // Fecha de expiración del pasaporte. YYMMDD. Index[21-26]
  var expDate: Int!
  // Digito de verificacion de expiracion. Index[27]
  var expVerNumber: Int!
  // Digito de verificacion del personal number. (Es cero). Index[42]
  var perVerNumber: Int!
  // Digito verificador num pasaporte, de fecha de nacimiento, expiracion y personal number
  var lastVerNumber: Int!
  
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
    
  }
  
  // Checa el numero de Pasaporte.
  func checkPassportNumber(strNumber: String)
  {
    
  }
  
  // Checa la fecha de nacimiento. No puede ser mayor a la actual.
  func checkBirthDate(strDate: String)
  {
    
  }
  
  // Checa la fecha de expiración. Si es anterior a la fecha actual, manda una alerta de vencimiento.
  func checkExpirationDate(strDate: String)
  {
    
  }
  
  // Calcula el numero de verificacion para comprarlo contra el que se leyo
  func verificationNumber(strNumber: String) -> Int
  {
    return 0
  }
  
  // Checa todos los datos que se leyeron del pasaporte
  func checkData(strDatos: String)
  {
    // Checa que se tenga la cantidad de caracteres correcta
    if strDatos.characters.count < 88 || strDatos.characters.count > 88
    {
      errorInValidation("Cantidad de caracteres incorrecta")
    }
    
    else
    {
      // Separa los datos en 2 lineas
      let strFirstRow = strDatos[0...43]
      let strSecondRow = strDatos[43...87]
      
      // Checa que el tipo de documento sea pasaporte
      if strFirstRow[0] != "P"
      {
        errorInValidation("Tipo de documento invalido")
      }
      else
      {
        documentType = "P"
      }
      
      // Checa el issuing Country
      if strFirstRow[2...4] != "MEX"
      {
        errorInValidation("No es un pasaporte mexicano")
      }
      else
      {
        issuingCountry = "MEX"
      }
      
      // Checa los nombres y apellidos de las personas
      checkData(strFirstRow[5...43])
      
      // Checa el numero de pasaporte y su numero verificador
      checkPassportNumber(strSecondRow[0...9])
      
      // Checa la nacionalidad
      if strSecondRow[10...12] != "MEX"
      {
        errorInValidation("No es un pasaporte mexicano")
      }
      else
      {
        nationality = "MEX"
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
