//
//  complex.h
//  MetalMandelbrot
//
//  Created by Felix Naredi on 2020-07-06.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#ifndef complex_h
#define complex_h

#include <metal_stdlib>
using namespace metal;

namespace mandelbrot
{

template <class F>
struct complex_t
{
  F re;
  F im;
  
  complex_t(const F re, const F im)
  : re(re)
  , im(im)
  {}
  
  complex_t(const float2 a)
  : complex_t(a.x, a.y)
  {}
};

template <class F>
complex_t<F> operator+(const complex_t<F> a, const complex_t<F> b)
{ return { a.re + b.re, a.im + b.im }; }

template <class F>
complex_t<F> operator*(const complex_t<F> a, const complex_t<F> b)
{ return { a.re * b.re - a.im * b.im, a.re * b.im + b.re * a.im }; }

template <class F>
F abs(const complex_t<F> x)
{ return sqrt(x.re * x.re + x.im * x.im); }

} // namespace mandelbrot

#endif /* complex_h */
