# YKSwiftSectionViewModel

[![Platform](https://img.shields.io/badge/swift-v4.0-yellow.svg)](https://cocoapods.org/pods/YKSwiftSectionViewModel) [! [Platform](https://img.shields.io/badge/platform-iOS 9-red.svg)](https://gitee.com/Edwrard/YKSwiftSectionViewModel) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://gitee.com/Edwrard/YKSwiftSectionViewModel/blob/master/LICENSE)

## Requirements

- iOS 9.0+ 
- Xcode 9.3+
- Swift 4.0+



## 

## Installation

YKSwiftSectionViewModel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YKSwiftSectionViewModel'
```

Then, run the following command:

```
$ pod install
```

## Example

### 1、init

```swift
let viewModel1 = ScTestViewModel.init()
let viewModel2 = ScTestViewModel.init()
let view = YKSectionCollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height),datas: [viewModel1,viewModel2])
view.errorCallBack = { error in
                      //TODO:receive error
                     }

view.endRefresh = {

}
        
        
view.setNoDataViewTip(tip: "no more data", font: UIFont.systemFont(ofSize: 10))
view.setNoDataViewImage(image: UIImage(named: "**"))
        
view.handleViewController = { vc,type,animate in
            if type == YKSectionViewModelPushType.Push.rawValue {
                self.navigationController?.pushViewController(vc, animated: animate)
            }else if type == YKSectionViewModelPushType.Present.rawValue {
                self.present(vc, animated: animate, completion: nil)
            }
                            }
```

### 2、initsubviewmodel

```swift
import YKSwiftSectionViewModel

class ScTestViewModel: YKSectionViewModelMainProtocol {
    
    private var count:Int = 0
    
    func yksc_numberOfItem() -> Int {
        return self.count
    }
    
    func yksc_beginToReloadData(mode: YKSectionViewModelRefreshMode.RawValue, reloadCallBack: @escaping ((Bool) -> Void), errrorCallBack: @escaping ((Error) -> Void)) {
       if mode == YKSectionViewModelRefreshMode.Header.rawValue {
           self.count += 5;
       }else if mode == YKSectionViewModelRefreshMode.Footer.rawValue {
           let error = NSError.init(domain: "YKSwiftSectionViewModel", code: -1, userInfo: [
               NSLocalizedDescriptionKey:"错误",
               NSLocalizedFailureReasonErrorKey:"错误",
               NSLocalizedRecoverySuggestionErrorKey:"请检查内容",
           ])
           errrorCallBack(error)
       }
       reloadCallBack(true)
    }
    
    func yksc_noDataShowHeaderFooter() -> Bool {
        return false
    }
    
    func yksc_idForItem(at indexPath: IndexPath) -> String {
        if ((indexPath.row % 2) == 1) {
            return "ScTest2Cell"
        }
        return "ScTestCell"
    }
    
    func yksc_registItems() -> Array<YKSectionResuseModel> {
        return [YKSectionResuseModel.init(className: ScTestCell.classForCoder(), classId: "ScTestCell"),YKSectionResuseModel.init(className: ScTest2Cell.classForCoder(), classId: "ScTest2Cell")]
    }
    
    func yksc_sizeOfItem(with width: CGFloat, atIndexPath: IndexPath) -> CGSize {
        if ((atIndexPath.row % 2) == 1) {
            return CGSize(width: width, height: 50)
        }
        return CGSize(width: width, height: 70)
    }
    
    func yksc_registHeader() -> YKSectionResuseModel {
        return YKSectionResuseModel.init(className: SCTestHeaderView.classForCoder(), classId: "SCTestHeaderView")
    }
    
    func yksc_sizeOfHeader(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 100)
    }
    
    func yksc_registFooter() -> YKSectionResuseModel {
        return YKSectionResuseModel.init(className: SCTestFooterView.classForCoder(), classId: "SCTestFooterView")
    }
    
    func yksc_sizeOfFooter(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 30)
    }
    
    func yksc_didSelectItem(at indexPath: IndexPath, callBack: ((UIViewController, YKSectionViewModelPushType.RawValue, Bool) -> Void)) {
        
    }
    
    func yksc_handleRouterEvent(eventName: String, userInfo: Dictionary<String, Any>, controllerEvent: ((UIViewController, YKSectionViewModelPushType.RawValue, Bool) -> Void)) -> Bool {
        
        if eventName == "test" {
            let vc = UIViewController.init()
            vc.view.backgroundColor = .red
            	controllerEvent(vc,YKSectionViewModelPushType.Push.rawValue,true)
        }
        
        return false
    }
```

### 3、initcell or header

```swift
import YKSwiftSectionViewModel

class ScTestCell: UICollectionViewCell,YKSectionViewModelResuseProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = UIView.init(frame: CGRect(x: 10, y: 10, width: self.bounds.size.width - 20, height: self.bounds.size.height - 20))
        view.backgroundColor = .red
        
        view.yk_tapOnView { tap in
            self.routerEvent(eventName: "123", userInfo: [:], needBuried: true)
        }
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(_ viewModel: YKSectionViewModelMainProtocol, _ atIndexPath: IndexPath) {
        
    }
}
```



## Author

edward, 534272374@qq.com

## License

YKSwiftSectionViewModel is available under the MIT license. See the LICENSE file for more info.
