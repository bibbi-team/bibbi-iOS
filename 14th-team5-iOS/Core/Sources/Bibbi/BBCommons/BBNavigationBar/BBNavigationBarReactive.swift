//
//  BBNavigationBarRx.swift
//  Core
//
//  Created by 김건우 on 8/11/24.
//

import Foundation

import RxSwift

public extension Reactive where Base: BBNavigationBar {
    
    var isHiddenLeftBarButtonNewMark: Binder<Bool> {
        Binder(self.base) { navigationBar, isHidden in
            navigationBar.isHiddenLeftBarButtonNewMark = isHidden
        }
    }
    
}
