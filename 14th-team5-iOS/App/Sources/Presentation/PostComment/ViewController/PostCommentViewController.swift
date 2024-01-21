//
//  PostCommentViewController.swift
//  App
//
//  Created by 김건우 on 1/18/24.
//

import Core
import UIKit

import RxSwift
import RxDataSources
import Then
import SnapKit

final public class PostCommentViewController: BaseViewController<PostCommentViewReactor> {
    // MARK: - Views
    private let navigationBarView: PostCommentTopBarView = PostCommentTopBarView()
    
    private let noCommentLabel: NoCommentLabel = NoCommentLabel()
    private let commentTableView: UITableView = UITableView()
    
    private let commentTextField: UITextField = UITextField()
    private let textFieldStroke: UIView = UIView()
    private let createCommentButton: UIButton = UIButton(type: .system)
    
    // MARK: - Properties
    private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<PostCommentSectionModel> = prepareDatasource()
    
    // MARK: - LifeCycles
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Helpers
    public override func bind(reactor: PostCommentViewReactor) {
        super.bind(reactor: reactor)
        bindInput(reactor: reactor)
        bindOutput(reactor: reactor)
    }
    
    private func bindInput(reactor: PostCommentViewReactor) { 
        Observable<Void>.merge(
            commentTableView.rx.tap.asObservable(),
            navigationBarView.rx.tap.asObservable()
        )
        .throttle(RxConst.throttleInterval, scheduler: Schedulers.main)
        .withUnretained(self)
        .subscribe {
            $0.0.commentTextField.resignFirstResponder()
        }
        .disposed(by: disposeBag)

    }
    
    private func bindOutput(reactor: PostCommentViewReactor) {
        let testData = PostCommentSectionModel.generateTestData()
        Observable.just(testData)
            .distinctUntilChanged()
            .bind(to: commentTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.commentCount >= 0 }
            .distinctUntilChanged()
            .bind(to: noCommentLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    public override func setupUI() {
        super.setupUI()
        
        view.addSubviews(
            navigationBarView, commentTableView,
            noCommentLabel, textFieldStroke
        )
        textFieldStroke.addSubview(commentTextField)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        navigationBarView.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        noCommentLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.bottom.equalTo(textFieldStroke.snp.top).offset(-5)
            $0.horizontalEdges.equalToSuperview()
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        textFieldStroke.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.top.equalTo(commentTableView.snp.bottom).offset(5)
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-5)
        }
        
        commentTextField.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(15)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        textFieldStroke.do {
            $0.layer.cornerRadius = 46 / 2
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.gray500.cgColor
            $0.backgroundColor = UIColor.clear
        }
        
        commentTableView.do {
            $0.estimatedRowHeight = 250
            $0.rowHeight = UITableView.automaticDimension
            $0.allowsSelection = false
            $0.separatorStyle = .none
            $0.backgroundColor = UIColor.bibbiBlack
            $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            
            $0.register(CommentCell.self, forCellReuseIdentifier: CommentCell.id)
        }
        
        commentTextField.do {
            $0.textColor = UIColor.bibbiWhite
            $0.attributedPlaceholder = NSAttributedString(
                string: "댓글 달기...",
                attributes: [.foregroundColor: UIColor.gray500]
            )
            $0.backgroundColor = UIColor.clear
            $0.rightView = createCommentButton
            $0.rightViewMode = .always
        }
        
        createCommentButton.do {
            $0.setTitle("등록", for: .normal)
            $0.tintColor = UIColor.mainGreen
        }
        
    }
}

extension PostCommentViewController {
    private func prepareDatasource() -> RxTableViewSectionedAnimatedDataSource<PostCommentSectionModel> {
        return RxTableViewSectionedAnimatedDataSource { dataSource, tableView, indexPath, reactor in
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.id) as! CommentCell
            cell.reactor = reactor
            return cell
        }
    }
}