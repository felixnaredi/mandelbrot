//
//  MandelbrotScreenSaverView.m
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-06-17.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#import "../MandelbrotRenderer.h"
#import "MandelbrotScreenSaverView.h"

@implementation MandelbrotScreenSaverView
{
  MandelbrotRenderer *_renderer;
  id<MTLDevice> _device;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if (!self) {
    return NULL;
  }
  
  _device = MTLCreateSystemDefaultDevice();
  _renderer = [[MandelbrotRenderer alloc]
               initWithDevice:_device
               library:[_device newDefaultLibraryWithBundle:
                        [NSBundle bundleWithIdentifier:@"edu.felixnaredi.MandelbrotScreenSaver"]
                                                      error:NULL]];
  
  self.layerContentsRedrawPolicy =
    NSViewLayerContentsRedrawOnSetNeedsDisplay |
    NSViewLayerContentsRedrawDuringViewResize;
  
  [self setAnimationTimeInterval:1.0/30.0];
  
  return self;
}

- (CALayer *)makeBackingLayer
{
  CAMetalLayer *layer = [CAMetalLayer layer];
  layer.delegate = self;
  layer.needsDisplayOnBoundsChange = YES;
  layer.device = _device;
  return layer;
}

- (BOOL)wantsUpdateLayer
{ return YES; }

- (void)setNeedsDisplay:(BOOL)needsDisplay
{
  [super setNeedsDisplay:needsDisplay];
  [self.layer setNeedsDisplay];
}

- (void)displayLayer:(CALayer *)layer
{ [_renderer drawInLayer:(CAMetalLayer *)layer]; }

- (void)setFrameSize:(NSSize)newSize
{
  [super setFrameSize:newSize];
  self.layer = [self makeBackingLayer];
  _renderer.width = newSize.width;
  _renderer.height = newSize.height;
}

- (void)animateOneFrame
{ self.needsDisplay = YES; }

- (BOOL)hasConfigureSheet
{ return NO; }

- (NSWindow*)configureSheet
{ return nil; }

@end
