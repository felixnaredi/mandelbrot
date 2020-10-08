//
//  complex.metal
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-07-06.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#ifndef complex_metal
#define complex_metal

#include <metal_stdlib>
#include "complex.h"
using namespace metal;

namespace mandelbrot
{

complex_t::complex_t(float re, float im)
: re(re)
, im(im)
{};

complex_t::complex_t(float2 u)
: complex_t(u.x, u.y)
{ }
  
complex_t operator+(const complex_t a, const complex_t b)
{ return { a.re + b.re, a.im + b.im }; }
  
complex_t operator*(const complex_t a, const complex_t b)
{ return { a.re * b.re - a.im * b.im, a.re * b.im + b.re * a.im }; }
  
float abs(const complex_t x)
{ return sqrt(x.re * x.re + x.im * x.im); }
  
} // namespace mandelbrot

#endif /* complex_metal */
