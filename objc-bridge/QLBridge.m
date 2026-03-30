#import "QLBridge.h"
#import <Foundation/Foundation.h>
#import <QuickLookUI/QuickLookUI.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

// Forward declaration of Rust FFI functions
extern char* mdpreviewer_render(const char* markdown, bool isTruncated);
extern void mdpreviewer_free_string(char* ptr);

@implementation QLBridge

- (void)providePreviewForRequest:(QLFilePreviewRequest *)request completionHandler:(void (^)(QLPreviewReply * _Nullable reply, NSError * _Nullable error))completionHandler {
    NSURL *fileURL = request.fileURL;
    NSLog(@"MDPreviewer (Modern): Rendering file: %@", fileURL.path);
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:&error];
    
    if (!data) {
        NSLog(@"MDPreviewer (Modern): Failed to read file: %@", error.localizedDescription);
        completionHandler(nil, error);
        return;
    }
    
    size_t maxSizeBytes = 3 * 1024 * 1024; // Limit for preview
    BOOL isTruncated = data.length > maxSizeBytes;
    if (isTruncated) {
        data = [data subdataWithRange:NSMakeRange(0, maxSizeBytes)];
    }
    
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!content) {
        NSLog(@"MDPreviewer (Modern): UTF-8 decoding failed");
        completionHandler(nil, [NSError errorWithDomain:@"com.doctorcode.mdpreviewer" code:1 userInfo:@{NSLocalizedDescriptionKey: @"UTF-8 decoding failed"}]);
        return;
    }
    
    char* htmlPtr = mdpreviewer_render([content UTF8String], isTruncated);
    if (!htmlPtr) {
        NSLog(@"MDPreviewer (Modern): Rust renderer returned NULL");
        completionHandler(nil, [NSError errorWithDomain:@"com.doctorcode.mdpreviewer" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Rust renderer failed"}]);
        return;
    }
    
    NSString *htmlStr = [NSString stringWithUTF8String:htmlPtr];
    mdpreviewer_free_string(htmlPtr);
    
    QLPreviewReply *reply = [[QLPreviewReply alloc] initWithDataOfContentType:UTTypeHTML contentSize:CGSizeZero dataCreationBlock:^NSData * _Nullable(QLPreviewReply * _Nonnull reply, NSError * _Nullable __autoreleasing * _Nullable error) {
        return [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    NSLog(@"MDPreviewer (Modern): HTML Delivered. Success!");
    completionHandler(reply, nil);
}

@end
