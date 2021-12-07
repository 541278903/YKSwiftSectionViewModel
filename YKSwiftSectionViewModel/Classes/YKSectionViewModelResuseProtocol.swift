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
    @objc optional func loadData(_ viewModel:YKSectionViewModelMainProtocol, _ atIndexPath:IndexPath)->Void
}
