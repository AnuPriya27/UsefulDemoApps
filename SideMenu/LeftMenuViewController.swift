//
//  LeftMenuViewController.swift
//  BeUnique
//
//  Created by Anupriya on 08/01/19.
//  Copyright © 2019 com.smartitventures. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire

let notificationLang = NSNotification.Name(rawValue: "notificationLang")
var users = UserDefaults.standard


class LeftMenuViewController: UIViewController {
   
    //MARK: Outlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblName : UILabel!
     @IBOutlet weak var lblEmail : UILabel!
    @IBOutlet weak var imgUser : UIImageView!
    //MARK: class Variables
    let kHeaderSectionTag: Int = 6900
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionItems: [Any] = []
    var sectionNames: [Any] = []
    var destination:UIViewController?
    var apiLanguageIncoming : ApiLanguageDataIncoming?
    var apiCurrencyIncoming : ApiCurrencyIncoming?
    var apiSubCategory : ApiSubCategoriesIncomming?
    var arrSubCat : [String] = []
    var arrCurrency : [String] = []
    var arrLang : [String] = []
    var langCode : String?
    var langId : Int?
    var userId : String?
    var userInfoIncoming : ApiSignUpIncoming?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        langCode = users.object(forKey: EnumUserDefaultKey.langCode.userKey) as? String
        langId = users.object(forKey: EnumUserDefaultKey.langId.userKey) as? Int
        self.getSubCategory()
         userId = users.object(forKey: EnumUserDefaultKey.customerId.userKey) as? String
        if userId != nil{
          getUserInfo(userId: userId!)
        }else{
           self.lblName.text = "Welcome"
           self.lblEmail.text = ""
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userId = users.object(forKey: EnumUserDefaultKey.customerId.userKey) as? String
        if userId != nil{
                        getUserInfo(userId: userId!)
                    }else{
                        self.lblName.text = "Welcome"
                        self.lblEmail.text = ""
                    }
    }
    
    
    
    @IBAction func actionProfileGesture(_ sender : UITapGestureRecognizer){
        if userId != nil{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileRootViewController") as! ProfileRootViewController
            self.present(vc, animated: false) {
                self.slideMenuController()?.closeLeft()
                self.slideMenuController()?.closeRight()
            }
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginRootViewController") as! LoginRootViewController
            self.present(vc, animated: false) {
                self.slideMenuController()?.closeLeft()
                self.slideMenuController()?.closeRight()
            }
        }
    }
    
    

    @objc func languageDidChange(){
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.ChangeLayout()
    }
    
    //MARK: Integerate LanguageApi
    func getLang(){
        HUD.show(.progress)
        WebServices.get(url: Api.getLanguage.url, completionHandler: { (response, _) in
            self.apiLanguageIncoming = ApiLanguageDataIncoming(response: response)
            _ = self.apiLanguageIncoming?.languages.map({ lang in
                self.arrLang.append(lang.name!)
            })
            self.getCurrency()
            HUD.hide()
        }) { (error, _) in
            HUD.hide()
            self.view.makeToast(error.localizedDescription)
        }
    }
    
    //MARK: getCurrency
    func getCurrency(){
        HUD.show(.progress)
        WebServices.get(url: Api.getCurrency.url, completionHandler: { (response, _) in
            self.apiCurrencyIncoming = ApiCurrencyIncoming(response: response)
            _ = self.apiCurrencyIncoming?.currencies.map({ curncy in
                self.arrCurrency.append(curncy.iso_code!)
            })
            self.sectionItems = [self.arrSubCat,[],[],[],self.arrLang,self.arrCurrency,[],[],[],[]]
            self.tblView.delegate = self
            self.tblView.dataSource = self
            self.tblView!.tableFooterView = UIView()
            HUD.hide()
        }) { (error, _) in
            HUD.hide()
            self.view.makeToast(error.localizedDescription)
        }
    }
   
    //MARK: GetSubcategory
    
    func getSubCategory(){
        HUD.show(.progress)
        WebServices.get(url: Api.getSubCategory(langId!).url, completionHandler: { (response, _) in
            self.apiSubCategory = ApiSubCategoriesIncomming(response: response)
            _ = self.apiSubCategory?.categories.map({ category in
                self.arrSubCat.append(category.name!)
            })
            self.getLang()
            HUD.hide()
        }) { (error, _) in
            HUD.hide()
            self.view.makeToast(error.localizedDescription)
        }
    }
    
}


// MARK:- UITableViewDelegate and DataSource

extension LeftMenuViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.expandedSectionHeaderNumber == section)
        {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (self.sectionNames.count != 0)
        {
            return self.sectionNames[section] as? String
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier:"ExpandedCollapsedCell", for:indexPath) as! ExpandedCollapsedCell
        let section = self.sectionItems[indexPath.section] as! NSArray
        cell.lblTitle.text = section[indexPath.row] as? String
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 45.0
    }
    
    // MARK :- Set HeaderTitle
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let header:UIView =  UIView()
        header.frame = CGRect(x: 10, y: 5, width:self.tblView.frame.size.width, height: 30)
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section)
        {
            viewWithTag.removeFromSuperview()
        }
        if(section==0)
        {
            let headerFrame = self.view.frame.size
            if self.langCode == "en"{
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 30, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "rightArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: 16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.numberOfLines = 0
                titleLbl.lineBreakMode = .byWordWrapping
                titleLbl.text = "Perfumes"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
            }else{
                let theImageView = UIImageView(frame: CGRect(x: 16, y: 16 , width: 18, height: 18));
                theImageView.image = UIImage(named: "leftArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: -16, y: 16, width: header.frame.size.width, height: 30))
                titleLbl.textAlignment = .right
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.text = "عطر"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                
            }
           
//            let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
//         //  button.addTarget(self, action:#selector(goToMyAccount), for:.touchUpInside)
//            header.addSubview(button)
        }
        if(section == 1)
        {
            if langCode == "en"{
                let titleLbl = UILabel(frame: CGRect(x: 16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.text = "Hair Perfume"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                button.addTarget(self, action:#selector(goToHairPerfumes), for:.touchUpInside)
                header.addSubview(button)
            }else{
                let titleLbl = UILabel(frame: CGRect(x: -16, y: 16, width: header.frame.size.width, height: 30))
                titleLbl.textAlignment = .right
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.text = "عطر الشعر"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                button.addTarget(self, action:#selector(goToHairPerfumes), for:.touchUpInside)
                header.addSubview(button)
            }
         
        }
        if(section == 2)
        {
            if self.langCode == "en"{
                let headerFrame = self.view.frame.size
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 30, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "rightArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: 16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.text = "Brands"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                button.addTarget(self, action:#selector(goToBrands), for:.touchUpInside)
                header.addSubview(button)
            }else{
                let headerFrame = self.view.frame.size
                let theImageView = UIImageView(frame: CGRect(x: 16, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "leftArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: -16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.text = "العلامات التجارية"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                button.addTarget(self, action:#selector(goToBrands), for:.touchUpInside)
                header.addSubview(button)
            }
            
            
        }
        else if(section == 3)
        {
            if langCode == "en"{
                let titleLbl = UILabel(frame: CGRect(x: 16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.text = "Magazine"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                button.addTarget(self, action:#selector(goToMagazine), for:.touchUpInside)
                header.addSubview(button)
            }else{
                let titleLbl = UILabel(frame: CGRect(x: -16, y: 16, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.textAlignment = .right
                titleLbl.text = "مجلة"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                  button.addTarget(self, action:#selector(goToMagazine), for:.touchUpInside)
                header.addSubview(button)
            }
        }
        else if(section == 4)
        {
            if langCode == "en"{
                let headerFrame = self.view.frame.size
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 30, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "rightArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: 16, y: 8, width: header.frame.size.width, height: 30))
                 titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.text = "Languages"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
            }else{
                let theImageView = UIImageView(frame: CGRect(x: 16, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "leftArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: -16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.text = "اللغات"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
               
            }
           
        }
        else if(section == 5)
        {
            if langCode == "en"{
                
               let headerFrame = self.view.frame.size
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 30, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "rightArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: 16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.text = "Currencies"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
            }else{
               
                let theImageView = UIImageView(frame: CGRect(x: 16, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "leftArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let titleLbl = UILabel(frame: CGRect(x: -16, y: 16, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.textAlignment = .right
                titleLbl.text = "العملات"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
            }
            
        }
        else if(section == 6)
        {
            if langCode == "en"{
                let headerFrame = self.view.frame.size
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 30, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "rightArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                 button.addTarget(self, action:#selector(RateApp), for:.touchUpInside)
                header.addSubview(button)
                let titleLbl = UILabel(frame: CGRect(x: 16, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.text = "Rate our App"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
            }else{
                let theImageView = UIImageView(frame: CGRect(x: 16, y: 16, width: 18, height: 18));
                theImageView.image = UIImage(named: "leftArrow")
                theImageView.tag = kHeaderSectionTag + section
                header.addSubview(theImageView)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                 button.addTarget(self, action:#selector(RateApp), for:.touchUpInside)
                header.addSubview(button)
                let titleLbl = UILabel(frame: CGRect(x: -16, y: 16, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.textAlignment = .right
                titleLbl.text = "تقييم التطبيق لدينا"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
            }
        }else if(section == 7){
            if langCode == "en"{
                let headerFrame = self.view.frame.size
                let titleLbl = UILabel(frame: CGRect(x: 50, y: 8, width: headerFrame.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.numberOfLines = 0
                titleLbl.lineBreakMode = .byWordWrapping
                titleLbl.text = "Free shipping to Saudi Arabia"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let theImageView2 = UIImageView(frame: CGRect(x: 8, y:8, width: 30, height:30));
                theImageView2.image = UIImage(named: "free_delivery")
                theImageView2.contentMode = .scaleAspectFit
                theImageView2.tag = kHeaderSectionTag + section
                header.addSubview(theImageView2)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                //  button.addTarget(self, action:#selector(goToMyAccount), for:.touchUpInside)
                header.addSubview(button)
            }else{
                
                let headerFrame = self.view.frame.size
                let titleLbl = UILabel(frame: CGRect(x: 8, y: 8, width: 210 , height: 45))
                titleLbl.numberOfLines = 0
                titleLbl.lineBreakMode = .byWordWrapping
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.textAlignment = .right
                "شحن مجاني إلى المملكة العربية السعودية"//
                titleLbl.text = "شحن مجاني إلى المملكة العربية السعودية"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let theImageView2 = UIImageView(frame: CGRect(x: headerFrame.width - 60 , y: 8 , width: 30, height:30));
                theImageView2.image = UIImage(named: "free_delivery")
                theImageView2.contentMode = .scaleAspectFit
                theImageView2.tag = kHeaderSectionTag + section
                header.addSubview(theImageView2)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                //   button.addTarget(self, action:#selector(goToMyAccount), for:.touchUpInside)
                header.addSubview(button)
                
            }
            
        }else if(section == 8){
            if langCode == "en"{
                let headerFrame = self.view.frame.size
                let titleLbl = UILabel(frame: CGRect(x: 50, y: 8, width: headerFrame.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.numberOfLines = 0
                titleLbl.lineBreakMode = .byWordWrapping
                titleLbl.text = "Gift with every order"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let theImageView2 = UIImageView(frame: CGRect(x: 8, y:8, width: 30, height:30));
                theImageView2.image = UIImage(named: "heart_red")
                theImageView2.contentMode = .scaleAspectFit
                theImageView2.tag = kHeaderSectionTag + section
                header.addSubview(theImageView2)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                //   button.addTarget(self, action:#selector(goToMyAccount), for:.touchUpInside)
                header.addSubview(button)
            }else{
                let headerFrame = self.view.frame.size
                let titleLbl = UILabel(frame: CGRect(x: 8, y: 8, width: 210 , height: 45))
                titleLbl.numberOfLines = 0
                titleLbl.lineBreakMode = .byWordWrapping
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.textAlignment = .right
                titleLbl.text = "هدية مع كل طلب"
                    /*"/شحن مجاني إلى المملكة العربية السعودية"&*/
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let theImageView2 = UIImageView(frame: CGRect(x: headerFrame.width - 60 , y: 16 , width: 30, height:30));
                theImageView2.image = UIImage(named: "heart_red")
                theImageView2.contentMode = .scaleAspectFit
                theImageView2.tag = kHeaderSectionTag + section
                header.addSubview(theImageView2)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                //   button.addTarget(self, action:#selector(goToMyAccount), for:.touchUpInside)
                header.addSubview(button)
                
            }
            
        }else if(section == 9){
            if langCode == "en"{
                let headerFrame = self.view.frame.size
                let titleLbl = UILabel(frame: CGRect(x: 50, y: 8, width: header.frame.size.width, height: 30))
                titleLbl.font = UIFont(name: "Shree Devanagari 714", size: 17)
                titleLbl.text = "100% original brands"
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let theImageView2 = UIImageView(frame: CGRect(x: 8, y:8, width: 30, height:30));
                theImageView2.image = UIImage(named: "tick")
                theImageView2.contentMode = .scaleAspectFit
                theImageView2.tag = kHeaderSectionTag + section
                header.addSubview(theImageView2)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                //   button.addTarget(self, action:#selector(goToMyAccount), for:.touchUpInside)
                header.addSubview(button)
            }else{
                let headerFrame = self.view.frame.size
                let titleLbl = UILabel(frame: CGRect(x: 8, y: 8, width: 210 , height: 45))
                titleLbl.numberOfLines = 0
                titleLbl.lineBreakMode = .byWordWrapping
                titleLbl.font = UIFont(name: "GE SS Two", size: 17)
                titleLbl.textAlignment = .right
                titleLbl.text = "100 ٪ الأصلي"
                /*"/شحن مجاني إلى المملكة العربية السعودية"&*/
                titleLbl.textColor = UIColor.black
                header.addSubview(titleLbl)
                let theImageView2 = UIImageView(frame: CGRect(x: headerFrame.width - 60 , y: 16 , width: 30, height:30));
                theImageView2.image = UIImage(named: "tick")
                theImageView2.contentMode = .scaleAspectFit
                theImageView2.tag = kHeaderSectionTag + section
                header.addSubview(theImageView2)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width:header.frame.size.width, height:header.frame.size.height+33))
                //   button.addTarget(self, action:#selector(goToMyAccount), for:.touchUpInside)
                header.addSubview(button)
            }
            
        }
        
        // MARK:- Add Gesture on Header to Expand or Collapse Cell
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        return header
    }
    
    //MARK: - Perform Actions On Header
    @objc func goToBrands()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BrandsRootViewController") as! BrandsRootViewController
        self.present(vc, animated: true) {
            self.slideMenuController()?.closeLeft()
            self.slideMenuController()?.closeRight()
        }
    }
    
    //MARK: - Perform Actions On Header
    @objc func RateApp()
    {
        let appId = "id1179732810"
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open \(url): \(success)")
            })
        } else if UIApplication.shared.openURL(url) {
            print("Open \(url)")
        }
    
    }
    

    //MARK: - Perform Actions On Header
    @objc func goToHairPerfumes()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HairPerfumeRootViewController") as! HairPerfumeRootViewController
        self.present(vc, animated: true) {
            self.slideMenuController()?.closeLeft()
            self.slideMenuController()?.closeRight()
        }
    }
    
    //MARK: - Perform Actions On Header
    @objc func goToMagazine()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MagzineRootViewController") as! MagzineRootViewController
        self.present(vc, animated: true) {
            self.slideMenuController()?.closeLeft()
            self.slideMenuController()?.closeRight()
        }
    }
    
    
    // MARK:- Check Section is selected or not and Perform Actions
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer)
    {
        let headerView = sender.view as! UIView
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1)
        {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        }
        else
        {
            if (self.expandedSectionHeaderNumber == section)
            {
                tableViewCollapeSection(section, imageView: eImageView!)
            }
            else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
    
    //MARK:- Method to expand a Selected Header
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView)
    {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0)
        {
            self.expandedSectionHeaderNumber = -1;
            return;
        }
        else
        {
            UIView.animate(withDuration: 0.4, animations:
                {
                    imageView.transform = CGAffineTransform(rotationAngle: (180 * CGFloat(Double.pi)) / 360.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count
            {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tblView!.beginUpdates()
            self.tblView!.insertRows(at: indexesPath, with: UITableView.RowAnimation.left)
            self.tblView!.endUpdates()
        }
        
    }
    
    //MARK:- Method to Collapse a Header cell which is already Expanded
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView)
    {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tblView!.beginUpdates()
            self.tblView!.deleteRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.tblView!.endUpdates()
        }
    }
    
    //MARK:- Selection of a Row and deselection of a Row
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("The Section and row  is  == \(indexPath.section) \(indexPath.row)")
        if indexPath.section == 0{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoryRootViewController") as! SubCategoryRootViewController
           let topVc = vc.viewControllers.first as! SubCategoryViewController
            topVc.parentId = self.apiSubCategory?.categories[indexPath.row].id
            self.present(vc, animated: true) {
                self.slideMenuController()?.closeLeft()
                 self.slideMenuController()?.closeRight()
            }
        }
        if indexPath.section == 4{
            let langCode = self.apiLanguageIncoming?.languages[indexPath.row].iso_code
            let langId = self.apiLanguageIncoming?.languages[indexPath.row].id
            users.set(langId, forKey: EnumUserDefaultKey.langId.userKey)
            users.set(langCode, forKey: EnumUserDefaultKey.langCode.userKey)
            Bundle.setLanguage(langCode!)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        
        if indexPath.section == 5{
            let currencyCode = self.apiCurrencyIncoming?.currencies[indexPath.row].sign
            let crncyConversion = self.apiCurrencyIncoming?.currencies[indexPath.row].conversion_rate
            users.set(currencyCode, forKey: EnumUserDefaultKey.currencyCode.userKey)
            users.set(crncyConversion, forKey: EnumUserDefaultKey.conversionRate.userKey)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
        }

     //   if indexPath.se
        
  /*      if(indexPath.section == 5){
            if indexPath.row == 0{
                destination = storyboard?.instantiateViewController(withIdentifier:"AboutUsViewController") as! AboutUsViewController
                sideMenuController()?.setContentViewController(destination!)
            }
            if indexPath.row == 1{
                destination = storyboard?.instantiateViewController(withIdentifier:"HowItWorksViewController") as! HowItWorksViewController
                sideMenuController()?.setContentViewController(destination!)
            }
            if indexPath.row == 2{
                destination = storyboard?.instantiateViewController(withIdentifier:"SellToUsViewController") as! SellToUsViewController
                sideMenuController()?.setContentViewController(destination!)
            }
            if indexPath.row == 3{
                destination = storyboard?.instantiateViewController(withIdentifier:"KnowledBaseViewController") as! KnowledBaseViewController
                sideMenuController()?.setContentViewController(destination!)
            }
            if indexPath.row == 4{
                destination = storyboard?.instantiateViewController(withIdentifier:"BlogsViewController") as! BlogsViewController
                sideMenuController()?.setContentViewController(destination!)
                
            }else if indexPath.row == 5{
                destination = storyboard?.instantiateViewController(withIdentifier:"EventsViewController") as! EventsViewController
                sideMenuController()?.setContentViewController(destination!)
            }
        }
    }
    */
}

}



//MARK: ExpandableCell Class
class ExpandedCollapsedCell :UITableViewCell
{
    
    @IBOutlet weak var lblTitle: UILabel!
    
}

extension LeftMenuViewController{
    
    func getUserInfo(userId : String){
        
        let url = URL(string: "https://bu-beunique.com/webservice/my-account/get_profile.php")!
        Alamofire.upload(multipartFormData: { multipart in
            multipart.append(userId.data(using: .utf8)!, withName :"id_customer")
        }, to: url, method: .post, headers: nil) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    //HUD.show(.progress)
                    //call progress callback here if you need it
                }
                upload.responseString(completionHandler: { (dattta) in
                    //HUD.hide()
                    print("duefwyfk",dattta)
                    let str1 = String.init(data: dattta.data!, encoding: .utf8)
                    let str2 = str1!.components(separatedBy: "profileApi")
                    if str2.count > 0{
                        let dicty1 = self.convertToDictionary(text: str2[1])
                        //                    //str.components(separatedBy: "RegistrationApi")
                        let dictResponse = dicty1! as NSDictionary
                        let status  = dictResponse["status"] as? String
                        let message = dictResponse["message"] as? String
                        self.view.makeToast(message)
                        if status == "success"{
                            // let loginIncoming = dictResponse["payload"] as? NSDictionary
                            self.userInfoIncoming = ApiSignUpIncoming(response: dicty1! as AnyObject)
                            self.lblName.text = (self.userInfoIncoming?.payLoad?.customer?.firstName)! + (self.userInfoIncoming?.payLoad?.customer?.lastName)!
                            self.lblEmail.text = (self.userInfoIncoming?.payLoad?.customer?.email)!
                            if self.userInfoIncoming?.payLoad?.customer?.profile_pic != nil && self.userInfoIncoming?.payLoad?.customer?.profile_pic != "" {
                                let str = "https://bu-beunique.com/images/" + (self.userInfoIncoming?.payLoad?.customer?.profile_pic)!
                                let imgURL = URL(string: str)!
                                self.imgUser.load(url:imgURL)
                            }
                        }else{
                            self.view.makeToast(message)
                        }
                        print("DICTRESPONSE===", dictResponse)
                    }else{
                        self.view.makeToast("Server Error , Try Again!")
                    }
                    
                })
            case .failure(let encodingError):
                HUD.hide()
                print("multipart upload encodingError: \(encodingError)")
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let jsonDict =  try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                return jsonDict as? [String : Any]
            } catch {
                //print(error.localizedDescription)
            }
        }
        return nil
    }
}

