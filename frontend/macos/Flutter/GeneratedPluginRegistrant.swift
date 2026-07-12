//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import device_info_plus
import local_auth_darwin
import package_info_plus
import passkeys_darwin
import ua_client_hints

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  LocalAuthPlugin.register(with: registry.registrar(forPlugin: "LocalAuthPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PasskeysPlugin.register(with: registry.registrar(forPlugin: "PasskeysPlugin"))
  UAClientHintsPlugin.register(with: registry.registrar(forPlugin: "UAClientHintsPlugin"))
}
