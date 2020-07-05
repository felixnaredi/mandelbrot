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

void put_float4x4(const simd_float4x4 * matrix)
{
  NSLog(@"\n{ %f, %f, %f, %f }\n{ %f, %f, %f, %f }\n{ %f, %f, %f, %f }\n{ %f, %f, %f, %f }",
        matrix->columns[0][0],
        matrix->columns[1][0],
        matrix->columns[2][0],
        matrix->columns[3][0],
        
        matrix->columns[0][1],
        matrix->columns[1][1],
        matrix->columns[2][1],
        matrix->columns[3][1],
        
        matrix->columns[0][2],
        matrix->columns[1][2],
        matrix->columns[2][2],
        matrix->columns[3][2],
        
        matrix->columns[0][3],
        matrix->columns[1][3],
        matrix->columns[2][3],
        matrix->columns[3][3]);
}

enum KeyCode
{ KEYCODE_A     =  0
, KEYCODE_S     =  1
, KEYCODE_D     =  2
, KEYCODE_H     =  4
, KEYCODE_C     =  8
, KEYCODE_W     = 13
, KEYCODE_R     = 15
, KEYCODE_PLUS  = 27
, KEYCODE_MINUS = 44
, KEYCODE_SPACE = 49 };

@implementation PreviewControllerWindow
{
  simd_float4x4 _modelMatrix;
  simd_float3   _d;
  float         _zDirection;
  float         _zfuncIterations;
  uint8         _keysDown[50];
  uint64_t      _keysDownMask;
}

- (void)resetState
{
  _keysDownMask = 0;
  _zfuncIterations = 10;
  _zDirection = -1.0;
  _d = simd_make_float3(-0.1, 0.0, 0.15);
  _modelMatrix = simd_matrix(simd_make_float4(1, 0, 0, 0),
                             simd_make_float4(0, 1, 0, 0),
                             simd_make_float4(0, 0, 1, 0),
                             simd_make_float4(0, 0, 0, 1));
}

- (void)updateModelMatrix
{
  _modelMatrix = simd_mul(_modelMatrix, simd_matrix(simd_make_float4(1, 0, 0, _d.x),
                                                    simd_make_float4(0, 1, 0, _d.y),
                                                    simd_make_float4(0, 0, 1, _d.z),
                                                    simd_make_float4(0, 0, 0,    1)));
}

- (simd_float4)getModelsTranslateVector
{
  return simd_make_float4(_modelMatrix.columns[0][3],
                          _modelMatrix.columns[1][3],
                          _modelMatrix.columns[2][3],
                          _modelMatrix.columns[3][3]);
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
      if ([self keyIsDown:KEYCODE_PLUS])  { self->_zfuncIterations += 0.15; }
      if ([self keyIsDown:KEYCODE_MINUS]) { self->_zfuncIterations -= 0.15; }
      
      const simd_float4 t = [self getModelsTranslateVector];
      const float m = 1 + t.z;
      
      if ([self keyIsDown:KEYCODE_W]) { self->_d.y += 0.0050 * m; }
      if ([self keyIsDown:KEYCODE_S]) { self->_d.y -= 0.0050 * m; }
      if ([self keyIsDown:KEYCODE_A]) { self->_d.x -= 0.0050 * m; }
      if ([self keyIsDown:KEYCODE_D]) { self->_d.x += 0.0050 * m; }
      if ([self keyIsDown:KEYCODE_SPACE]) { self->_d.z += 0.0025 * m * self->_zDirection; }
      self->_d *= 0.85;
      [self updateModelMatrix];
      
      renderer.modelMatrix = self->_modelMatrix;
      renderer.iterations = (uint) self->_zfuncIterations;
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
