//
//  HelpTextView.h
//  MandelbrotPreview
//
//  Created by Felix Naredi on 2020-07-12.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import simd;
@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

@interface HelpTextView : NSView

- (void)setText:(NSArray<NSString *> *)lines;

@end

NS_ASSUME_NONNULL_END
