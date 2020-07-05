//
//  PreviewView.m
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-06-17.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import Cocoa;
@import Metal;
#import <QuartzCore/CAMetalLayer.h>
#import "../MandelbrotRenderer.h"
#import "PreviewView.h"


static NSTextField * text(NSString * str)
{
  NSTextField * res = [NSTextField textFieldWithString:str];
  res.textColor = [NSColor colorWithWhite:1.0 alpha:1.0];
  res.font = [NSFont fontWithName:@"Menlo" size:24];
  res.editable = false;
  res.selectable = false;
  return res;
}


@implementation PreviewView
{
  id<MTLDevice>        _device;
  MandelbrotRenderer * _renderer;
  NSStackView        * _helpTextView;
  BOOL                 _helpTextVisible;
}

- (MandelbrotRenderer *)getRenderer
{ return _renderer; }

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  
  if (!self) {
    return NULL;
  }
  
  _device = MTLCreateSystemDefaultDevice();
  _renderer = [[MandelbrotRenderer alloc] initWithDevice:_device library:[_device newDefaultLibrary]];
  
  self.layerContentsRedrawPolicy =
    NSViewLayerContentsRedrawOnSetNeedsDisplay |
    NSViewLayerContentsRedrawDuringViewResize;
  
  _helpTextVisible = true;
  
  _helpTextView = [[NSStackView alloc] initWithFrame:self.frame];
  _helpTextView.alignment = NSLayoutAttributeTop;
  _helpTextView.orientation = NSUserInterfaceLayoutOrientationVertical;
  _helpTextView.spacing = 2.0;
  
  [_helpTextView addArrangedSubview:text(@"    h : show/hide help text")];
  [_helpTextView addArrangedSubview:text(@"    w : move up")];
  [_helpTextView addArrangedSubview:text(@"    a : move left")];
  [_helpTextView addArrangedSubview:text(@"    s : move down")];
  [_helpTextView addArrangedSubview:text(@"    d : move right")];
  [_helpTextView addArrangedSubview:text(@"space : zoom")];
  [_helpTextView addArrangedSubview:text(@"    r : toogle zoom in/out")];
  [_helpTextView addArrangedSubview:text(@"    + : increase iterations")];
  [_helpTextView addArrangedSubview:text(@"    - : decrease iterations")];
  [self addSubview:_helpTextView];
  
  return self;
}

- (BOOL)getHelpTextVisible
{ return _helpTextVisible; }

- (void)setHelpTextVisible:(BOOL)helpTextVisible
{
  if (_helpTextVisible == helpTextVisible) {
    return;
  }
  
  if (helpTextVisible) {
    [self addSubview:_helpTextView];
  } else {
    [_helpTextView removeFromSuperview];
  }
  
  _helpTextVisible = helpTextVisible;
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

@end
