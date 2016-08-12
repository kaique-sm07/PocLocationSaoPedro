//
//  IGCValidation.swift
//  PocLocation
//
//  Created by Felipe Eulalio on 12/08/16.
//  Copyright © 2016 Kaique de Souza Monteiro. All rights reserved.
//

import Foundation

class IGCValidation: NSObject
{
	//MARK:- Parameters
	
	/// IGC file to be validated
	var file: String!
	
	/// Pointer to a Hmac context
	private var context: UnsafeMutablePointer<CCHmacContext> = nil
	
	//MARK:- Constants
	
	/// Key for the Hmac
	private let KEY = "M6VLw6RuK33EqX4E6HB74igo17E73QE4"
	
	//MARK:- Methods
	//MARK:- Init Methods
	
	/**
	Init a IGCValidation object with a file name
	- parameter file: The file to be validated
	*/
	convenience init(file: String)
	{
		self.init()
		self.file = file
		
	}
	
	//MARK:- Public Methods
	
	/**
	Generates a validation code for the IGC file
	- returns: The G record to be writen on the file
	*/
	func validateIGC() -> String
	{
		do {
			let content = try String(contentsOfFile: getDocumentsDirectory().stringByAppendingPathComponent(file), encoding: NSUTF8StringEncoding) as String
			let lines = content.componentsSeparatedByString("\n")
			
			context = UnsafeMutablePointer<CCHmacContext>.alloc(1)
			CCHmacInit(context, UInt32(kCCHmacAlgSHA256), KEY, KEY.characters.count)
			
			return parseFile(lines)
			
		} catch {
			print("The file for validation couldn't be opened")
			return ""
		}
	}
	
	//MARK:- Private Methods
	
	/**
	Parse the file and update the Hmac on the correct records from the IGC file
	- returns: The G record
	*/
	private func parseFile(content: [String]) -> String
	{
		for line in content {
			print(line)
			
			if line.hasPrefix("HP") || line.hasPrefix("HO") ||
				(line.hasPrefix("L") && !line.hasPrefix("LLXN")
				|| line.characters.count == 0) {
				// Do nothing
			} else {
				CCHmacUpdate(context, line.stringByAppendingString("\n"), line.characters.count + 1)
			}
		}
		
		return finishValidation()
	}
	
	/**
	Finish the validation and generate a hexadecimal code
	- returns: The G record
	*/
	private func finishValidation() -> String
	{
		var validationCode = Array<UInt8>(count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
		CCHmacFinal(context, &validationCode)
		
		context.dealloc(1)
		
		var gRecordHex = "G"
		
		for byte in validationCode {
			gRecordHex += String(format: "%02X", byte)
		}
		
		gRecordHex += "\n"
		
		print(gRecordHex)
		
		return gRecordHex
	}
	
	/**
	Get the documents directory path
	- returns: The document directory path
	*/
	private func getDocumentsDirectory() -> NSString
	{
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}

}
