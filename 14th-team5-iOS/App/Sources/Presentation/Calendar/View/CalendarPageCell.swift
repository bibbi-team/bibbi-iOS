//
//  CalendarPageViewCell.swift
//  App
//
//  Created by 김건우 on 12/6/23.
//

import UIKit

import Core
import DesignSystem
import Domain
import FSCalendar
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class CalendarPageCell: BaseCollectionViewCell<CalendarPageCellReactor> {
    // MARK: - Views
    private let calendarTitleLabel: BibbiLabel = BibbiLabel(.head1, alignment: .center, textColor: .gray200)
    
    private lazy var labelStackView: UIStackView = UIStackView()
    private lazy var calendarInfoButton: UIButton = UIButton(type: .system)
    
    private let calendarView: FSCalendar = FSCalendar()
    
    // MARK: - Properties
    private let infoCircleFill: UIImage = DesignSystemAsset.infoCircleFill.image
        .withRenderingMode(.alwaysTemplate)
    
    static var id: String = "CalendarPageCell"
    
    // MARK: - Intializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    override func setupUI() {
        super.setupUI()
        contentView.addSubviews(
            labelStackView, calendarView
        )
        labelStackView.addArrangedSubviews(
            calendarTitleLabel, calendarInfoButton
        )
    }
    
    override func setupAutoLayout() {
        super.setupAutoLayout()
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(56.0)
            $0.leading.equalTo(contentView.snp.leading).offset(CalendarCell.AutoLayout.calendarTopOffsetValue)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(32.0)
            $0.horizontalEdges.equalToSuperview().inset(CalendarCell.AutoLayout.calendarLeadingTrailingOffsetValue)
            $0.height.equalTo(contentView.snp.width).multipliedBy(CalendarCell.AutoLayout.calendarHeightMultiplier)
        }
        
        calendarInfoButton.snp.makeConstraints {
            $0.width.height.equalTo(20.0)
        }
    }
    
    override func setupAttributes() {
        super.setupAttributes()
        calendarInfoButton.do {
            $0.setImage(
                infoCircleFill,
                for: .normal
            )
            $0.tintColor = .gray300
        }
        
        labelStackView.do {
            $0.axis = .horizontal
            $0.spacing = 10.0
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        calendarView.do {
            $0.headerHeight = 0.0
            $0.weekdayHeight = 40.0
            
            $0.today = nil
            $0.scrollEnabled = false
            $0.placeholderType = .fillSixRows
            $0.adjustsBoundingRectWhenChangingMonths = true
            
            $0.appearance.selectionColor = UIColor.clear
            
            $0.appearance.titleFont = UIFont.pretendard(.body1Regular)
            $0.appearance.titleDefaultColor = UIColor.bibbiWhite
            $0.appearance.titleSelectionColor = UIColor.bibbiWhite
            
            $0.appearance.weekdayFont = UIFont.pretendard(.caption)
            $0.appearance.weekdayTextColor = UIColor.gray300
            $0.appearance.caseOptions = .weekdayUsesSingleUpperCase
            
            $0.appearance.titlePlaceholderColor = UIColor.gray700
            
            $0.backgroundColor = UIColor.clear
            
            $0.locale = Locale(identifier: "ko_kr")
            $0.register(ImageCalendarCell.self, forCellReuseIdentifier: ImageCalendarCell.id)
            $0.register(PlaceholderCalendarCell.self, forCellReuseIdentifier: PlaceholderCalendarCell.id)
            
            $0.delegate = self
            $0.dataSource = self
        }
        
        setupCalendarTitle(calendarView.currentPage)
    }
    
    override func bind(reactor: CalendarPageCellReactor) {
        super.bind(reactor: reactor)
        bindInput(reactor: reactor)
        bindOutput(reactor: reactor)
    }
    
    private func bindInput(reactor: CalendarPageCellReactor) {
        Observable<Void>.just(())
            .map { Reactor.Action.fetchCalendarResponse }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        calendarInfoButton.rx.tap
            .throttle(RxConst.throttleInterval, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .map { Reactor.Action.didTapInfoButton($0.0.calendarInfoButton) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        calendarView.rx.didSelect
            .map { Reactor.Action.didSelectDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(reactor: CalendarPageCellReactor) {
        reactor.state.map { $0.arrayCalendarResponse }
            .withUnretained(self)
            .subscribe { $0.0.calendarView.reloadData() }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.date }
            .distinctUntilChanged()
            .bind(to: calendarView.rx.currentPage)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.date }
            .distinctUntilChanged()
            .bind(to: calendarTitleLabel.rx.calendarTitleText)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.date }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe {
                $0.0.setupCalendarTitle($0.1)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Extensions
extension CalendarPageCell {
    func setupCalendarTitle(_ date: Date) {
        calendarTitleLabel.text = DateFormatter.yyyyMM.string(from: date)
    }
}

extension CalendarPageCell: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let dateMonth = date.month
        let currentMonth = calendar.currentPage.month
        
        if let calendarCell = calendar.cell(for: date, at: monthPosition) as? ImageCalendarCell {
            // 셀의 날짜가 현재 월(月)과 동일하고, 썸네일 이미지가 있다면
            if dateMonth == currentMonth && calendarCell.hasThumbnailImage {
                return true
            }
        }
        
        return false
    }
}

extension CalendarPageCell: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let calendarMonth = calendar.currentPage.month
        let positionMonth = date.month
        // 셀의 날짜가 현재 월(月)과 동일하다면
        if calendarMonth == positionMonth {
            let cell = calendar.dequeueReusableCell(
                withIdentifier: ImageCalendarCell.id,
                for: date,
                at: position
            ) as! ImageCalendarCell
            
            // 해당 일자에 데이터가 존재하지 않는다면
            guard let dayResponse = reactor?.currentState.arrayCalendarResponse?.results.filter({ $0.date == date }).first else {
                let emptyResponse = CalendarResponse(
                    date: date,
                    representativePostId: "",
                    representativeThumbnailUrl: "",
                    allFamilyMemebersUploaded: false
                )
                cell.reactor = ImageCalendarCellDIContainer(
                    .month,
                    dayResponse: emptyResponse
                ).makeReactor()
                return cell
            }
            
            cell.reactor = ImageCalendarCellDIContainer(
                .month,
                dayResponse: dayResponse
            ).makeReactor()
            return cell
        // 셀의 날짜가 현재 월(月)과 동일하지 않다면
        } else {
            let cell = calendar.dequeueReusableCell(
                withIdentifier: PlaceholderCalendarCell.id,
                for: date,
                at: position
            ) as! PlaceholderCalendarCell
            return cell
        }
    }
}
