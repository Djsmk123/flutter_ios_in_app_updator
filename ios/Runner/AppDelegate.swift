import Flutter
import UIKit
import StoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.smkwinner.app_updator_example/store"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register the Flutter plugin
    GeneratedPluginRegistrant.register(with: self)
    
    // Get the root view controller
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    // Create a method channel for communication between Flutter and native code
    let storeChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    
    // Set the method call handler for the method channel
    storeChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      // Check if the method called is "openStore"
      guard call.method == "openStore" else {
        result(FlutterMethodNotImplemented)
        return
      }
      // Extract the appID from the arguments
      if let args = call.arguments as? [String: Any], let appID = args["appID"] as? String {
        self?.openStoreViewController(appID: appID, result: result)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "App ID is required", details: nil))
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func openStoreViewController(appID: String, result: @escaping FlutterResult) {
    var rootViewController: UIViewController?
    
    // Check if the iOS version is 13.0 or later
    if #available(iOS 13.0, *) {
      // Get the window scene and the root view controller
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
        result(FlutterError(code: "NO_WINDOW", message: "No window available", details: nil))
        return
      }
      rootViewController = window.rootViewController
    } else {
      // Fallback on earlier versions
      guard let window = UIApplication.shared.windows.first else {
        result(FlutterError(code: "NO_WINDOW", message: "No window available", details: nil))
        return
      }
      rootViewController = window.rootViewController
    }
    
    // Check if the root view controller is available
    guard let rootVC = rootViewController else {
      result(FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "No root view controller available", details: nil))
      return
    }
    
    // Create and configure the store view controller
    let storeViewController = SKStoreProductViewController()
    let parameters = [SKStoreProductParameterITunesItemIdentifier: appID]
    
    // Load the product with the given parameters
    storeViewController.loadProduct(withParameters: parameters) { (loaded, error) in
      if !loaded {
        if let error = error {
          print("Error loading product: \(error.localizedDescription)")
          result(FlutterError(code: "LOAD_ERROR", message: error.localizedDescription, details: nil))
          return
        } else {
          print("Unknown error occurred while loading product.")
          result(FlutterError(code: "UNKNOWN_ERROR", message: "Unknown error occurred while loading product.", details: nil))
          return
        }
      }
    }
    
    // Present the store view controller
    rootVC.present(storeViewController, animated: true, completion: nil)
    
    // Return success
    result(nil)
  }
}
