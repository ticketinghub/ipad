platform :ios, '7.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!

pod 'iOS-api', :podspec => '.'

pod 'TapkuLibrary',     :git => 'https://github.com/bartekhugo/tapkulibrary.git',       :branch => 'ios7'
pod 'PPSSignatureView', :git => 'https://github.com/bartekhugo/PPSSignatureView.git',   :branch => 'master'
pod 'AKPickerView',     :git => 'https://github.com/bartekhugo/AKPickerView.git',       :branch => 'tickethub'
pod 'thcal',            :git => 'https://github.com/ticketinghub/ical.git',             :branch => 'tickethub'
pod 'PPiAwesomeButton', :git => 'https://github.com/pepibumur/PPiAwesomeButton.git',    :commit => '44a73c8' #explicit bug fix for PPiFlatSegmentedControl without release tag
pod 'Block-KVO',        :git => 'https://github.com/iMartinKiss/Block-KVO.git'

pod 'PPiFlatSegmentedControl',                      '~> 1.3.8'
pod 'RMPickerViewController',                       '~> 1.1.0'
pod 'SevenSwitch',                                  '~> 1.3.0'
pod 'Stripe',                                       '~> 1.1.2'
pod 'TSCurrencyTextField',                          '~> 0.1.0'
pod 'UIAlertView-Blocks',                           '~> 1.0'
pod 'UIImage+PDF',                                  '~> 1.1.2'
pod 'UIView+Shake',                                 '~> 0.2'
pod 'UIView-Autolayout',                            '~> 0.2.0'
pod 'UIViewController+BHTKeyboardAnimationBlocks',  '~> 0.0.2'

target :test, :exclusive => true do
    
   link_with 'TicketingHubTests'

   pod 'Expecta', '~> 0.2.3'
   pod 'Specta', '~> 0.2.1'
   pod 'OCMock', '~> 2.2.3'

end

