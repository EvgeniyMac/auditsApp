source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'

inhibit_all_warnings!

project 'Education'

use_frameworks!

def common_pods
    pod 'Alamofire', '4.7.3'
    pod 'AlamofireObjectMapper', '5.1.0'
    pod 'AlamofireImage', '3.4.1'
    pod 'AlamofireNetworkActivityLogger', '2.3.0'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Firebase/Auth'
end

def tracking_pods
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
#    pod 'Fabric'
#    pod 'Crashlytics'
end

def ui_pods
    pod 'CountryPickerView', '2.2.4'
    pod 'NVActivityIndicatorView', '4.4.0'
#    pod 'Charts', '3.2.2'
    pod 'InputMask', '4.1.1'
    pod 'ActiveLabel', '1.1.0'
    pod 'XLPagerTabStrip', '8.1.0'
    pod 'MXSegmentedPager', '3.3.0'
    pod 'AlignedCollectionViewFlowLayout'
    pod 'GrowingTextView'
end

target 'Education' do
    common_pods
    tracking_pods
    ui_pods
end

target 'Education-Prod' do
    common_pods
    tracking_pods
    ui_pods
end
