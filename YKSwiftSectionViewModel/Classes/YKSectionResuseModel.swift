//
//  YKSectionResuseModel.swift
//  YKSwiftSectionViewModel
//
//  Created by linghit on 2021/12/7.
//

import Foundation

public class YKSectionResuseModel: NSObject {
    
    public var className:String = ""
    public var classId:String = ""
    
    public init(className:String,classId:String) {
        super.init()
        self.className = className
        self.classId = classId
    }

}
