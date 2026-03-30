#import <Foundation/Foundation.h>
#import <QuickLookUI/QuickLookUI.h>

// Explicitly declare NSExtensionMain as it might be hidden in some Foundation headers
extern int NSExtensionMain(int argc, const char * argv[]);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // This is the standard entry point for modern macOS AppExtensions
        return NSExtensionMain(argc, argv);
    }
}
