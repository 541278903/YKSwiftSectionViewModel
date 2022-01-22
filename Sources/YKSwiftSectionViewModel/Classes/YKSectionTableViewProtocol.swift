//
//  YKSectionTableViewProtocol.swift
//  YKSwiftSectionViewModel
//
//  Created by edward on 2022/1/22.
//

import Foundation
import UIKit

@objc public protocol YKSectionTableViewProtocol : YKSectionMainProtocol
{
    /// 获取当前cell的高度
    /// - Parameters:
    ///   - atIndexPath: 索引
    /// - Returns: cell的高度
    func yksc_heightOfItem(at indexPath:IndexPath) -> CGFloat
    
    /// 获取当前cell的估高
    /// - Returns: 估高
    @objc optional func yksc_estimatedHeightOfItem(at indexPath:IndexPath) -> CGFloat
    
    /// 获取当前头部高度
    /// - Returns: 头部的高度
    @objc optional func yksc_heightOfHeader() -> CGFloat
    
    /// 获取当前头部估高
    /// - Returns: 估高
    @objc optional func yksc_estimatedHeightOfHeader() -> CGFloat
    
    /// 获取当前底部高度
    /// - Returns: 高度
    @objc optional func yksc_heightOfFooter() -> CGFloat
    
    /// 获取当前底部高度
    /// - Returns: 估高
    @objc optional func yksc_estimatedHeightOfFooter() -> CGFloat
    
    
    /// 获取当前cell点击事件
    @objc optional func yksc_didSelectItem(at indexPath:IndexPath, tableView:YKSectionTableView, callBack:((_ viewcontroller:UIViewController, _ type:YKSectionViewModelPushType , _ animate:Bool) -> Void))
    
    /// 获取响应内容触发机制
    /// - Parameters:
    ///   - eventName: 响应头部信息
    ///   - userInfo: 响应内容
    ///   - controllerEvent: 控制回调
    /// - Returns: 是否作出响应
    @objc optional func yksc_handleRouterEvent(eventName:String, userInfo:Dictionary<String,Any>, tableView:YKSectionTableView, callBack:((_ viewcontroller:UIViewController, _ type:YKSectionViewModelPushType, _ animate:Bool) -> Void)) -> Bool
}
