//
//  complex.h
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-07-06.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#ifndef complex_h
#define complex_h

namespace mandelbrot
{

struct complex_t
{
  float re;
  float im;
  
  complex_t(const float re, const float im);
  complex_t(const float2 u);
};

complex_t operator+(const complex_t a, const complex_t b);
complex_t operator*(const complex_t a, const complex_t b);
float abs(const complex_t x);

} // namespace mandelbrot

#endif /* complex_h */
