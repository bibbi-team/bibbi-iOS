//
//  BibbiMissionView.swift
//  Core
//
//  Created by Kim dohyun on 5/1/24.
//

import UIKit

import DesignSystem
import SnapKit


public final class BibbiMissionView: UIView {
    
    public let missionBadgeView: UIImageView = UIImageView()
    public let missionTitleView: BibbiLabel = BibbiLabel(.body2Bold, textAlignment: .center, textColor: .mainYellow)
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupAttributes()
        setupAutoLayout()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        addSubviews(missionBadgeView, missionTitleView)
    }
    
    private func setupAttributes() {
        missionBadgeView.do {
            $0.image = DesignSystemAsset.missionTitleBadge.image
        }
        missionTitleView.do {
            $0.text = "tesetstest"
        }
    }
    
    private func setupAutoLayout() {
        missionBadgeView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(18)
        }
        
        missionTitleView.snp.makeConstraints {
            $0.top.equalTo(missionBadgeView.snp.bottom).offset(8)
            $0.height.equalTo(20)
            $0.centerX.equalTo(missionBadgeView)
        }
        
    }
    
    
}

