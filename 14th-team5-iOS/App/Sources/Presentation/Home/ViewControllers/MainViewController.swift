//
//  HomeViewController.swift
//  App
//
//  Created by 마경미 on 05.12.23.
//

import UIKit

import Core
import Domain
import DesignSystem

import RxDataSources
import RxCocoa
import RxSwift

final class MainViewController: BaseViewController<MainViewReactor>, UICollectionViewDelegateFlowLayout {
    private let familyViewController: MainFamilyViewController = MainFamilyViewDIContainer().makeViewController()

    private let timerView: TimerView = TimerDIContainer().makeView()
    private let descriptionLabel: BibbiLabel = BibbiLabel(.body2Regular, textAlignment: .center, textColor: .gray300)
    private let imageView: UIImageView = UIImageView()
    
    private let segmentControl: BibbiSegmentedControl = BibbiSegmentedControl(isUpdated: true)
    private let pageViewController: SegmentPageViewController = SegmentPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    private let cameraButton: MainCameraButtonView = MainCameraDIContainer().makeView()

    private let memberRepo = App.Repository.member
    private let deepLinkRepo = App.Repository.deepLink
    
    private let alertConfirmRelay = PublishRelay<(String, String)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.inviteCode = nil
    }
    
    override func bind(reactor: MainViewReactor) {
        super.bind(reactor: reactor)
        bindInput(reactor: reactor)
        bindOutput(reactor: reactor)
    }
    
    override func setupUI() {
        super.setupUI()
        
        addChild(familyViewController)
        addChild(pageViewController)
        
        view.addSubviews(familyViewController.view, timerView, descriptionLabel,
                         imageView, segmentControl, pageViewController.view,
                         cameraButton)
        
        familyViewController.didMove(toParent: self)
        pageViewController.didMove(toParent: self)
    }
    
    override func setupAutoLayout() {
        super.setupAutoLayout()
        
        familyViewController.view.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(138)
        }
        
        timerView.snp.makeConstraints {
            $0.top.equalTo(familyViewController.view.snp.bottom)
            $0.height.equalTo(48)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(timerView.snp.bottom).offset(8)
            $0.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel)
            $0.size.equalTo(20)
            $0.leading.equalTo(descriptionLabel.snp.trailing).offset(2)
        }
        
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(138)
            $0.height.equalTo(40)
        }
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        cameraButton.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(140)
        }
    }
    
    override func setupAttributes() {
        super.setupAttributes()
        
        navigationBarView.do {
            $0.setNavigationView(leftItem: .family, centerItem: .logo, rightItem: .calendar)
        }
    }
}

extension MainViewController {
    private func bindInput(reactor: MainViewReactor) {
        Observable.merge(
            Observable.just(())
                .map { Reactor.Action.fetchMainUseCase },
            NotificationCenter.default.rx.notification(UIScene.willEnterForegroundNotification)
                .map { _ in Reactor.Action.fetchMainUseCase }
        )
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
//        self.rx.viewWillAppear
//            .withUnretained(self)
//            // 별도 딥링크를 받지 않으면
//            .filter {
//                let repo = $0.0.deepLinkRepo
//                return repo.notification.value == nil && repo.widget.value == nil
//            }
//            // viewWillAppear 메서드 수행하기
//            .map { _ in Reactor.Action.viewWillAppear }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

        segmentControl.survivalButton.rx.tap
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapSegmentControl(.survival) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
      
        segmentControl.missionButton.rx.tap
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapSegmentControl(.mission) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        navigationBarView.rx.leftButtonTap
            .throttle(RxConst.throttleInterval, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .bind { $0.0.navigationController?.pushViewController( FamilyManagementDIContainer().makeViewController(), animated: true) }
            .disposed(by: disposeBag)
        
        navigationBarView.rx.rightButtonTap
            .throttle(RxConst.throttleInterval, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .bind { $0.0.navigationController?.pushViewController(CalendarDIConatainer().makeViewController(), animated: true) }
            .disposed(by: disposeBag)
      
        alertConfirmRelay
            .map { Reactor.Action.pickConfirmButtonTapped($0.0, $0.1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cameraButton.camerTapObservable
            .throttle(RxConst.throttleInterval, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .bind(onNext: {
                MPEvent.Home.cameraTapped.track(with: nil)
                let cameraViewController = CameraDIContainer(cameraType: .survival).makeViewController()
                $0.0.navigationController?.pushViewController(cameraViewController, animated: true)
            })
            .disposed(by: disposeBag)
    
        // 위젯 딥링크 코드
        App.Repository.deepLink.widget
            .compactMap { $0 }
            .map { Reactor.Action.pushWidgetPostDeepLink($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 푸시 노티피케이션 딥링크 코드
        App.Repository.deepLink.notification
            .compactMap { $0 }
            .flatMap {
                // 댓글 푸시 알림이라면
                if $0.openComment {
                    return Observable.just(Reactor.Action.pushNotificationCommentDeepLink($0))
                // 포스트 푸시 알림이라면
                } else {
                    return Observable.just(Reactor.Action.pushNotificationPostDeepLink($0))
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(reactor: MainViewReactor) {
        reactor.pulse(\.$familySection)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: familyViewController.familySectionRelay)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.pageIndex }
            .distinctUntilChanged()
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .bind(onNext: {
                $0.0.pageViewController.indexRelay.accept($0.1)
                $0.0.segmentControl.isSelected = ($0.1 == 0)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.balloonText }
            .distinctUntilChanged()
            .bind(to: cameraButton.textRelay)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.description }
            .distinctUntilChanged { $0.text }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .bind(onNext: {
                $0.0.descriptionLabel.text = $0.1.text
                $0.0.imageView.image = $0.1.image
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPresentPickAlert)
            .compactMap { $0 }
            .bind(with: self) { owner, profile in
                BibbiAlertBuilder(owner)
                    .alertStyle(.pickMember(profile.0))
                    .setConfirmAction {
                        owner.alertConfirmRelay.accept((profile.0, profile.1))
                    }
                    .present()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPresentPickSuccessToastMessage)
            .compactMap { $0 }
            .bind(with: self) { owner, name in
                owner.makeBibbiToastView(
                    text: "\(name)님에게 생존신고 알림을 보냈어요",
                    image: DesignSystemAsset.yellowPaperPlane.image
                )
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPresentCopySuccessToastMessage)
            .filter { $0 }
            .bind(with: self) { owner, _ in
                owner.makeBibbiToastView(
                    text: "링크가 복사되었어요",
                    image: DesignSystemAsset.link.image
                )
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPresentFailureToastMessage)
            .filter { $0 }
            .bind(with: self) { owner, _ in
                owner.makeErrorBibbiToastView()
            }
            .disposed(by: disposeBag)

//        // 위젯 딥링크 코드
//        reactor.pulse(\.$widgetPostDeepLink)
//            .delay(RxConst.smallDelayInterval, scheduler: Schedulers.main)
//            .compactMap { $0 }
//            .bind(with: self) { owner, deepLink in
//                owner.handlePostWidgetDeepLink(deepLink)
//            }
//            .disposed(by: disposeBag)
//        
//        // 포스트 노티피케이션 딥링크 코드
//        reactor.pulse(\.$notificationPostDeepLink)
//            .delay(RxConst.smallDelayInterval, scheduler: Schedulers.main)
//            .compactMap { $0 }
//            .bind(with: self) { owner, deepLink in
//                owner.handlePostNotificationDeepLink(deepLink)
//            }
//            .disposed(by: disposeBag)
//        
//        // 댓글 노티피케이션 딥링크 코드
//        reactor.pulse(\.$notificationCommentDeepLink)
//            .delay(RxConst.smallDelayInterval, scheduler: Schedulers.main)
//            .compactMap { $0 }
//            .bind(with: self) { owner, deepLink in
//                owner.handleCommentNotificationDeepLink(deepLink)
//            }
//            .disposed(by: disposeBag)
    }
}