//
//  YKSectionTableView.swift
//  YKSwiftSectionViewModel
//
//  Created by edward on 2022/1/22.
//

import UIKit

public class YKSectionTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    
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
    
    private lazy var datas:Array<YKSectionTableViewProtocol> = []
    
    public var outTime:Double = 15
    
    public var errorCallBack:((_ error:Error) -> Void)?
    
    public var handleViewController:((_ controller:UIViewController, _ type:YKSectionViewModelPushType, _ animated:Bool) -> Void)?
    
    public var endRefresh:(() -> Void)?
    
    public var loadingCallBack:((_ isLoading:Bool) -> Void)?
    
    public init(frame: CGRect, datas:Array<YKSectionTableViewProtocol>) {
        super.init(frame: frame, style: .grouped)
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
        self.separatorStyle = .none
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        self.addNoDateView()
        self.initData()
        self.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
        self.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "UITableViewHeaderFooterView")
        
    }
    
    private func bindData() -> Void {
        //不再初始化的时候进行刷新数据
    }
    
    private func initData() -> Void {
        for obj in self.datas {
            let models = obj.yksc_registItems()
            for model in models {
                self.register(model.className, forCellReuseIdentifier: model.classId)
            }
            
            if let headerModel = obj.yksc_registHeader?() {
                for model in headerModel {
                    self.register(model.className, forHeaderFooterViewReuseIdentifier: model.classId)
                }
            }
            
            if let footerModel = obj.yksc_registFooter?() {
                for model in footerModel {
                    self.register(model.className, forHeaderFooterViewReuseIdentifier: model.classId)
                }
            }
        }
    }
    
    public func resetViewModels(datas:Array<YKSectionTableViewProtocol>) -> Void {
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
            //开始加载
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
        
        let reloadBlock = { [weak self] (obj:YKSectionTableViewProtocol) in
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
    
    //MARK: -delegate/datasource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.datas.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let obj = self.datas[section]
        return obj.yksc_numberOfItem()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        let obj = self.datas[indexPath.section]
        let Id = obj.yksc_idForItem(at: indexPath)
        if let myCell = tableView.dequeueReusableCell(withIdentifier: Id) {
            cell = myCell
            
            if cell.conforms(to: YKSectionViewModelResuseProtocol.self) {
                let cellP = cell as! YKSectionViewModelResuseProtocol
                if cellP.loadDataWithIndexPath?(obj, indexPath) == nil {
                    #if DEBUG
                    print("❌ \(cell)未实现loadDataWithIndexPath：")
                    #endif
                }
            }else {
                #if DEBUG
                print("❌ \(cell)未继承'YKSectionViewModelResuseProtocol'协议")
                #endif
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = self.datas[indexPath.section]
        let height:CGFloat = obj.yksc_heightOfItem(at: indexPath)
        return height
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 40
        let obj = self.datas[indexPath.section]
        if let myHeiht = obj.yksc_estimatedHeightOfItem?(at: indexPath) {
            height = myHeiht
        }
        return height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let obj = self.datas[section]
        
        var isShowHeaderFooter:Bool = true
        if let isShowHeaderFooterP = obj.yksc_noDataShowHeaderFooter?() {
            isShowHeaderFooter = isShowHeaderFooterP
        }
        let num = obj.yksc_numberOfItem()
        if (num > 0 || isShowHeaderFooter)  {
            if let headerId = obj.yksc_idForHeader?() {
                if headerId.count > 0 {
                    if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) {
                        if headerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                            let headerViewP = headerView as! YKSectionViewModelResuseProtocol
                            if headerViewP.loadDataWithSection?(obj, section) == nil {
                                #if DEBUG
                                print("❌ \(headerView)未实现loadDataWithSection：")
                                #endif
                            }
                        }else {
                            #if DEBUG
                            print("❌ \(headerView)未继承'YKSectionViewModelResuseProtocol'协议")
                            #endif
                        }
                        return headerView
                    }
                }
            }
        }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "UITableViewHeaderFooterView")
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        var estimateHeaderHeight:CGFloat = 40
        let obj = self.datas[section]
        if let myEstimateHeaderHeight = obj.yksc_estimatedHeightOfHeader?() {
            estimateHeaderHeight = myEstimateHeaderHeight
        }
        return estimateHeaderHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHeitht:CGFloat = 0
        let obj = self.datas[section]
        if let myHeaderHeight = obj.yksc_heightOfHeader?() {
            headerHeitht = myHeaderHeight
        }
        return headerHeitht
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let obj = self.datas[section]
        var isShowHeaderFooter:Bool = true
        if let isShowHeaderFooterP = obj.yksc_noDataShowHeaderFooter?() {
            isShowHeaderFooter = isShowHeaderFooterP
        }
        let num = obj.yksc_numberOfItem()
        if (num > 0 || isShowHeaderFooter)  {
            if let footerId = obj.yksc_idForFooter?() {
                if footerId.count > 0 {
                    if let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerId) {
                        if footerView.conforms(to: YKSectionViewModelResuseProtocol.self) {
                            let footerViewP = footerView as! YKSectionViewModelResuseProtocol
                            if footerViewP.loadDataWithSection?(obj, section) == nil {
                                #if DEBUG
                                print("❌ \(footerView)未实现loadDataWithSection：")
                                #endif
                            }
                        }else {
                            #if DEBUG
                            print("❌ \(footerView)未继承'YKSectionViewModelResuseProtocol'协议")
                            #endif
                        }
                        return footerView
                    }
                }
            }
        }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "UITableViewHeaderFooterView")
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        var estimateFooterHeight:CGFloat = 40
        let obj = self.datas[section]
        if let myEstimateFooterHeight = obj.yksc_estimatedHeightOfFooter?() {
            estimateFooterHeight = myEstimateFooterHeight
        }
        return estimateFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var footerHeitht:CGFloat = 0
        let obj = self.datas[section]
        if let myFooterHeight = obj.yksc_heightOfFooter?() {
            footerHeitht = myFooterHeight
        }
        return footerHeitht
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.datas[indexPath.section]
        if obj.yksc_didSelectItem?(at: indexPath, tableView: self, callBack: { [weak self] viewcontroller, type, animate in
            if let strongself = self {
                guard let handleCallBack = strongself.handleViewController else { return  }
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
            if let resultP = obj.yksc_handleRouterEvent?(eventName: eventName, userInfo: userInfo, tableView: self, callBack: handleCallBack) {
                result = (result || resultP)
            }
        }
        return result
    }
    
    //MARK: -private func
    
    
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