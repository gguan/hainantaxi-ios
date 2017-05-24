//
//  MobileAuthViewController.swift
//  HNTaxi
//
//  Created by Tbxark on 17/05/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import HNTaxiKit
import SVProgressHUD

typealias MainAuthViewController = MobileAuthViewController
class MobileAuthViewController: UIViewController {
    
    fileprivate let disposeQueue = DisposeQueue()
    fileprivate let countryCode = Variable<String>("86")
    
    fileprivate let countryButton = UIButton().then {
        $0.title = " 86 ▾ "
        $0.setTitleColor(Color.textDarkGray, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.contentHorizontalAlignment = .left
    }
    fileprivate let sendCodeButton = UIButton().then {
        $0.title = "验证码"
        $0.setTitleColor(UIColor.gray, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.contentHorizontalAlignment = .right
    }
    fileprivate let phoneTextField = UITextField().then {
        $0.textColor = UIColor.gray
        $0.placeholder = "有效手机号码"
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    fileprivate let codeTextField = UITextField().then {
        $0.textColor = Color.textDarkGray
        $0.placeholder = "短信验证码"
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    fileprivate let loginButton = UIButton().then {
        $0.title = "登录 / 注册"
        $0.setTitleColor(Color.textDarkGray, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.layer.borderColor = Color.textDarkGray.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        configureObservable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    private func layoutViewController() {
        let phoneLabel = UILabel().then {
            $0.textColor = Color.textBlack
            $0.font = UIFont.boldSystemFont(ofSize: 16)
            $0.text = "手机号码"
        }
        let codeLabel = UILabel().then {
            $0.textColor = Color.textBlack
            $0.font = UIFont.boldSystemFont(ofSize: 16)
            $0.text = "验证码"
        }
        let spline1 = UIView().then {
            $0.backgroundColor = Color.bgGay
        }
        let spline2 = UIView().then {
            $0.backgroundColor = Color.bgGay
        }
        
        navigationItem.title = "登录"
        view.backgroundColor = UIColor.white
        view.addSubview(phoneLabel)
        view.addSubview(codeLabel)
        view.addSubview(spline1)
        view.addSubview(spline2)
        view.addSubview(countryButton)
        view.addSubview(sendCodeButton)
        view.addSubview(phoneTextField)
        view.addSubview(codeTextField)
        view.addSubview(loginButton)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(view).offset(R.Margin.large)
            make.height.equalTo(30)
            make.right.equalTo(view).offset(-R.Margin.large)
        }
        countryButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(phoneTextField)
            make.left.equalTo(phoneLabel)
            make.width.equalTo(60)
        }
        phoneTextField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneLabel.snp.bottom).offset(R.Margin.medium)
            make.left.equalTo(countryButton.snp.right)
            make.right.equalTo(phoneLabel)
            make.height.equalTo(40)
        }
        spline1.snp.makeConstraints { (make) in
            make.left.right.equalTo(phoneLabel)
            make.top.equalTo(phoneTextField.snp.bottom)
            make.height.equalTo(1)
        }
        codeLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(phoneLabel)
            make.height.equalTo(30)
            make.top.equalTo(spline1.snp.bottom).offset(R.Margin.large * 2)
        }
        sendCodeButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(codeTextField)
            make.right.equalTo(phoneLabel)
            make.width.equalTo(60)
        }
        codeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(codeLabel.snp.bottom).offset(R.Margin.medium)
            make.left.equalTo(codeLabel)
            make.right.equalTo(sendCodeButton.snp.left)
            make.height.equalTo(40)
        }
        spline2.snp.makeConstraints { (make) in
            make.left.right.equalTo(phoneLabel)
            make.top.equalTo(codeTextField.snp.bottom)
            make.height.equalTo(1)
        }
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(spline2.snp.bottom).offset(R.Margin.large * 3)
            make.height.equalTo(40)
            make.width.equalTo(120)
            make.centerX.equalTo(view)
        }
        
    }
    
    
    private func configureObservable() {
        let phoneData = Observable.combineLatest(countryCode.asObservable(),
                                                 phoneTextField.rx.text.orEmpty,
                                                 resultSelector: { c,p in (c, p)})
        
        let loginData = Observable.combineLatest(countryCode.asObservable(),
                                                 phoneTextField.rx.text.orEmpty,
                                                 codeTextField.rx.text.orEmpty, resultSelector: { c, p, v in (c, p, v)})
        sendCodeButton.rx.tap
            .asObservable()
            .withLatestFrom(phoneData)
            .flatMap { (country: String, phone: String) -> Observable<HTResult<Void>> in
                SMSService.selectCountry = country
                return SMSService.sendVerificationCodeWithPhoneNumber(phone)
                    .mapToResult(error: "error")
            }
            .subscribe(onNext: { (res: HTResult<Void>) in
                print(res)
            })
            .addDisposableTo(disposeQueue, key: "sendCodeButton")
        
        loginButton.rx.tap
            .asObservable()
            .withLatestFrom(loginData)
            .flatMap { (country: String, phone: String, code: String) -> Observable<HTResult<Void>> in
                SVProgressHUD.show()
                return HTAuthManager.default.mobile(country: country, phone: phone, code: code)
                    .mapToResult(error: "error")
            }
            .subscribe(onNext: {[weak self] (res: HTResult<Void>) in
                switch res {
                case .success(_):
                    SVProgressHUD.dismiss()
                    self?.close()
                case .error(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription ?? "Error")
                }
            })
            .addDisposableTo(disposeQueue, key: "loginButton")
    }
    
    

}
