//
//  YKSectionCollectionView.swift
//  YKSwiftSectionViewModel
//
//  Created by linghit on 2021/12/7.
//

import UIKit

public class YKSectionCollectionView: UICollectionView,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    public var errorCallBack:((_ error:Error)->Void)?
    
    public var handleViewController:((_ controller:UIViewController, _ type:YKSectionViewModelPushType.RawValue, _ animated:Bool)->Void)?
    
    public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout ,datas:Array<YKSectionViewModelMainProtocol>) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
    }
    
    public func refreshData(mode:YKSectionViewModelRefreshMode)->Void
    {
        
    }
    
    public func addSubViewModel(viewMode:YKSectionViewModelMainProtocol)->Void
    {
        
    }
    
    public func addSubViewModel(viewMode:YKSectionViewModelMainProtocol, atIndex:Int)->Void
    {
        
    }
    
    public func handleRouter(eventName:String, userInfo:Dictionary<String,Any>)->Bool
    {
        var result = false
        result = true
        return result
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
