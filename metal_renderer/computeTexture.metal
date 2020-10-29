//
//  computeTexture.metal
//  mac-metal-rendere
//
//  Created by Lucas Alves Da Silva on 28.10.20.
//

#include <metal_stdlib>
using namespace metal;

struct Particle {
    float2 pos;
    float2 vel;
    float size;
};

kernel void computeParticles(
                             texture2d<float, access::write> texture [[ texture(0) ]],
                             device Particle *particles [[ buffer(0) ]],
                             const device int *numberOfParticles [[ buffer(1) ]],
                             uint2 pid [[ thread_position_in_grid ]]
                             ) {
    simd_float2 currentComputePosition = simd_float2(pid.x, pid.y);
    
    float width = texture.get_width();
    float height = texture.get_height();
    
    
    float r = 0;
    float g = 0;
    float b = 0;
    float a = 1;

    
    
    for (int i = 0; i < *numberOfParticles; i++) {
        float factor =  particles[i].size / distance(currentComputePosition, particles[i].pos);
        
        particles[i].pos += particles[i].vel;
        Particle pt = particles[i];
        
        if (pt.pos.x < 0 || pt.pos.x > width) { particles[i].vel.x *= -1; };
        if (pt.pos.y < 0 || pt.pos.y > height) { particles[i].vel.y *= -1; };
        
        r += factor;
        g += factor * 0.5;
        b += factor * 0.5;
    }
        
    
    float4 color = float4(r,g,b,a);
    
    texture.write(color, pid);
}
