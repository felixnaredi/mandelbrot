//
//  PreviewView.m
//  MandelbrotCocoaApp
//
//  Created by Felix Naredi on 2020-06-17.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import Cocoa;
@import Metal;
#import <QuartzCore/CAMetalLayer.h>
#import "../MandelbrotRenderer.h"
#import "PreviewView.h"
#import "HelpTextView.h"



@implementation PreviewView
{
  id<MTLDevice> _device;
  MandelbrotRenderer * _renderer;
}

- (MandelbrotRenderer *)getRenderer
{ return _renderer; }

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (!self) { return NULL; }
  
  _device = MTLCreateSystemDefaultDevice();
  _renderer = [[MandelbrotRenderer alloc] initWithDevice:_device library:[_device newDefaultLibrary]];
  
  self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay
                                 | NSViewLayerContentsRedrawDuringViewResize;
  
  return self;
}

- (CALayer *)makeBackingLayer
{
  CAMetalLayer *layer = [CAMetalLayer layer];
  layer.delegate = self;
  layer.needsDisplayOnBoundsChange = true;
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

- (BOOL)acceptsFirstResponder
{ return true; }

@end
