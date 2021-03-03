//
//  GMPhoneHistoryView.swift
//  LoginSDK
//
//  Created by 张海川 on 2021/2/24.
//

import UIKit

class GMPhoneHistoryView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    static var showedView: GMPhoneHistoryView?
    
    var completeAction: ((String) -> Void)!
    
    var dataArray = GMPhoneHistoryView.phones()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.rowHeight = ScaleWidth(36)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 4
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        return tableView;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        layer.cornerRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func show(withHostView hostView: UIView, complete: @escaping (String) -> Void) {
        let view = GMPhoneHistoryView()
        view.completeAction = complete
        
        if let superView = hostView.superview {
            superView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.top.equalTo(hostView.snp.bottom)
                make.left.right.equalTo(hostView)
                make.height.equalTo(ScaleWidth(36) * (CGFloat)(view.rowsNumber() > 3 ? 3 : view.rowsNumber()))
            }
            showedView = view
        }
    }
    
    static func hideCurrentView() {
        if let view = GMPhoneHistoryView.showedView {
            view.completeAction = nil
            view.removeFromSuperview()
            GMPhoneHistoryView.showedView = nil
        }
    }
    
    func rowsNumber() -> Int {
        dataArray.count > 0 ? dataArray.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.textLabel?.textColor = ._333333
        if rowsNumber() == 1, dataArray.count == 0 {
            cell.accessoryView = nil
            cell.textLabel?.text = "暂无记录"
            return cell
        }
        cell.textLabel?.text = dataArray[indexPath.row]
        
        let deletebutton = UIButton(imageName: "delete", target: self, action: #selector(deleteButtonClicked(sender:)))
        deletebutton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        deletebutton.tag = indexPath.row
        cell.accessoryView = deletebutton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rowsNumber() == 1, dataArray.count == 0 {
            return
        }
        completeAction(dataArray[indexPath.row])
        completeAction = nil
        removeFromSuperview()
        GMPhoneHistoryView.showedView = nil
    }
    
    @objc
    func deleteButtonClicked(sender: UIButton) {
        GMPhoneHistoryView.removePhone(at: sender.tag)
        dataArray = GMPhoneHistoryView.phones()
        tableView.reloadData()
    }
}

extension GMPhoneHistoryView {
    
    static let key_historyPhone = "LoginSDK.historyPhone"
    
    static func phones() -> [String] {
        if let phones = UserDefaults.standard.stringArray(forKey: key_historyPhone) {
            return phones
        } else {
            return []
        }
    }
    
    // 保存和返回的都是带格式的手机号 188 8888 8888
    static func savePhone(_ phone: String) {
        var newPhones = phones()
        // 如果这个手机号存在本地，先删除
        var localIndex: NSInteger?
        for (index, localPhone) in newPhones.enumerated() {
            if phone == localPhone {
                localIndex = index
                break
            }
        }
        if localIndex != nil {
            newPhones .remove(at: localIndex!)
        }
        // 排在最前
        newPhones.insert(phone, at: 0)
        UserDefaults.standard.setValue(newPhones, forKey: key_historyPhone)
    }
    
    static func removePhone(at index: NSInteger) {
        var newPhones = phones()
        guard index < newPhones.count else {
            return
        }
        newPhones.remove(at: index)
        UserDefaults.standard.setValue(newPhones, forKey: key_historyPhone)
    }
}
