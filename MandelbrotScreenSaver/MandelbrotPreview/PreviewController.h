//
//  PreviewController.h
//  MandelbrotPreview
//
//  Created by Felix Naredi on 2020-06-18.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import Cocoa;

#import "PreviewView.h"
#import "HelpTextView.h"


NS_ASSUME_NONNULL_BEGIN

@interface PreviewController : NSViewController

@property (weak) IBOutlet HelpTextView * helpTextView;

@end

NS_ASSUME_NONNULL_END
