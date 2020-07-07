//
//  Shaders.metal
//  MandelbrotScreenSaver
//
//  Created by Felix Naredi on 2020-06-17.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//


#include <metal_stdlib>
#include "complex.h"
using namespace metal;

namespace mandelbrot
{

float NormalDistribution(const float avrage, const float variance, const float x)
{ return (1.0 / sqrt(2 * M_PI_F)) * pow(M_E_F, -0.5 * (pow((x - avrage) / variance, 2.0))); }

float AvrageZNorm(const uint iterations, const complex_t c)
{
  complex_t z = { 0.0, 0.0 };
  float sum = 0.0;
  
  for (uint i = 0; i < iterations; ++i) {
    z = z * z + c;
    
    constexpr float avrage = 100000.0;
    constexpr float variance = 2550.0;
    sum += NormalDistribution(avrage, variance, min(avrage, abs(z)));
  }
  
  return sum / float(iterations);
}

float ZModSum(const uint tone, const uint iterations, const complex_t c)
{
  complex_t z = { 0.0, 0.0 };
  uint sum = 0;
  
  for (uint i = 0; i < iterations; ++i) {
    z = z * z + c;
    sum += uint(abs(z));
    sum %= tone;
  }
  
  return sum;
}

struct vertex_output_t
{
  float4 _position [[position]];
  float4 position;
  
  vertex_output_t(float4 position)
  : _position(position)
  , position(position)
  { }
  
  static vertex_output_t get(uint index)
  {
    switch (index) {
      case 0: return { {  1.0,  1.0, 1.0, 1.0 } };
      case 1: return { { -1.0,  1.0, 1.0, 1.0 } };
      case 2: return { {  1.0, -1.0, 1.0, 1.0 } };
      case 3: return { { -1.0, -1.0, 1.0, 1.0 } };
    }
    return { float4() };
  }
};


vertex vertex_output_t VertexShader(          uint       index        [[vertex_id]]
                                   , constant float4x4 & model_matrix [[buffer(0)]]
                                   )
{ return vertex_output_t::get(index); }


fragment float4 FragmentShader(          vertex_output_t   in              [[stage_in]]
                              , constant uint            & iterations      [[buffer(0)]]
                              , constant float4x4        & model_matrix    [[buffer(1)]]
                              , constant float2          & viewport        [[buffer(2)]]
                              , constant simd_int3       & tone_modulation [[buffer(3)]]
                              )
{
  const uint tone = 2147483648;
  
  float4 c(float4(0, 0, 1, 1) * model_matrix);
  
  float4 p(in.position * model_matrix - c);
  p *= c.z * float4(viewport, 1.0, 1.0);
  p += c;
  
  uint d = ZModSum(tone, iterations, complex_t(p.xy));
  return { float(d % (tone / tone_modulation.x)) / float(tone / tone_modulation.x)
         , float(d % (tone / tone_modulation.y)) / float(tone / tone_modulation.y)
         , float(d % (tone / tone_modulation.z)) / float(tone / tone_modulation.z)
         , 1.00 };
}
  
} // namespace mandelbrot

