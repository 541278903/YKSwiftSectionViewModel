//
//  YKSectionViewModelResuseProtocol.swift
//  YKSwiftSectionViewModel
//
//  Created by linghit on 2021/12/7.
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
    @objc optional func loadData(_ viewModel:YKSectionViewModelMainProtocol, _ atIndexPath:IndexPath)->Void
}
