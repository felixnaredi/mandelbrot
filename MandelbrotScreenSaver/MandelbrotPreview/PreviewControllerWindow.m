//
//  PreviewControllerWindow.m
//  MandelbrotPreview
//
//  Created by Felix Naredi on 2020-06-18.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import simd;
#import "PreviewControllerWindow.h"
#import "PreviewView.h"

simd_float4x4 modelMatrix(const simd_float3 vector)
{
  const float x = vector.x;
  const float y = vector.y;
  const float z = vector.z;
  return simd_matrix(simd_make_float4(z, 0, 0, x),
                     simd_make_float4(0, z, 0, y),
                     simd_make_float4(0, 0, 0, 0),
                     simd_make_float4(0, 0, 0, 0));
}

enum KeyCode
{ KEYCODE_A     =  0
, KEYCODE_S     =  1
, KEYCODE_D     =  2
, KEYCODE_H     =  4
, KEYCODE_Z     =  6
, KEYCODE_X     =  7
, KEYCODE_C     =  8
, KEYCODE_W     = 13
, KEYCODE_R     = 15
, KEYCODE_PLUS  = 27
, KEYCODE_MINUS = 44
, KEYCODE_SPACE = 49 };

@implementation PreviewControllerWindow
{
  simd_float3   _d;
  simd_float3   _i;
  float         _zDirection;
  float         _zfuncIterations;
  float         _threshold;
  uint8         _keysDown[50];
  uint64_t      _keysDownMask;
}

- (void)resetState
{
  _keysDownMask = 0;
  _zfuncIterations = 10;
  _zDirection = -1.0;
  _threshold = 4.294967296e9;
  _d = simd_make_float3(-0.1, 0.0, 0.0);
  _i = simd_make_float3( 0.0, 0.0, 1.0);
}

- (MandelbrotRenderer *)getRenderer
{
  PreviewView *view = (PreviewView *)self.contentView;
  if (view == NULL) {
    return NULL;
  }
  return view.renderer;
}

- (id)init
{
  self = [super init];
  
  if (!self) {
    return NULL;
  }
  
  [self resetState];
  return self;
}

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSWindowStyleMask)style
                  backing:(NSBackingStoreType)backingStoreType
                    defer:(BOOL)flag
{
  self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
  
  if (!self) {
    return NULL;
  }
  
  [self resetState];
  return self;
}

- (BOOL)keyIsDown:(uint)keyCode
{ return (_keysDownMask & (1 << keyCode)) != 0; }

- (void)setContentView:(__kindof NSView *)contentView
{
  [super setContentView:contentView];
  
  if (contentView.class == PreviewView.class) {
    [self getRenderer].onWillRender = ^(MandelbrotRenderer * renderer)
    {
      if ([self keyIsDown:KEYCODE_PLUS])  { self->_zfuncIterations += 0.25; }
      if ([self keyIsDown:KEYCODE_MINUS]) { self->_zfuncIterations -= 0.25; }
      
      if ([self keyIsDown:KEYCODE_W]) { self->_d.y += 0.0050; }
      if ([self keyIsDown:KEYCODE_S]) { self->_d.y -= 0.0050; }
      if ([self keyIsDown:KEYCODE_A]) { self->_d.x -= 0.0050; }
      if ([self keyIsDown:KEYCODE_D]) { self->_d.x += 0.0050; }
      if ([self keyIsDown:KEYCODE_SPACE]) { self->_d.z += 0.0025 * self->_zDirection; }
      self->_d *= 0.85;
      self->_i += self->_d * self->_i.z;
      
      if ([self keyIsDown:KEYCODE_Z]) { self->_threshold *= 0.89; }
      if ([self keyIsDown:KEYCODE_X]) { self->_threshold *= 1.11; }
      
      renderer.modelMatrix = modelMatrix(self->_i);
      renderer.iterations = (uint) self->_zfuncIterations;
      renderer.threshold = self->_threshold;
    };
  }
}

- (void)keyUp:(NSEvent *)event
{ _keysDownMask &= ~(1 << event.keyCode); }

- (void)keyDown:(NSEvent *)event
{
  NSLog(@"[PreviewControllerWindow keyDown] - keyCode: %d", event.keyCode);
  
  _keysDownMask |= 1 << event.keyCode;
  
  if (event.keyCode == KEYCODE_R) {
    _zDirection *= -1;
  }
  
  if (event.keyCode == KEYCODE_H) {
    PreviewView * view = self.contentView;
    view.helpTextVisible = !view.helpTextVisible;
  }
}

@end
