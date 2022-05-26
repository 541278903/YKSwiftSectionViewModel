//
//  YKSectionCollectionViewCell.swift
//  YKSwiftSectionViewModel
//
//  Created by linghit on 2022/5/26.
//

import UIKit

public class YKSectionCollectionViewCell: UICollectionViewCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI(self.contentView)
        bindData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(_ view:UIView) {
        
    }
    
    private func bindData() {
        
    }
}
