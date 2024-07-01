//
//  BaseView.swift
//  Core
//
//  Created by geonhui Yu on 12/8/23.
//

import UIKit

import ReactorKit
import RxSwift

open class BaseView<R>: UIView, ReactorKit.View where R: Reactor {
    public typealias Reactor = R
    
    // MARK: - Properties
    public var disposeBag: RxSwift.DisposeBag = DisposeBag()
    
    // MARK: - Intializer
    public convenience init(reactor: Reactor? = nil) {
        self.init(frame: .zero)
        self.reactor = reactor
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helpers
    // 리액터와 바인딩을 위한 메서드
    open func bind(reactor: R) { }
    
    // 서브 뷰 추가를 위한 메서드
    open func setupUI() { }
    
    // 오토레이아웃 설정을 위한 메서드
    open func setupAutoLayout() { }
    
    // 뷰의 속성 설정을 위한 메서드
    open func setupAttributes() { }
}
