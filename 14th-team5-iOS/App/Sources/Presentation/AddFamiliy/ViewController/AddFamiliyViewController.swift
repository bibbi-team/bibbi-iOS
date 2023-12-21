//
//  LinkShareViewController.swift
//  App
//
//  Created by 김건우 on 12/11/23.
//

import UIKit

import Core
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import Then

public final class AddFamiliyViewController: BaseViewController<AddFamiliyViewReactor> {
    // MARK: - Views
    private let backgroundView: UIView = UIView()
    private let imageBackgroundView: UIView = UIView()
    private let envelopeImageView: UIImageView = UIImageView()
    
    private let titleStackView: UIStackView = UIStackView()
    private let addFamiliyTitleLabel: UILabel = UILabel()
    private let addFamimliySubTitleLabel: UILabel = UILabel()
    private let shareInvitationUrlButton: UIButton = UIButton(type: .system)
    
    private let dividerView: UIView = UIView()
    
    private let tableHeaderStackView: UIStackView = UIStackView()
    private let familiyMemeberTitleLabel: UILabel = UILabel()
    private let familiyMemberCountLabel = UILabel()
    private let tableView: UITableView = UITableView()
    
    // MARK: - Properties
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfFamiliyMemberProfile> = RxTableViewSectionedReloadDataSource<SectionOfFamiliyMemberProfile> { datasource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: YourFamilyProfileCell.id, for: indexPath) as! YourFamilyProfileCell
        cell.reactor = YourFamilProfileCellReactor(TempProfileCellModel(memberId: item.memberId, name: item.name, imageUrl: item.imageUrl))
        return cell
    }
    
    // MARK: - Lifecycles
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Helpers
    public override func setupUI() {
        super.setupUI()
        view.addSubview(backgroundView)
        backgroundView.addSubviews(
            imageBackgroundView, envelopeImageView, titleStackView, shareInvitationUrlButton
        )
        titleStackView.addArrangedSubviews(
            addFamiliyTitleLabel, addFamimliySubTitleLabel
        )
        view.addSubviews(
            dividerView, tableHeaderStackView, tableView
        )
        tableHeaderStackView.addArrangedSubviews(
            familiyMemeberTitleLabel, familiyMemberCountLabel
        )
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        backgroundView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(AddFamiliyVC.AutoLayout.defaultOffsetValue)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(AddFamiliyVC.AutoLayout.backgroundViewTopOffsetValue)
            $0.trailing.equalTo(view.snp.trailing).offset(-AddFamiliyVC.AutoLayout.defaultOffsetValue)
            $0.height.equalTo(AddFamiliyVC.AutoLayout.backgroundViewHeightValue)
        }
        
        imageBackgroundView.snp.makeConstraints {
            $0.leading.equalTo(backgroundView.snp.leading).offset(AddFamiliyVC.AutoLayout.defaultOffsetValue)
            $0.width.height.equalTo(AddFamiliyVC.AutoLayout.imageBackgroundViewHeightValue)
            $0.centerY.equalTo(backgroundView.snp.centerY)
        }
        
        envelopeImageView.snp.makeConstraints {
            $0.width.height.equalTo(AddFamiliyVC.AutoLayout.envelopeImageViewHeightValue)
            $0.center.equalTo(imageBackgroundView.snp.center)
        }
        
        titleStackView.snp.makeConstraints {
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(AddFamiliyVC.AutoLayout.defaultOffsetValue)
            $0.centerY.equalTo(backgroundView.snp.centerY)
        }
        
        shareInvitationUrlButton.snp.makeConstraints {
            $0.trailing.equalTo(backgroundView.snp.trailing).offset(-AddFamiliyVC.AutoLayout.shareInvitationUrlButtonTrailingOffsetValue)
            $0.centerY.equalTo(backgroundView.snp.centerY)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading)
            $0.top.equalTo(backgroundView.snp.bottom).offset(AddFamiliyVC.AutoLayout.dividerViewTopOffsetValue)
            $0.trailing.equalTo(view.snp.trailing)
            $0.height.equalTo(1.0)
        }
        
        tableHeaderStackView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(AddFamiliyVC.AutoLayout.defaultOffsetValue)
            $0.top.equalTo(dividerView.snp.bottom).offset(AddFamiliyVC.AutoLayout.tableHeaderStackViewTopOffsetValue)
        }
        
        tableView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading)
            $0.top.equalTo(tableHeaderStackView.snp.bottom).offset(AddFamiliyVC.AutoLayout.tableViewTopOffsetValue)
            $0.trailing.equalTo(view.snp.trailing)
            $0.bottom.equalTo(view.snp.bottom)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        // TODO: - 이미지・색상・폰트 다시 설정하기
        backgroundView.do {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = AddFamiliyVC.Attribute.backgroundViewCornerRadius
            $0.backgroundColor = UIColor.darkGray
        }
        
        imageBackgroundView.do {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = AddFamiliyVC.AutoLayout.imageBackgroundViewHeightValue / 2.0
            $0.backgroundColor = UIColor.systemGreen
        }
        
        envelopeImageView.do {
            $0.contentMode = .scaleAspectFill
        }
        
        titleStackView.do {
            $0.axis = .vertical
            $0.spacing = 5.0
            $0.alignment = .leading
            $0.distribution = .fillProportionally
        }
        
        addFamiliyTitleLabel.do {
            $0.text = AddFamiliyVC.Strings.addFamiliyTitle
            $0.font = UIFont.boldSystemFont(ofSize: AddFamiliyVC.Attribute.addFamiliyTitleFontSize)
            $0.textColor = UIColor.white
            $0.textAlignment = .left
        }
        
        addFamimliySubTitleLabel.do {
            $0.text = AddFamiliyVC.Strings.addFamiliySubTitle
            $0.font = UIFont.systemFont(ofSize: AddFamiliyVC.Attribute.addFamiliySubTitleFontSize)
            $0.textColor = UIColor.white
            $0.textAlignment = .left
        }
        
        shareInvitationUrlButton.do {
            $0.backgroundColor = UIColor.white
        }
        
        dividerView.do {
            $0.backgroundColor = UIColor.white
        }
        
        tableHeaderStackView.do {
            $0.axis = .horizontal
            $0.spacing = 10.0
            $0.alignment = .fill
            $0.distribution = .fillProportionally
        }
        
        familiyMemeberTitleLabel.do {
            $0.text = AddFamiliyVC.Strings.tableTitle
            $0.textColor = UIColor.white
            $0.font = UIFont.boldSystemFont(ofSize: AddFamiliyVC.Attribute.tableHeaderTitleFontSize)
        }
        
        familiyMemberCountLabel.do {
            $0.text = "0"
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: AddFamiliyVC.Attribute.tableHeaderCountFontSize)
        }
        
        tableView.do {
            $0.separatorStyle = .none
            $0.allowsSelection = false
            $0.estimatedRowHeight = UITableView.automaticDimension
            $0.backgroundColor = UIColor.clear
            $0.contentInset = AddFamiliyVC.Attribute.tableContentInset
            
            $0.register(YourFamilyProfileCell.self, forCellReuseIdentifier: YourFamilyProfileCell.id)
        }
        
        navigationItem.title = AddFamiliyVC.Strings.navgationTitle
    }
    
    public override func bind(reactor: AddFamiliyViewReactor) {
        super.bind(reactor: reactor)
        bindInput(reactor: reactor)
        bindOutput(reactor: reactor)
    }
    
    private func bindInput(reactor: AddFamiliyViewReactor) {
        Observable<Void>.just(())
            .map { Reactor.Action.refreshYourFamiliyMemeber }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        shareInvitationUrlButton.rx.tap
            .throttle(RxConst.throttleInterval, scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapInvitationUrlButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(reactor: AddFamiliyViewReactor) {
        reactor.state.map { $0.yourFamiliyDatasource }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.map { "\($0.yourFaimliyMemberCount)" }
            .distinctUntilChanged()
            .bind(to: familiyMemberCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$invitationUrl)
            .withUnretained(self)
            .subscribe {
                $0.0.makeInvitationUrlSharePanel($0.1, provider: reactor.provider)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPresentFetchInvitationUrlFailureToastMessage)
            .filter { $0 }
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe {
                $0.0.makeRoundedToastView(
                    title: "링크 불러오기 실패",
                    symbol: "exclamationmark.triangle.fill",
                    palletteColors: [UIColor.systemRed],
                    width: 190
                )
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPresentInvitationUrlCopySuccessToastMessage)
            .filter { $0 }
            .withUnretained(self)
            .subscribe {                
                $0.0.makeRoundedToastView(
                    title: AddFamiliyVC.Strings.successCopyInvitationUrl,
                    symbol: "link",
                    width: 200
                )
            }
            .disposed(by: disposeBag)
    }
}