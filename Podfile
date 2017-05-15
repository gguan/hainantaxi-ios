platform :ios, '8.0'
use_frameworks!

def baseframework 
    pod 'RxSwift',    '~> 3.0'
    pod 'RxCocoa',    '~> 3.0'
    pod 'ObjectMapper'
end

def netframework 
    pod 'Alamofire'
    pod 'CocoaMQTT'
end

def authframework
    pod 'MonkeyKing'
end


def uiframework
    pod 'YYWebImage'
    pod 'YYImage/WebP'
    pod 'FDFullscreenPopGesture'
    pod 'YYText'
    pod 'SVProgressHUD'
    pod 'IQKeyboardManagerSwift'
    pod 'SnapKit'
    pod 'MJRefresh'
    pod 'AMap3DMap'
end

def cacheframework
    pod 'YYCache'
    pod 'KeychainAccess'
end


def mapframework
    pod 'AMapSearch'
end

target 'HNTaxi' do
    pod 'R.swift'
    baseframework
    uiframework
    mapframework
end

target 'HNTaxiKit' do
    baseframework
    authframework
end

target 'NetworkService' do
    baseframework
    netframework
end

target 'CacheService' do
    cacheframework
end
