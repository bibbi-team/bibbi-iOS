//
//  ProfileFeedCollectionViewCell.swift
//  App
//
//  Created by Kim dohyun on 12/18/23.
//

import UIKit

import Core
import DesignSystem
import Kingfisher
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import Then

public final class ProfileFeedCollectionViewCell: BaseCollectionViewCell<ProfileFeedCellReactor> {
    private let feedImageView: UIImageView = UIImageView()
    private let feedStackView: UIStackView = UIStackView()
    private let feedTitleLabel: UILabel = UILabel()
    private let feedUplodeLabel: UILabel = UILabel()
    
    
    public override func prepareForReuse() {
        feedImageView.image = nil
        feedTitleLabel.text = ""
        feedUplodeLabel.text = ""
    }
    
    public override func setupUI() {
        super.setupUI()
        
        feedStackView.addArrangedSubviews(feedTitleLabel, feedUplodeLabel)
        contentView.addSubviews(feedImageView, feedStackView)
        
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        feedImageView.do {
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
        }
        
        feedTitleLabel.do {
            $0.text = "99"
            $0.textColor = .darkGray
            $0.font = .systemFont(ofSize: 14)
            $0.textAlignment = .left
            $0.numberOfLines = 1
        }
        
        feedUplodeLabel.do {
            $0.text = "3월 7일"
            $0.textColor = .darkGray
            $0.font = .systemFont(ofSize: 12)
            $0.textAlignment = .left
            $0.numberOfLines = 1
        }
        
        feedStackView.do {
            $0.distribution = .fillProportionally
            $0.spacing = 4
            $0.axis = .vertical
            $0.alignment = .leading
        }
        
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        feedImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(self.snp.width)
        }
        
        feedStackView.snp.makeConstraints {
            $0.top.equalTo(feedImageView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(36)
        }
        
        
        
    }
    
    
    public override func bind(reactor: ProfileFeedCellReactor) {
        reactor.state
            .map { $0.imageURL }
            .withUnretained(self)
            .bind(onNext: { $0.0.setupProfileFeedImage($0.1)})
            .disposed(by: disposeBag)

        
        reactor.state
            .map { $0.date }
            .asDriver(onErrorJustReturn: "")
            .drive(feedUplodeLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.title }
            .asDriver(onErrorJustReturn: "")
            .drive(feedTitleLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    
    
    
}


extension ProfileFeedCollectionViewCell {
    private func setupProfileFeedImage(_ url: URL) {
        feedImageView.kf.setImage(with: url)
    }
}
