import Flutter
import PhotosUI
import UIKit

@main
@objc
class AppDelegate: FlutterAppDelegate, PHPickerViewControllerDelegate,
  UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

  private var pendingResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ 기존 플러그인 등록 유지
    GeneratedPluginRegistrant.register(with: self)

    // ✅ MethodChannel 등록
    if let controller = self.window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "native_image_picker",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else { return }

        if self.pendingResult != nil {
          result(FlutterError(code: "busy", message: "Picker already open", details: nil))
          return
        }

        switch call.method {
        case "pickFromGallery":
          self.pendingResult = result
          self.openGallery(from: controller)

        case "pickFromCamera":
          self.pendingResult = result
          self.openCamera(from: controller)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func openGallery(from controller: UIViewController) {
    if #available(iOS 14, *) {
      var config = PHPickerConfiguration()
      config.selectionLimit = 1
      config.filter = .images
      let picker = PHPickerViewController(configuration: config)
      picker.delegate = self
      controller.present(picker, animated: true)
    } else {
      let picker = UIImagePickerController()
      picker.sourceType = .photoLibrary
      picker.delegate = self
      controller.present(picker, animated: true)
    }
  }

  private func openCamera(from controller: UIViewController) {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      // 시뮬레이터면 false일 수 있음
      pendingResult?(nil)
      pendingResult = nil
      return
    }

    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.delegate = self
    controller.present(picker, animated: true)
  }

  // MARK: - PHPicker (iOS14+)
  @available(iOS 14, *)
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)

    guard let provider = results.first?.itemProvider,
      provider.canLoadObject(ofClass: UIImage.self)
    else {
      pendingResult?(nil)
      pendingResult = nil
      return
    }

    provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
      guard let self = self else { return }
      if let img = object as? UIImage {
        let path = self.saveToTemp(image: img)
        self.pendingResult?(path)
      } else {
        self.pendingResult?(nil)
      }
      self.pendingResult = nil
    }
  }

  // MARK: - UIImagePicker (camera / iOS13 gallery)
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
    pendingResult?(nil)
    pendingResult = nil
  }

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    picker.dismiss(animated: true)

    let img = (info[.editedImage] ?? info[.originalImage]) as? UIImage
    if let img = img {
      let path = saveToTemp(image: img)
      pendingResult?(path)
    } else {
      pendingResult?(nil)
    }
    pendingResult = nil
  }

  private func saveToTemp(image: UIImage) -> String? {
    guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
    let filename = "picked_\(Int(Date().timeIntervalSince1970)).jpg"
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    do {
      try data.write(to: url)
      return url.path
    } catch {
      return nil
    }
  }
}
