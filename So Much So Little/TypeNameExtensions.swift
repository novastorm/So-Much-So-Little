//
//  TypeNameExtensions.swift
//
//  Created by Adland Lee on 11/10/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation

protocol TypeName: AnyObject {
    static var typeName: String { get }
}

extension TypeName {
    static var typeName: String {
        return String(describing: self)
    }
}

extension NSObject: TypeName {
    class var typeName: String {
        return String(describing: self)
    }
    
}
