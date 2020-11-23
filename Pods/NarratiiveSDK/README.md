# Narratiive IOS SDK

[![CI Status](https://img.shields.io/travis/git/NarratiiveSDK.svg?style=flat)](https://travis-ci.org/git/NarratiiveSDK)
[![Version](https://img.shields.io/cocoapods/v/NarratiiveSDK.svg?style=flat)](https://cocoapods.org/pods/NarratiiveSDK)
[![License](https://img.shields.io/cocoapods/l/NarratiiveSDK.svg?style=flat)](https://cocoapods.org/pods/NarratiiveSDK)
[![Platform](https://img.shields.io/cocoapods/p/NarratiiveSDK.svg?style=flat)](https://cocoapods.org/pods/NarratiiveSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Add NarratiiveSDK to Your iOS App

NarratiiveSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NarratiiveSDK'
```

Save the Podfile and run:

```ruby
pod install
```

This creates an .xcworkspace file for your application. Use this file for all future development on your application.


## Initialize NarratiiveSDK for your iOS App

Now that you have the configuration file for your project, you're ready to begin implementing. First, configure the shared Analytics object inside AppDelegate. This makes it possible for your app to send data to Analytics. 

To do so, import the NarratiiveSDK libruary and override the `didFinishLaunchingWithOptions` method to configure NarratiiveSDK:

**Swift Code**:
    
    // AppDelegate.swift
    
    import NarratiiveSDK
    ...
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        guard let sdk = NarratiiveSDK.sharedInstance() else {
          assert(false, "Narratiive SDK not configured correctly")
        }
        
        // Optional, show debug information in output
        // Remove before app release.
        sdk.debugMode = true
        // Optional, use of IDFA to identify user
        sdk.useIDFA = true
        sdk.setup(withHost: "YOUR_HOSTNAME", andHostKey: "YOUR_HOSTKEY")
        
        return true
    }
         
 Example: [AppDelegate.swift](./Example/NarratiiveSDK/AppDelegate.swift)
 
 
**Objective C**:
    
    // AppDelegate.m
    
    #import "NarratiiveSDK-Swift.h"
    ...
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Override point for customization after application launch.
       
        NarratiiveSDK *sdk = [NarratiiveSDK sharedInstance];
        [sdk setupWithHost:@"YOUR_HOSTNAME" andHostKey:@"YOUR_HOSTKEY"];

        // Optional, show debug information in output
        // Remove before app release.
        sdk.debugMode = YES;
     
        return YES;
    }
    
    **Note**: You will need to create a bridging header for this Swift Pod if you don't have one yet in your Objective C project.

 

## Add screen tracking

Here you’ll send a named screen view to NarratiiveSDK whenever the user opens or changes screens on your app. Open a View Controller that you'd like to track, or if this is a new application, open the default view controller. Your code should do the following:

**Swift Code**:
    
    // FirstViewController.swift    
    import NarratiiveSDK
    ...
    
    override func viewWillAppear(_ animated: Bool) {
        if let inst = NarratiiveSDK.sharedInstance() {
            inst.send(screenName: "/first-page")
        }
    }


Example: [FirstViewControler.swfit](./Example/NarratiiveSDK/FirstViewController.swift)

**Objective C**:
    
    // FirstViewController.m
    #import "NarratiiveSDK-Swift.h"
    ...
    
    - (void) viewWillAppear:(BOOL)animated {
        NarratiiveSDK *sdk = [NarratiiveSDK sharedInstance];
        [sdk sendWithScreenName:@"/first-page"];
    }


**Note**: The `screenName` is used to identify the screen view. It should follows a URL path format and be in lowercases.

## About IDFA

Announced at WDDC (Worldwide Developers Conference) 2020, iOS 14 will begin requiring users to opt in for developers to access their devices’ advertising ID, or IDFA. 

In versions before v0.2.0, the SDK collects the IDFA and use it for user identification by default.

Since v0.2.0, the SDK requires the use of IDFA be explicitly enabled by setting `useIDFA = true`. Please refer to the above example for details. The SDK will not request user authorization. App developers need to issue an app-tracking authorization request to the user if required. For more details, visit  [https://developer.apple.com/documentation/apptrackingtransparency](https://developer.apple.com/documentation/apptrackingtransparency).



## Author

git, engineering@narratiive.com

## License

NarratiiveSDK is available under the MIT license. See the LICENSE file for more info.

## Development

This SDK was created using [Pod Lib Create](https://guides.cocoapods.org/making/using-pod-lib-create) and published to [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk)

Follow the steps bellow to start development:

1. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html)
2. Open `Example/NarratiiveSDK.xcworkspace` with XCode for development;
3. Update version number in `NarratiiveSDK.podspec`;
4. `pod lib lint`
5. Commit changes and create a release tag in the Git repository. For example:

    ```
    $ git add -A && git commit -m "Release 0.0.1."
    $ git tag '0.0.1'
    $ git push --tags
    ```

6. `pod spec lint`  (use engineering@narratiive.com as user of CocoaPods Trunk)
7. `pod repo push`
