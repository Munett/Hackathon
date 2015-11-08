//
//  Passport.swift
//  MyPass
//
//  Created by Alejandro De la Rosa Cortés on 08/11/15.
//  Copyright © 2015 ARC. All rights reserved.
//

import UIKit
import CoreData

class Passport: NSManagedObject
{

}

extension Passport {
  
  @NSManaged var givenName: String?
  @NSManaged var documentType: String?
  @NSManaged var surName: String?
  @NSManaged var passportNumber: String?
  @NSManaged var nationality: String?
  @NSManaged var birthDate: String?
  @NSManaged var sex: String?
  @NSManaged var expDate: String?
  @NSManaged var personalNumber: String?
  @NSManaged var issuingCountry: String?
  
  class func createInManagedObjectContext
    (moc: NSManagedObjectContext, documentType: String, issuingCountry: String, surName: String,
    givenName: String, passportNumber: String, nationality: String, birthDate: String, sex: String,
    personalNumber: String, expDate: String) -> Passport
  {
    let newItem = NSEntityDescription.insertNewObjectForEntityForName("Passport", inManagedObjectContext: moc) as! Passport
    
    newItem.documentType = documentType
    newItem.issuingCountry = issuingCountry
    newItem.surName = surName
    newItem.givenName = givenName
    newItem.passportNumber = passportNumber
    newItem.nationality = nationality
    newItem.birthDate = birthDate
    newItem.sex = sex
    newItem.personalNumber = personalNumber
    newItem.expDate = expDate
    
    return newItem
  }
}