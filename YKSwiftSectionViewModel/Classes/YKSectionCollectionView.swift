//
//  YKSectionCollectionView.swift
//  YKSwiftSectionViewModel
//
//  Created by linghit on 2021/12/7.
//

import UIKit

public class YKSectionCollectionView: UICollectionView,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    public var nodataView:YKSectionNoDataView {
        get {
            let view = YKSectionNoDataView.init(frame: self.bounds)
            view.reloadCallBack = {
                self.refreshData(mode: .Header)
            }
            return view
        }
    }
    
    private lazy var datas:Array<YKSectionViewModelMainProtocol> = []
    
    public var errorCallBack:((_ error:Error)->Void)?
    
    public var handleViewController:((_ controller:UIViewController, _ type:YKSectionViewModelPushType.RawValue, _ animated:Bool)->Void)?
    
    public var endRefresh:(()->Void)?
    
    public init(frame: CGRect,datas:Array<YKSectionViewModelMainProtocol>) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout.init())
        self.datas = datas
        self.setupUI()
        self.bindData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI()->Void
    {
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .clear
        self.initData()
        self.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "UICollectionViewCell")
        self.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionReusableView")
        self.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "UICollectionReusableView")
    }
    
    private func bindData()->Void
    {
        self.refreshData(mode: .Header)
    }
    
    private func initData()->Void
    {
        for obj in self.datas {
            let models = obj.yksc_registItems()
            for model in models {
//                let classP = NSClassFromString(model.className)
                self.register(model.className, forCellWithReuseIdentifier: model.classId)
            }
            
            if let headerModel = obj.yksc_registHeader?() {
                self.register(headerModel.className, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerModel.classId)
            }
            
            if let footerModel = obj.yksc_registFooter?() {
                self.register(footerModel.className, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerModel.classId)
            }
        }
    }
    
    public func addSubViewModel(viewModel:YKSectionViewModelMainProtocol)->Void
    {
        self.datas.append(viewModel)
        self.initData()
        self.reloadData()
    }
    
    public func addSubViewModel(viewModel:YKSectionViewModelMainProtocol, atIndex:Int)->Void
    {
        self.datas.insert(viewModel, at: atIndex)
        self.initData()
        self.reloadData()
    }
    
    public func refreshData(mode:YKSectionViewModelRefreshMode)->Void
    {
        for obj in self.datas {
            obj.yksc_beginToReloadData(mode: mode.rawValue) { isReload in
                if isReload {
                    self.reloadData()
                }
            }
        }
    }
    
    public override func reloadData() {
        if self.endRefresh != nil {
            self.endRefresh!()
        }
        super.reloadData()
        if self.datas.count >= 0 {
            var count:Int = 0
            for obj in self.datas {
                count = count + obj.yksc_numberOfItem()
            }
            if count <= 0 {
                //add nodata
                self.addSubview(self.nodataView)
            }else{
                //remove nodataView
                self.nodataView.removeFromSuperview()
            }
        }else{
            //add NoData
            self.addSubview(self.nodataView)
        }
    }
    
    //MARK: -delegate/datasource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let obj = self.datas[section]
        return obj.yksc_numberOfItem()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        let obj = self.datas[indexPath.section]
        let Id = obj.yksc_idForItem(at: indexPath)
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: Id, for: indexPath)
        
        if cell.conforms(to: YKSectionViewModelResuseProtocol.self) {
            let cellP = cell as! YKSectionViewModelResuseProtocol
            if cellP.loadData?(obj, indexPath) == nil {
                #if DEBUG
                print("❌ \(cell)未实现loadData：")
                #endif
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let obj = self.datas[indexPath.section]
        
        if kind == UICollectionView.elementKindSectionHeader {
            if let model = obj.yksc_registHeader?() {
                let headerId = model.classId
                if headerId.count > 0 {
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath)
                    if headerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                        let headerViewP = headerView as! YKSectionViewModelResuseProtocol
                        if headerViewP.loadData?(obj, indexPath) == nil {
                            #if DEBUG
                            print("❌ \(headerView)未实现loadData：")
                            #endif
                        }
                        return headerView
                    }
                }
            }
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            if let model = obj.yksc_registFooter?() {
                let footerId = model.classId
                if footerId.count > 0 {
                    let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerId, for: indexPath)
                    if footerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                        let headerViewP = footerView as! YKSectionViewModelResuseProtocol
                        if headerViewP.loadData?(obj, indexPath) == nil {
                            #if DEBUG
                            print("❌ \(footerView)未实现loadData：")
                            #endif
                        }
                        return footerView
                    }
                }
            }
        }
        
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionReusableView", for: indexPath)
    }
    
    //MARK: -fulllayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let obj = self.datas[indexPath.section]
        let size = obj.yksc_sizeOfItem(with: collectionView.bounds.size.width, atIndexPath: indexPath)
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let obj = self.datas[section]
        var size = CGSize(width: collectionView.bounds.size.width, height: 0)
        if let sizeP = obj.yksc_sizeOfHeader?(width: collectionView.bounds.size.width) {
            size = sizeP
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let obj = self.datas[section]
        var size = CGSize(width: collectionView.bounds.size.width, height: 0)
        if let sizeP = obj.yksc_sizeOfFooter?(width: collectionView.bounds.size.width) {
            size = sizeP
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let obj = self.datas[section]
        var lineSpacing:CGFloat = 0
        if let lineSpacingP = obj.yksc_sectionMinimumLineSpacing?() {
            lineSpacing = lineSpacingP
        }
        return lineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let obj = self.datas[section]
        var interItemSpacing:CGFloat = 0
        if let interItemSpacingP = obj.yksc_sectionMinimumInteritemSpacing?() {
            interItemSpacing = interItemSpacingP
        }
        return interItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = self.datas[indexPath.section]
        if obj.yksc_didSelectItem?(at: indexPath, callBack: { viewcontroller, type, animate in
            guard let handleCallBack = self.handleViewController else {
                return
            }
            handleCallBack(viewcontroller,type,animate)
        }) == nil {
            
        }
    }
    
    //MARK: -handleRouter
    public func handleRouter(eventName:String, userInfo:Dictionary<String,Any>)->Bool
    {
        var result = false
        
        for obj in self.datas {
            guard let handleCallBack = self.handleViewController else {
                return result
            }
            if let resultP = obj.yksc_handleRouterEvent?(eventName: eventName, userInfo: userInfo, controllerEvent: handleCallBack) {
                result = (result || resultP)
            }
            
        }
        
        return result
    }
    
    private func addNoDateView()->Void {
        
    }
    
    private func createError(errorMsg:String)->Void
    {
        let error = NSError.init(domain: "YKSwiftSectionViewModel", code: -1, userInfo: [
            NSLocalizedDescriptionKey:errorMsg,
            NSLocalizedFailureReasonErrorKey:errorMsg,
            NSLocalizedRecoverySuggestionErrorKey:"请检查内容",
        ])
        guard let errorBlock = self.errorCallBack else {
            return
        }
        errorBlock(error)
    }

}
