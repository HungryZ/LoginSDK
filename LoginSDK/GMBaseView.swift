//
//  GMBaseView.swift
//  GMLogin
//
//  Created by 张海川 on 2021/2/1.
//

import UIKit

protocol GMBaseViewDelegate: class {
    func popBack()
    func popBack(count: Int)
    func pushView(_ view: GMBaseView)
}

class GMBaseView: UIView {
    
    weak var delegate: GMBaseViewDelegate?
    
    /// 是否可以返回
    public var canGoBack = true {
        didSet {
            backButton.isHidden = !canGoBack
        }
    }
    
    /// 标题
    public var title: String? {
        didSet {
            titleLabel.text = title
            
            titleView.snp.updateConstraints { (make) in
                make.height.equalTo((title != nil) ? 44 : 0)
            }
        }
    }
    
    /// 标题视图
    lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        
        return view
    }()
    
    lazy var titleLabel = UILabel(font: UIFont.systemFont(ofSize: 15, weight: .medium), textColor: ._333333)
    
    lazy var backButton = UIButton(imageName: "back", target: self, action: #selector(backButtonClicked))
    
    public let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(titleView)
        addSubview(contentView)
        addSubview(backButton)
        
        snp.makeConstraints { (make) in
            make.width.equalTo(ScreenWidth - ScaleWidth(48 * 2))
        }
        titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(0)
        }
        backButton.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.size.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.bottom.right.equalTo(0)
        }
    }
    
    func willAppear() {
        
    }
    
    @objc func backButtonClicked() {
        delegate?.popBack()
    }
}
