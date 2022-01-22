//
//  YKSectionCollectionView.swift
//  YKSwiftSectionViewModel
//
//  Created by edward on 2021/12/7.
//

import UIKit

public class YKSectionCollectionView: UICollectionView,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {

    private lazy var loading:Bool = false
    private var objcs:[String] = []
    
    private lazy var _nodataView:YKSectionNoDataView = {
        let view = YKSectionNoDataView.init(frame: self.bounds)
        view.reloadCallBack = { [weak self] in
            if let strongself = self {
                strongself.refreshData(mode: .Header)
            }
        }
        return view
    }()
    
    private lazy var datas:Array<YKSectionViewModelMainProtocol> = []
    
    public var outTime:Double = 15
    
    public var errorCallBack:((_ error:Error) -> Void)?
    
    public var handleViewController:((_ controller:UIViewController, _ type:YKSectionViewModelPushType, _ animated:Bool) -> Void)?
    
    public var endRefresh:(() -> Void)?
    
    public var loadingCallBack:((_ isLoading:Bool) -> Void)?
    
    public init(frame: CGRect, datas:Array<YKSectionViewModelMainProtocol>) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout.init())
        self.datas = datas
        self.setupUI()
        self.bindData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() -> Void {
        self.delegate = self
        self.dataSource = self
        self.alwaysBounceVertical = true
        self.alwaysBounceHorizontal = false
        self.backgroundColor = .clear
        self.addNoDateView()
        self.initData()
        self.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "UICollectionViewCell")
        self.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionReusableView")
        self.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "UICollectionReusableView")
    }
    
    private func bindData() -> Void {
        //不再初始化的时候进行刷新数据
//        self.refreshData(mode: .Header)
    }
    
    private func initData() -> Void {
        for obj in self.datas {
            let models = obj.yksc_registItems()
            for model in models {
                self.register(model.className, forCellWithReuseIdentifier: model.classId)
            }
            
            if let headerModel = obj.yksc_registHeader?() {
                for model in headerModel {
                    self.register(model.className, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: model.classId)
                }
            }
            
            if let footerModel = obj.yksc_registFooter?() {
                for model in footerModel {
                    self.register(model.className, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: model.classId)
                }
            }
        }
    }
    
    public func resetViewModels(datas:Array<YKSectionViewModelMainProtocol>) -> Void {
        self.datas = datas
        self.initData()
        self.reloadData()
    }
    
    public func refreshData(mode:YKSectionViewModelRefreshMode) -> Void
    {
        if self.loading {
            //已经加载中
            return
        }else {
            //已经加载中
            self.loading = true
            if let callBack = self.loadingCallBack {
                callBack(true)
            }
            self.startTimer()
        }
        if self.datas.count <= 0 {
            self.loading = false
            if let callBack = self.loadingCallBack {
                callBack(false)
            }
            self.stopTimer()
            self.reloadData()
            return
        }
        
        let reloadBlock = { [weak self] (obj:YKSectionViewModelMainProtocol) in
            let objcName = "d\(Unmanaged.passUnretained(obj).toOpaque())"
            if let strongself = self {
                if strongself.objcs.count > 0 {
                    strongself.objcs.remove(at: strongself.objcs.firstIndex(of: objcName)!)
                }
                if strongself.objcs.count <= 0 {
                    if strongself.loading {
                        strongself.loading = false
                        if let callBack = strongself.loadingCallBack {
                            callBack(false)
                        }
                        strongself.stopTimer()
                        strongself.reloadData()
                    }else {
                        strongself.reloadData()
                    }
                }
            }
        }
        for obj in self.datas {
            let objcName = "d\(Unmanaged.passUnretained(obj).toOpaque())"
            self.objcs.append(objcName)
            
        }
        
        for obj in self.datas {
            
            obj.yksc_beginToReloadData(mode: mode) {
                reloadBlock(obj)
            } errrorCallBack: { [weak self] (error) in
                if let strongself = self {
                    if strongself.errorCallBack != nil {
                        strongself.errorCallBack!(error)
                    }
                }
            }
        }
    }
    
    public func setNoDataViewTip(tip:String, font:UIFont) -> Void {
        self._nodataView.tipLabel.text = tip
        self._nodataView.tipLabel.font = font
    }
    
    public func setNoDataViewImage(image:UIImage?) -> Void {
        self._nodataView.tipImageView.image = image
    }
    
    //MARK: -reloadData
    
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
                self._nodataView.isHidden = false
            }else{
                //remove nodataView
                self._nodataView.isHidden = true
            }
        }else{
            //add NoData
            self._nodataView.isHidden = false
        }
    }
    
    //MARK: private func
    
    
    private func startTimer() -> Void {
        self.perform(#selector(outTimeTodo), with: nil, afterDelay: self.outTime)
    }
    
    private func stopTimer() -> Void {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.outTimeTodo), object: nil)
    }
    
    @objc private func outTimeTodo() -> Void {
        self.loading = false
        if let callBack = self.loadingCallBack {
            callBack(false)
        }
        self.objcs.removeAll()
        self.reloadData()
        if let block = self.errorCallBack {
            block(self.createError(errorMsg: "加载超时"))
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
            if let headerId = obj.yksc_idForHeader?() {
                var isShowHeaderFooter:Bool = true
                if let isShowHeaderFooterP = obj.yksc_noDataShowHeaderFooter?() {
                    isShowHeaderFooter = isShowHeaderFooterP
                }
                let num = obj.yksc_numberOfItem()
                if (num > 0 || isShowHeaderFooter)  {
                    if headerId.count > 0 {
                        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath)
                        if headerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                            let headerViewP = headerView as! YKSectionViewModelResuseProtocol
                            if headerViewP.loadData?(obj, indexPath) == nil {
                                #if DEBUG
                                print("❌ \(headerView)未实现loadData：")
                                #endif
                            }
                        }
                        return headerView
                    }
                }else {
                    return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionReusableView", for: indexPath)
                }
            }
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            if let footerId = obj.yksc_idForFooter?() {
                var isShowHeaderFooter:Bool = true
                if let isShowHeaderFooterP = obj.yksc_noDataShowHeaderFooter?() {
                    isShowHeaderFooter = isShowHeaderFooterP
                }
                let num = obj.yksc_numberOfItem()
                if (num > 0 || isShowHeaderFooter)  {
                    if footerId.count > 0 {
                        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerId, for: indexPath)
                        if footerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                            let headerViewP = footerView as! YKSectionViewModelResuseProtocol
                            if headerViewP.loadData?(obj, indexPath) == nil {
                                #if DEBUG
                                print("❌ \(footerView)未实现loadData：")
                                #endif
                            }
                        }
                        return footerView
                    }
                }else {
                    return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionReusableView", for: indexPath)
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
        let num = obj.yksc_numberOfItem()
        var isShowHeaderFooter:Bool = true
        if let isShowHeaderFooterP = obj.yksc_noDataShowHeaderFooter?() {
            isShowHeaderFooter = isShowHeaderFooterP
        }
        if (num > 0 || isShowHeaderFooter)  {
            if let sizeP = obj.yksc_sizeOfHeader?(width: collectionView.bounds.size.width) {
                size = sizeP
            }
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let obj = self.datas[section]
        var size = CGSize(width: collectionView.bounds.size.width, height: 0)
        let num = obj.yksc_numberOfItem()
        var isShowHeaderFooter:Bool = true
        if let isShowHeaderFooterP = obj.yksc_noDataShowHeaderFooter?() {
            isShowHeaderFooter = isShowHeaderFooterP
        }
        if (num > 0 || isShowHeaderFooter)  {
            if let sizeP = obj.yksc_sizeOfFooter?(width: collectionView.bounds.size.width) {
                size = sizeP
            }
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
        if obj.yksc_didSelectItem?(at: indexPath, collectionView: self, callBack: { [weak self] viewcontroller, type, animate in
            if let strongself = self {
                guard let handleCallBack = strongself.handleViewController else {
                    return
                }
                handleCallBack(viewcontroller,type,animate)
            }
        }) == nil {
            
        }
    }
    
    //MARK: -handleRouter
    public func handleRouter(eventName:String, userInfo:Dictionary<String,Any>) -> Bool {
        var result = false
        
        for obj in self.datas {
            guard let handleCallBack = self.handleViewController else {
                return result
            }
            if let resultP = obj.yksc_handleRouterEvent?(eventName: eventName, userInfo: userInfo, collectionView: self, callBack: handleCallBack) {
                result = (result || resultP)
            }
            
        }
        
        return result
    }
    
    private func addNoDateView() ->Void {
        self.addSubview(self._nodataView)
    }
    
    private func createError(errorMsg:String) ->NSError {
        let error = NSError.init(domain: "YKSwiftSectionViewModel", code: -1, userInfo: [
            NSLocalizedDescriptionKey:errorMsg,
            NSLocalizedFailureReasonErrorKey:errorMsg,
            NSLocalizedRecoverySuggestionErrorKey:"请检查内容",
        ])
        return error
    }

}
