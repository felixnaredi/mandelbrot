//
//  PreviewView.h
//  MandelbrotCocoaApp
//
//  Created by Felix Naredi on 2020-06-17.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CALayer.h>
#import "../MandelbrotRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreviewView : NSView <CALayerDelegate>

@property (readonly) MandelbrotRenderer * renderer;

@end

NS_ASSUME_NONNULL_END
