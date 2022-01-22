//
//  YKSectionViewModelResuseProtocol.swift
//  YKSwiftSectionViewModel
//
//  Created by edward on 2021/12/7.
//

import Foundation
import UIKit


@objc public protocol YKSectionViewModelResuseProtocol
{
    
    /// 加载当前内容信息
    /// - Parameters:
    ///   - viewModel: 当前viewmodel
    ///   - atIndexPath: 索引
    /// - Returns: 无
    @objc optional func loadDataWithIndexPath(_ viewModel:YKSectionMainProtocol, _ atIndexPath:IndexPath) -> Void
    
    
    /// 加载当前内容信息
    /// - Parameters:
    ///   - viewModel: 当前viewmodel
    ///   - atSection: 索引
    /// - Returns: 无
    @objc optional func loadDataWithSection(_ viewModel:YKSectionMainProtocol, _ atSection:Int) -> Void
}
