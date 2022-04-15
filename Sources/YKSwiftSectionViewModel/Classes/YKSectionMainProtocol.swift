//
//  YKSectionMainProtocol.swift
//  YKSwiftSectionViewModel
//
//  Created by edward on 2022/1/22.
//

import Foundation

@objc public enum YKSectionViewModelPushType:Int {
    case Push = 0
    case Present = 1
}

@objc public enum YKSectionViewModelRefreshMode:Int {
    case Header = 0
    case Footer = 1
}

//@objc public enum YKSectionViewModelEndRefreshResult:Int {
//    case Success = 0
//    case Timeout = 1
//}

@objc public protocol YKSectionMainProtocol
{
    
    /// 获取当前section有多少item
    /// - Returns: 获取有多少item
    func yksc_numberOfItem() -> Int
    
    /// 开始刷新Push
    /// - Parameters:
    ///   - mode: 刷新模式
    ///   - reloadCallBack: 刷新回调
    /// - Returns: 无
    func yksc_beginToReloadData(mode:YKSectionViewModelRefreshMode, reloadCallBack:@escaping ((_ isNoMoreData:Bool) -> Void), errrorCallBack:@escaping ((Error) -> Void)) -> Void;
    
    /// 获取当前行所需要的cellid
    /// - Parameter indexPath: 索引
    /// - Returns: Id
    func yksc_idForItem(at indexPath:IndexPath) -> String
    
    /// 注册cells
    /// - Returns: 所有cell的集合
    func yksc_registItems() -> Array<YKSectionResuseModel>
    
    /// 没有数据时是否显示头部和底部
    /// - Returns: 是否显示默认不显示
    @objc optional func yksc_noDataShowHeaderFooter() -> Bool
    
    /// 注册当前section头部
    /// - Returns: 头部信息
    @objc optional func yksc_registHeader() -> Array<YKSectionResuseModel>
    
    /// 获取当前需要的header的Id
    /// - Returns: sectionheader Id
    @objc optional func yksc_idForHeader() -> String
    
    /// 注册当前section底部
    /// - Returns: 底部信息
    @objc optional func yksc_registFooter() -> Array<YKSectionResuseModel>
    
    /// 获取当前需要的header的Id
    /// - Returns: sectionheader Id
    @objc optional func yksc_idForFooter() -> String
    
    
}

