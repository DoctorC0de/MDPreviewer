use objc2::rc::Retained;
use objc2::{msg_send, ClassType};
use objc2_app_kit::{NSApplication, NSApplicationActivationPolicy, NSWindow, NSWindowStyleMask, NSBackingStoreType, NSTextField};
use objc2_foundation::{MainThreadMarker, NSPoint, NSRect, NSSize, NSString};

fn main() {
    let mtm = unsafe { MainThreadMarker::new_unchecked() };
    
    let app = unsafe { NSApplication::sharedApplication(mtm) };
    let _: bool = unsafe { msg_send![&app, setActivationPolicy: NSApplicationActivationPolicy::Regular] };

    let rect = NSRect::new(NSPoint::new(100.0, 100.0), NSSize::new(400.0, 160.0));
    let window: Retained<NSWindow> = unsafe {
        let cls = NSWindow::class();
        let obj: *mut NSWindow = msg_send![cls, alloc];
        let window: *mut NSWindow = msg_send![
            obj,
            initWithContentRect: rect,
            styleMask: NSWindowStyleMask::Titled | NSWindowStyleMask::Closable,
            backing: NSBackingStoreType::NSBackingStoreBuffered,
            defer: false,
        ];
        Retained::from_raw(window).expect("Failed to initialize NSWindow")
    };

    unsafe {
        let title = NSString::from_str("MDPreviewer");
        let _: () = msg_send![&window, setTitle: &*title];
        
        let message = "MDPreviewer: QuickLook 已激活 ✅\n\n请在 Finder 中对 .md 文件按空格预览";
        let text = NSString::from_str(message);
        let label: Retained<NSTextField> = {
            let cls = NSTextField::class();
            // Using msg_send in a way that returns a raw pointer, then wrapping it.
            // +labelWithString: returns an autoreleased object.
            let obj: *mut NSTextField = msg_send![cls, labelWithString: &*text];
            Retained::from_raw(obj).expect("Failed to create label")
        };
        
        let label_rect = NSRect::new(NSPoint::new(10.0, 40.0), NSSize::new(380.0, 80.0));
        let _: () = msg_send![&label, setFrame: label_rect];
        let _: () = msg_send![&label, setAlignment: 1]; // Center alignment
        
        let content_view: *mut objc2::runtime::AnyObject = msg_send![&window, contentView];
        let _: () = msg_send![content_view, addSubview: &*label];

        let _: () = msg_send![&window, makeKeyAndOrderFront: None::<&NSWindow>];
    }

    unsafe {
        let _: () = msg_send![&app, run];
    }
}
