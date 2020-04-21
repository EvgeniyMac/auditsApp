//
//  ModuleInput.swift
//  Education
//
//  Created by Andrey Medvedev on 20/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

@objc protocol ModuleInput: class {
    @objc optional func configureWithObject(_ object: Any)
}
