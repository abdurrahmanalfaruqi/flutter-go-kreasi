import UIKit
import Flutter

enum ChannelName {
  static let secure_screen = "com.go_expert.app/secure_screen"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var field = UITextField()
  var isSecureScreen: Bool = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    // add Secure View
    addSecuredView()

    guard let controller : FlutterViewController = window?.rootViewController as? FlutterViewController else {
          fatalError("rootViewController is not type FlutterViewController")
        }

    let secureChannel = FlutterMethodChannel(name: ChannelName.secure_screen,
                                                  binaryMessenger: controller.binaryMessenger)
    secureChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          switch call.method {
          case "setSecureScreen" :
            self?.setSecureScreen(isSecure: call.arguments as! Bool, result: result)
          default :
            result(FlutterMethodNotImplemented)
          }
        })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setSecureScreen(isSecure: Bool, result: FlutterResult) {
    isSecureScreen = isSecure
    secureView(willResign: false)
    result(isSecureScreen)
  }

  // Code to hide content if screen not active
  private func secureView(willResign: Bool) {
    print("SWIFT-SECURE-VIEW: " + String(isSecureScreen))
    if (willResign) {
        field.isSecureTextEntry = false
        self.window.isHidden = isSecureScreen
    } else {
        field.isSecureTextEntry = isSecureScreen
        self.window.isHidden = false
    }
  }

  override func applicationWillResignActive(
    _ application: UIApplication
  ) {
       print("SWIFT-SECURE-VIEW-WillResign: " + String(isSecureScreen))
       secureView(willResign: true)
  }

  // Code to show content if screen active
  override func applicationDidBecomeActive(
    _ application: UIApplication
  ) {
       print("SWIFT-SECURE-VIEW-DidBecome: " + String(isSecureScreen))
       secureView(willResign: false)
  }

  // Securing View Function
  private func addSecuredView() {
     if (!window.subviews.contains(field)) {
       window.addSubview(field)
       field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
       field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
       window.layer.superlayer?.addSublayer(field.layer)
       field.layer.sublayers?.first?.addSublayer(window.layer)
     }
  }

  private func appUpdateAvailable() -> (Bool,String?) {
    
    guard let info = Bundle.main.infoDictionary,
          let identifier = info["CFBundleIdentifier"] as? String else {
        return (false,nil)
    }
    
    //        let storeInfoURL: String = "http://itunes.apple.com/lookupbundleId=\(identifier)&country=IN"
    let storeInfoURL:String = "https://itunes.apple.com/IN/lookup?bundleId=\(identifier)"
    var upgradeAvailable = false
    var versionAvailable = ""
    
    // Get the main bundle of the app so that we can determine the app's version number
    let bundle = Bundle.main
    if let infoDictionary = bundle.infoDictionary {
        // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
        let urlOnAppStore = NSURL(string: storeInfoURL)
        if let dataInJSON = NSData(contentsOf: urlOnAppStore! as URL) {
            // Try to deserialize the JSON that we got
            if let dict: NSDictionary = try?
                JSONSerialization.jsonObject(with: dataInJSON as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject] as NSDictionary? {
                if let results:NSArray = dict["results"] as? NSArray {
                    let versionDict = NSMutableDictionary(dictionary: results[0] as! [String:Any])
                    
                    if let version = versionDict.object(forKey: "version") as? String {
                        
                        // Get the version number of the current version installed on device
                        if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                            // Check if they are the same. If not, an upgrade is available.
                            print("\(version)")
                            print("\(currentVersion)")

                            if version != currentVersion {
                                upgradeAvailable = true
                                versionAvailable = version
                            }
                        }
                    }
                }
            }
        }
    }
    return (upgradeAvailable,versionAvailable)
  }

  private func checkAppVersion(controller: UIViewController) -> Bool {
    
    let appVersion = appUpdateAvailable()
    
    return appVersion.0
  }
}