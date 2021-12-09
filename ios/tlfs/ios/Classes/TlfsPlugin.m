#import "TlfsPlugin.h"
#if __has_include(<tlfs/tlfs-Swift.h>)
#import <tlfs/tlfs-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tlfs-Swift.h"
#endif

@implementation TlfsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTlfsPlugin registerWithRegistrar:registrar];
}
@end
