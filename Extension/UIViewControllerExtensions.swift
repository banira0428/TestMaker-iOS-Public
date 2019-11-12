//
//  UIViewControllerExtensions.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/11/13.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import Foundation
import GoogleMobileAds
import FirebaseAnalytics

extension UIViewController { //ダイアログ表示などの処理を共通化
    
    func createAd() -> GADBannerView{
        
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-hogehoge"
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        return bannerView
    }
    
    func showAd(){

        let bannerView = createAd()

        self.view.addSubview(bannerView)
        
        self.view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
    }

    func showToast(message: String) {

        let toast = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)

        present(toast, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            toast.dismiss(animated: true, completion: nil)
        }

    }

    func showToastWithConfirm(message: String) {
        let toast = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)

        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)

        toast.addAction(defaultAction)

        present(toast, animated: true, completion: nil)

    }

    func showAskPermitDialog(message: String, handler: ((UIAlertAction) -> Void)? = nil) {

        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: UIAlertActionStyle.default, handler: handler)

        let cancelAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: UIAlertActionStyle.default, handler: nil)

        alert.addAction(cancelAction)

        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)

    }
    
    func createDialogForIPad(dialog: UIViewController) -> UIViewController {
        
        dialog.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        dialog.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)
        
        return dialog
    }

    func logEvent(title: String) {

        Analytics.logEvent(title, parameters: nil)

    }

    func showIndicator(message: String) {
        
        var indicatorBackgroundView: UIView!
        var indicator: UIActivityIndicatorView!
        var label: UILabel!
        
        // インジケータビューの背景
        indicatorBackgroundView = UIView(frame: self.view.bounds)
        indicatorBackgroundView?.backgroundColor = UIColor.black
        indicatorBackgroundView?.alpha = 0.4
        indicatorBackgroundView?.tag = 100100
        
        label = UILabel(frame: CGRect(x: 100, y: 100, width: 300, height: 100))
        label?.text = message
        label?.textAlignment = .center
        label?.center = self.view.center
        label?.textColor = UIColor.white
        
        
        indicator = UIActivityIndicatorView()
        indicator?.activityIndicatorViewStyle = .whiteLarge
        indicator?.color = UIColor.white
        indicator?.translatesAutoresizingMaskIntoConstraints = false
        // アニメーション停止と同時に隠す設定
        indicator?.hidesWhenStopped = true
        
        // 作成したviewを表示
        indicatorBackgroundView?.addSubview(label!)
        indicatorBackgroundView?.addSubview(indicator!)
        
        indicator?.topAnchor.constraint(equalTo: label!.bottomAnchor,constant: 0).isActive = true
        indicator?.leftAnchor.constraint(equalTo: label!.leftAnchor,constant: 0).isActive = true
        indicator?.rightAnchor.constraint(equalTo: label!.rightAnchor,constant: 0).isActive = true

        self.view.addSubview(indicatorBackgroundView!)
        indicator?.startAnimating()
    }
    
    func hideIndicator(){
        // viewにローディング画面が出ていれば閉じる
         if let viewWithTag = self.view.viewWithTag(100100) {
             viewWithTag.removeFromSuperview()
         }
     }
}
