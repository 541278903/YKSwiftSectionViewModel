//
//  YKSectionViewModelMainProtocol.swift
//  YKSwiftSectionViewModel
//
//  Created by edward on 2021/12/7.
//

import Foundation
import UIKit

public enum YKSectionViewModelPushType:Int {
    case Push = 0
    case Present = 1
}

public enum YKSectionViewModelRefreshMode:Int {
    case Header = 0
    case Footer = 1
}

@objc public protocol YKSectionViewModelMainProtocol
{
    
    /// 获取当前section有多少item
    /// - Returns: 获取有多少item
    func yksc_numberOfItem()->Int
    
    /// 开始刷新Push
    /// - Parameters:
    ///   - mode: 刷新模式
    ///   - reloadCallBack: 刷新回调
    /// - Returns: 无
    func yksc_beginToReloadData(mode:YKSectionViewModelRefreshMode.RawValue, reloadCallBack:@escaping ((Bool)->Void), errrorCallBack:@escaping ((Error)->Void))->Void;
    
    /// 获取当前行所需要的cellid
    /// - Parameter indexPath: 索引
    /// - Returns: Id
    func yksc_idForItem(at indexPath:IndexPath)->String
    
    /// 注册cells
    /// - Returns: 所有cell的集合
    func yksc_registItems()->Array<YKSectionResuseModel>
    
    /// 获取当前cell的尺寸
    /// - Parameters:
    ///   - width: 当前collectionview宽度
    ///   - atIndexPath: 索引
    /// - Returns: 尺寸
    func yksc_sizeOfItem(with width:CGFloat, atIndexPath:IndexPath)->CGSize
    
    /// 注册当前section头部
    /// - Returns: 头部信息
    @objc optional func yksc_registHeader()->YKSectionResuseModel
    
    /// 没有数据时是否显示头部和底部
    /// - Returns: 是否显示默认不显示
    @objc optional func yksc_noDataShowHeaderFooter()->Bool
    
    /// 获取当前头部尺寸
    /// - Parameter width: 当前collectionview宽度
    /// - Returns: 尺寸
    @objc optional func yksc_sizeOfHeader(width:CGFloat)->CGSize
    
    /// 注册当前section底部
    /// - Returns: 底部信息
    @objc optional func yksc_registFooter()->YKSectionResuseModel
    
    /// 获取当前底部尺寸
    /// - Parameter width: 当前collectionview宽度
    /// - Returns: 尺寸
    @objc optional func yksc_sizeOfFooter(width:CGFloat)->CGSize
    
    /// 获取最小行间距
    /// - Returns: 距离
    @objc optional func yksc_sectionMinimumLineSpacing()->CGFloat
    
    /// 获取最小列距离
    /// - Returns: 距离
    @objc optional func yksc_sectionMinimumInteritemSpacing()->CGFloat
    
    /// 获取当前cell点击事件
    @objc optional func yksc_didSelectItem(at indexPath:IndexPath, callBack:((_ viewcontroller:UIViewController, _ type:YKSectionViewModelPushType.RawValue , _ animate:Bool)->Void))
    
    /// 获取响应内容触发机制
    /// - Parameters:
    ///   - eventName: 响应头部信息
    ///   - userInfo: 响应内容
    ///   - controllerEvent: 控制回调
    /// - Returns: 是否作出响应
    @objc optional func yksc_handleRouterEvent(eventName:String, userInfo:Dictionary<String,Any>, controllerEvent:((_ viewcontroller:UIViewController, _ type:YKSectionViewModelPushType.RawValue, _ animate:Bool)->Void))->Bool
}
