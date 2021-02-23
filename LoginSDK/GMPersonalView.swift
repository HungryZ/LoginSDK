//
//  GMPersonalView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMPersonalView: GMBaseView {
    
    let titleArray = ["绑定手机号", "实名制认证", "意见反馈", "切换账号"]
    let iconArray = ["phone", "real_name", "feedback", "change_account"]
    
    var phoneDetalStr: String?
    var cerDetailStr: String?
        
    lazy var mainTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .white
        table.dataSource = self;
        table.delegate = self;
        table.tableHeaderView = self.headerView()
        table.rowHeight = ScaleWidth(45)
        table.separatorStyle = .none
        
        return table
    }()
    
    lazy var avatarButton: UIButton = {
        let button = UIButton(imageName: "avatar", target: self, action: #selector(avatarButtonClicked))
        button.frame = CGRect(x: 0, y: 0, width: ScaleWidth(58), height: ScaleWidth(58))
        button.layer.cornerRadius = ScaleWidth(58 / 2)
        button.clipsToBounds = true
        
        return button
    }()
    
    lazy var nameLabel = UILabel(font: UIFont.boldSystemFont(ofSize: 15), textColor: .white, text: "姓名姓名")
    
    lazy var changePsdButton = UIButton(title: "修改密码", titleColor: UIColor("#E8E8E8"), font: 11, target: self, action: #selector(changePsdButtonClicked))
    
    override func buildUI() {
        super.buildUI()
        
        addSubview(mainTableView)
        mainTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.height.equalTo(ScaleWidth(354))
        }
    }
    
    override func willAppear() {
        super.willAppear()
        
        GMNet.request(GMLogin.userInfo) { (response) in
            let user = response.decode(to: GMUserModel.self)
            self.phoneDetalStr = user.phone.securityPhoneStr()
            self.cerDetailStr = user.idNo.securityIDStr()
            self.mainTableView.reloadData()
            
            LoginManager.shared.user = user
        }
    }
    
    func headerView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: ScaleWidth(160)))
        let bgView = UIImageView(image: UIImage(fromBundle: "header_personal"))
        
        headerView.addSubview(bgView)
        headerView.addSubview(avatarButton)
        headerView.addSubview(nameLabel)
        headerView.addSubview(changePsdButton)
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        avatarButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(headerView)
            make.size.equalTo(avatarButton.snp.size)
            make.top.equalTo(ScaleWidth(36))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarButton.snp.bottom).offset(16)
            make.centerX.equalTo(headerView)
        }
        changePsdButton.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.centerX.equalTo(headerView)
        }
        
        return headerView
    }
    
    @objc
    func avatarButtonClicked() {
        
    }
    
    @objc
    func changePsdButtonClicked() {
        delegate?.pushView(GMForgotPsdView())
    }
}

extension GMPersonalView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)    // 不会发生重用
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        cell.textLabel?.textColor = ._333333
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
        cell.detailTextLabel?.textColor = ._999999
        cell.accessoryType = .disclosureIndicator
        if indexPath.row > 0 {
            let separatorLine = UIView()
            separatorLine.backgroundColor = UIColor("#DDDDDD")
            cell.contentView.addSubview(separatorLine)
            separatorLine.snp.makeConstraints { (make) in
                make.top.equalTo(cell.contentView)
                make.left.right.equalTo(cell).inset(15)
                make.height.equalTo(0.5)
            }
        }
        let title = titleArray[indexPath.row]
        cell.imageView?.image = UIImage(fromBundle: iconArray[indexPath.row])
        cell.textLabel?.text = title
        if title == "绑定手机号" {
            cell.detailTextLabel?.text = phoneDetalStr
        } else if title == "实名制认证" {
            cell.detailTextLabel?.text = cerDetailStr
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch titleArray[indexPath.row] {
        case "绑定手机号":
            let needBind = LoginManager.shared.user?.need_bind ?? false
            delegate?.pushView(GMPhoneCodeView(type: needBind ? .newBind : .exchangeOld))
        case "实名制认证":
            if !(LoginManager.shared.user?.needBindIdCardInfo ?? false) {
                return
            }
            self.delegate?.pushView(GMRealNameCerView())
        case "意见反馈":
            GMNet.request(GMLogin.feedback) { (response) in
                GMAlertView.show(title: "意见反馈", message: response["text"] as! String, confirmStr: "确认")
            }
        case "切换账号":
            LoginManager.shared.logout()
        default: break
        }
    }
}
