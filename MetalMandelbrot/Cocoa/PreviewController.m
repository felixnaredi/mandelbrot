//
//  PreviewController.m
//  MandelbrotPreview
//
//  Created by Felix Naredi on 2020-06-18.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

@import simd;
#import "PreviewController.h"
#import "PreviewView.h"
#import "HelpTextView.h"

simd_float4x4 modelMatrix(const simd_float3 vector)
{
  const float x = vector.x;
  const float y = vector.y;
  const float z = vector.z;
  return simd_matrix(simd_make_float4(z, 0, 0, x),
                     simd_make_float4(0, z, 0, y),
                     simd_make_float4(0, 0, 1, 0),
                     simd_make_float4(0, 0, 0, 1));
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


@implementation PreviewController
{
  simd_float3   _d;
  simd_float3   _i;
  float         _zDirection;
  float         _zfuncIterations;
  float         _threshold;
  uint64_t      _keysDownMask;
  uint32_t      _helpTextMode;
}

- (void)resetState
{
  _keysDownMask = 0;
  _zfuncIterations = 10;
  _zDirection = -1.0;
  _threshold = 5.0;
  _d = simd_make_float3(-0.1, 0.0, 0.0);
  _i = simd_make_float3( 0.0, 0.0, 1.7);
  _helpTextMode = 1;
}

- (void)updateHelpTextView
{
  switch (_helpTextMode) {
    case 0:
      self.helpTextView.hidden = true;
      break;
    case 1:
      self.helpTextView.hidden = false;
      [self.helpTextView setText:@[ @"    h : toggle help text"
                                  , @"    w : move up"
                                  , @"    a : move left"
                                  , @"    s : move down"
                                  , @"    d : move right"
                                  , @"space : zoom"
                                  , @"    r : toggle zoom in/out"
                                  , @"    + : increase iterations"
                                  , @"    - : decrease iterations"
                                  , @"    z : increase threshold"
                                  , @"    x : decrease threshold" ]];
      break;
    case 2:
      self.helpTextView.hidden = false;
      [self.helpTextView setText:@[ [NSString stringWithFormat:@"         x : %f", _i.x]
                                  , [NSString stringWithFormat:@"         y : %f", _i.y]
                                  , [NSString stringWithFormat:@"         z : %f", _i.z]
                                  , [NSString stringWithFormat:@"iterations : %d", (int)_zfuncIterations]
                                  , [NSString stringWithFormat:@" threshold : %f", _threshold] ]];
      break;
      
    default:
      break;
  }
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (!self) { return NULL; }
  
  [self resetState];
  return self;
}

- (BOOL)keyIsDown:(uint)keyCode
{ return (_keysDownMask & (1 << keyCode)) != 0; }

- (void)viewDidLoad
{
  PreviewView * view = (PreviewView *) self.view;
  
  view.renderer.onWillRender = ^(MandelbrotRenderer * renderer)
  {
    if ([self keyIsDown:KEYCODE_PLUS])  { self->_zfuncIterations += 0.45; }
    if ([self keyIsDown:KEYCODE_MINUS]) { self->_zfuncIterations -= 0.45; }
    
    if ([self keyIsDown:KEYCODE_W]) { self->_d.y += 0.0050; }
    if ([self keyIsDown:KEYCODE_S]) { self->_d.y -= 0.0050; }
    if ([self keyIsDown:KEYCODE_A]) { self->_d.x -= 0.0050; }
    if ([self keyIsDown:KEYCODE_D]) { self->_d.x += 0.0050; }
    if ([self keyIsDown:KEYCODE_SPACE]) { self->_d.z += 0.0025 * self->_zDirection; }
    self->_d *= 0.85;
    self->_i += self->_d * self->_i.z;
    
    if ([self keyIsDown:KEYCODE_Z]) { self->_threshold *= 0.89; }
    if ([self keyIsDown:KEYCODE_X]) { self->_threshold *= 1.11; }
    
    [self updateHelpTextView];
    
    renderer.modelMatrix = modelMatrix(self->_i);
    renderer.iterations = (uint) self->_zfuncIterations;
    renderer.threshold = self->_threshold;
  };
}

- (void)keyUp:(NSEvent *)event
{ _keysDownMask &= ~(1 << event.keyCode); }

- (void)keyDown:(NSEvent *)event
{
  NSLog(@"[PreviewController keyDown] - keyCode: %d", event.keyCode);
  
  // TODO:
  //  For some reason controlls are not unique to a single button. It is possible to zoom with 't' and
  //  decrease iterations with 'q'.
  _keysDownMask |= (1 << event.keyCode);
  
  if (event.keyCode == KEYCODE_R) { _zDirection *= -1; }
  if (event.keyCode == KEYCODE_H) { _helpTextMode = (_helpTextMode + 1) % 3; }
}

@end
