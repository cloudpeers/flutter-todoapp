#import "TlfsPlugin.h"

@implementation TlfsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTlfsPlugin registerWithRegistrar:registrar];
}
@end
