//
//  BibbiAlertAction.swift
//  Core
//
//  Created by 김건우 on 4/18/24.
//

import UIKit

public typealias Action = ((BibbiAlertViewController) -> Void)?
struct BibbiAlertAction {
    var text: String?
    var textColor: UIColor?
    var backgroundColor: UIColor?
    var fontStlye: BibbiFontStyle?
    var action: Action
}
