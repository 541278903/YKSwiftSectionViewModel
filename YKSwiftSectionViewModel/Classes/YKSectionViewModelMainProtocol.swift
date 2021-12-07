//
//  YKSectionViewModelMainProtocol.swift
//  YKSwiftSectionViewModel
//
//  Created by linghit on 2021/12/7.
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
    func yksc_beginToReloadData(mode:YKSectionViewModelRefreshMode.RawValue, reloadCallBack:@escaping ((Bool)->Void))->Void;
    
    func yksc_idForItem(at indexPath:IndexPath)->String
    
    func yksc_registItems()->Array<YKSectionResuseModel>
    
    func yksc_sizeOfItem(with width:CGFloat, atIndexPath:IndexPath)->CGSize
    
    @objc optional func yksc_registHeader()->YKSectionResuseModel
    
    @objc optional func yksc_sizeOfHeader(width:CGFloat)->CGSize
    
    @objc optional func yksc_registFooter()->YKSectionResuseModel
    
    @objc optional func yksc_sizeOfFooter(width:CGFloat)->CGSize
    
    @objc optional func yksc_sectionMinimumLineSpacing()->CGFloat
    
    @objc optional func yksc_sectionMinimumInteritemSpacing()->CGFloat
    
    @objc optional func yksc_didSelectItem(at indexPath:IndexPath, callBack:((_ viewcontroller:UIViewController, _ type:YKSectionViewModelPushType.RawValue , _ animate:Bool)->Void))
    
    @objc optional func yksc_handleRouterEvent(eventName:String, userInfo:Dictionary<String,Any>, controllerEvent:((_ viewcontroller:UIViewController, _ type:YKSectionViewModelPushType.RawValue, _ animate:Bool)->Void))->Bool
}
