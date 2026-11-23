// Native macOS replacement for the grim + slurp + imagemagick pipeline used by
// vicinae-color-picker: shows the system loupe and prints the picked colour as
// "r,g,b" (sRGB, 0-255). Exits 1 when the user cancels.
#import <AppKit/AppKit.h>

int main(void) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    NSColorSampler *sampler = [[NSColorSampler alloc] init];
    [sampler showSamplerWithSelectionHandler:^(NSColor *color) {
      if (color == nil) exit(1);

      NSColor *srgb = [color colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
      printf("%d,%d,%d\n", (int)lround(srgb.redComponent * 255),
             (int)lround(srgb.greenComponent * 255),
             (int)lround(srgb.blueComponent * 255));
      exit(0);
    }];

    [NSApp run];
  }
  return 1;
}
