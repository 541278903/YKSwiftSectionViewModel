//
//  YKSectionCollectionView.swift
//  YKSwiftSectionViewModel
//
//  Created by edward on 2021/12/7.
//

import UIKit

public class YKSectionCollectionView: UICollectionView {

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
    
    private lazy var datas:[YKSectionCollectionViewProtocol] = []
    
    public var outTime:Double = 15
    
    private var errorCallBack:((_ error:Error) -> Void)?
    
    private var handleViewController:((_ controller:UIViewController, _ type:YKSectionViewModelPushType, _ animated:Bool) -> Void)?
    
    private var endRefresh:((_ isNoMoreData:Bool) -> Void)?
    
    private var loadingCallBack:((_ isLoading:Bool) -> Void)?
    
    private var isNoData:Bool = false
    
    private var isNoMoreData:Bool = false
    
    
    public init(frame: CGRect, layout:UICollectionViewLayout, datas:[YKSectionCollectionViewProtocol]) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.datas = datas
        self.setupUI()
        self.bindData()
    }
    
    public convenience init(frame: CGRect, datas:[YKSectionCollectionViewProtocol]) {
        self.init(frame: frame, layout: UICollectionViewFlowLayout.init(), datas: datas)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - reloadData
    public override func reloadData() {
        self.endRefresh?(self.isNoMoreData)
        super.reloadData()
        self._nodataView.isShowNoData(noData: self.isNoMoreData)
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
}

//MARK: - public func
public extension YKSectionCollectionView {
    
    func resetViewModels(datas:[YKSectionCollectionViewProtocol]) -> Void {
        self.datas = datas
        self.initData()
        self.reloadData()
    }
    
    func refreshData(mode:YKSectionViewModelRefreshMode) -> Void
    {
        if self.loading {
            //???????????????
            return
        }else {
            //????????????
            self.loading = true
            self.loadingCallBack?(true)
            self.startTimer()
        }
        if self.datas.count <= 0 {
            self.loading = false
            self.isNoData = true
            self.isNoMoreData = false
            self.loadingCallBack?(false)
            self.stopTimer()
            self.reloadData()
            return
        }
        
        let reloadBlock = { [weak self] (obj:YKSectionCollectionViewProtocol, isNoMoreData:Bool) in
            guard let weakself = self else { return }
            let objcName = "d\(Unmanaged.passUnretained(obj).toOpaque())"
            weakself.isNoData = true
            weakself.isNoMoreData = weakself.isNoMoreData && isNoMoreData
            if weakself.objcs.count > 0 {
                weakself.objcs.remove(at: weakself.objcs.firstIndex(of: objcName)!)
            }
            if weakself.objcs.count <= 0 {
                if weakself.loading {
                    weakself.loading = false
                    weakself.isNoMoreData = false
                    if let callBack = weakself.loadingCallBack {
                        callBack(false)
                    }
                    weakself.stopTimer()
                    weakself.reloadData()
                }else {
                    weakself.reloadData()
                }
            }
        }
        for obj in self.datas {
            let objcName = "d\(Unmanaged.passUnretained(obj).toOpaque())"
            self.objcs.append(objcName)
            
        }
        
        for obj in self.datas {
            obj.yksc_beginToReloadData(mode: mode) { isNoMoreData in
                reloadBlock(obj,isNoMoreData)
            } errorCallBack: { [weak self] error in
                guard let weakSelf = self else { return }
                weakSelf.errorCallBack!(error)
            }

        }
    }
    
    func setNoDataViewTip(tip:String, font:UIFont) -> Void {
        self._nodataView.tipLabel.text = tip
        self._nodataView.tipLabel.font = font
    }
    
    func setNoDataViewImage(image:UIImage?) -> Void {
        self._nodataView.tipImageView.image = image
    }
    
    func toSetErrorCallBack(errorCallBack:@escaping (_ error:Error) -> Void) {
        if self.errorCallBack == nil {
            self.errorCallBack = errorCallBack
        }else {
            #if DEBUG
            print("??? errorCallBack??????????????????????????????")
            #endif
        }
    }
    
    func toSetHandleViewController(handleViewController:@escaping ((_ controller:UIViewController, _ type:YKSectionViewModelPushType, _ animated:Bool) -> Void)) {
        if self.handleViewController == nil {
            self.handleViewController = handleViewController
        }else {
            #if DEBUG
            print("??? handleViewController??????????????????????????????")
            #endif
        }
    }
    
    func toSetEndRefresh(endRefresh:@escaping ((_ isNoMoreData:Bool) -> Void)) {
        if self.endRefresh == nil {
            self.endRefresh = endRefresh
        }else {
            #if DEBUG
            print("??? endRefresh??????????????????????????????")
            #endif
        }
    }
    
    func toSetLoadingCallBack(loadingCallBack:@escaping ((_ isLoading:Bool) -> Void)) {
        if self.loadingCallBack == nil {
            self.loadingCallBack = loadingCallBack
        }else {
            #if DEBUG
            print("??? loadingCallBack??????????????????????????????")
            #endif
        }
    }
    
    func handleRouter(eventName:String, userInfo:[String:Any]) -> Bool {
        var result = false

        for obj in self.datas {
            if let resultP = obj.yksc_handleRouterEvent?(eventName: eventName, userInfo: userInfo, collectionView: self, callBack: self.handleViewController ?? { _,_,_ in
                
            }) {
                result = (result || resultP)
            }

        }

        return result
    }
}

//MARK: - dataSource
extension YKSectionCollectionView: UICollectionViewDataSource {
    
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let obj = self.datas[section]
        return obj.yksc_numberOfItem()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "YKSectionCollectionViewCell", for: indexPath)
        let obj = self.datas[indexPath.section]
        let Id = obj.yksc_idForItem(at: indexPath)
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: Id, for: indexPath)
        
        if let yk_collectionViewCell = cell as? YKSectionCollectionViewCell
        {
            yk_collectionViewCell.toSetClickEvent { [weak self] eventName, userInfo in
                guard let weakself = self else { return }
                let model = weakself.datas[indexPath.section]
                let _ = model.yksc_handleRouterEvent?(eventName: eventName, userInfo: userInfo ?? [:], collectionView: weakself, callBack: weakself.handleViewController ?? { _,_,_ in
                    
                })
            }
        }
        
        if cell.conforms(to: YKSectionViewModelResuseProtocol.self) {
            let cellP = cell as! YKSectionViewModelResuseProtocol
            if cellP.loadDataWithIndexPath?(obj, indexPath) == nil {
                #if DEBUG
                print("??? \(cell)?????????loadDataWithIndexPath???")
                #endif
            }
        }else {
            #if DEBUG
            print("??? \(cell)?????????'YKSectionViewModelResuseProtocol'??????")
            #endif
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
                        
                        
                        if let yk_collectionViewHeader = headerView as? YKSectionCollectionHeaderFooterView {
                            yk_collectionViewHeader.toSetClickEvent { [weak self] eventName, userInfo in
                                guard let weakself = self else { return }
                                let model = weakself.datas[indexPath.section]
                                let _ = model.yksc_handleRouterEvent?(eventName: eventName, userInfo: userInfo ?? [:], collectionView: weakself, callBack: weakself.handleViewController ?? { _,_,_ in
                                    
                                })
                            }
                        }
                        
                        if headerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                            let headerViewP = headerView as! YKSectionViewModelResuseProtocol
                            if headerViewP.loadDataWithIndexPath?(obj, indexPath) == nil {
                                #if DEBUG
                                print("??? \(headerView)?????????loadDataWithIndexPath???")
                                #endif
                            }
                        }else {
                            #if DEBUG
                            print("??? \(headerView)?????????'YKSectionViewModelResuseProtocol'??????")
                            #endif
                        }
                        return headerView
                    }
                }else {
                    return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "YKSectionCollectionHeaderFooterView", for: indexPath)
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
                        
                        if let yk_collectionViewFooter = footerView as? YKSectionCollectionHeaderFooterView {
                            yk_collectionViewFooter.toSetClickEvent { [weak self] eventName, userInfo in
                                guard let weakself = self else { return }
                                let model = weakself.datas[indexPath.section]
                                let _ = model.yksc_handleRouterEvent?(eventName: eventName, userInfo: userInfo ?? [:], collectionView: weakself, callBack: weakself.handleViewController ?? { _,_,_ in
                                    
                                })
                            }
                        }
                        
                        if footerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                            let headerViewP = footerView as! YKSectionViewModelResuseProtocol
                            if headerViewP.loadDataWithIndexPath?(obj, indexPath) == nil {
                                #if DEBUG
                                print("??? \(footerView)?????????loadDataWithIndexPath???")
                                #endif
                            }
                        }else {
                            #if DEBUG
                            print("??? \(footerView)?????????'YKSectionViewModelResuseProtocol'??????")
                            #endif
                        }
                        return footerView
                    }
                }else {
                    return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "YKSectionCollectionHeaderFooterView", for: indexPath)
                }
            }
        }
        
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionReusableView", for: indexPath)
    }
    
    
}

//MARK: - delegate
extension YKSectionCollectionView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = self.datas[indexPath.section]
        if obj.yksc_didSelectItem?(at: indexPath, collectionView: self, callBack: { [weak self] viewcontroller, type, animate in
            if let strongself = self {
                guard let handleCallBack = strongself.handleViewController else { return  }
                handleCallBack(viewcontroller,type,animate)
            }
        }) == nil {
            
        }
    }
}

//MARK: - flowLayout
extension YKSectionCollectionView: UICollectionViewDelegateFlowLayout {
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let obj = self.datas[indexPath.section]
        return obj.yksc_sizeOfItem(with: collectionView.bounds.size.width, atIndexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let obj = self.datas[section]
        let size = CGSize(width: collectionView.bounds.size.width, height: 0)
        let num = obj.yksc_numberOfItem()
        let isShowHeaderFooter = obj.yksc_noDataShowHeaderFooter?() ?? false
        
        if (num > 0 || isShowHeaderFooter)  {
            return obj.yksc_sizeOfHeader?(with: collectionView.bounds.size.width) ?? size
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        let obj = self.datas[section]
        let size = CGSize(width: collectionView.bounds.size.width, height: 0)
        let num = obj.yksc_numberOfItem()
        let isShowHeaderFooter = obj.yksc_noDataShowHeaderFooter?() ?? false
        
        if (num > 0 || isShowHeaderFooter)  {
            return obj.yksc_sizeOfFooter?(with: collectionView.bounds.size.width) ?? size
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let obj = self.datas[section]
        return obj.yksc_sectionMinimumLineSpacing?() ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let obj = self.datas[section]
        return obj.yksc_sectionMinimumInteritemSpacing?() ?? 0
    }
    
    
}

//MARK: - private func
private extension YKSectionCollectionView {
    
    private func setupUI() -> Void {
        self.delegate = self
        self.dataSource = self
        self.alwaysBounceVertical = true
        self.alwaysBounceHorizontal = false
        self.backgroundColor = .clear
        self.addNoDateView()
        self.initData()
        self.register(YKSectionCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "YKSectionCollectionViewCell")
        self.register(YKSectionCollectionHeaderFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "YKSectionCollectionHeaderFooterView")
        self.register(YKSectionCollectionHeaderFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "YKSectionCollectionHeaderFooterView")
        self.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionReusableView")
        self.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "UICollectionReusableView")
    }
    
    private func bindData() -> Void {
        
        
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
            block(self.createError(errorMsg: "????????????"))
        }
    }
    
    private func addNoDateView() ->Void {
        self.addSubview(self._nodataView)
    }
    
    private func createError(errorMsg:String) ->NSError {
        let error = NSError.init(domain: "yk.swift.scetionCollectionView", code: -1, userInfo: [
            NSLocalizedDescriptionKey:errorMsg,
            NSLocalizedFailureReasonErrorKey:errorMsg,
            NSLocalizedRecoverySuggestionErrorKey:"???????????????",
        ])
        return error
    }
    
}
