//
//  TextureRenderer.swift
//  mac-metal-rendere
//
//  Created by Lucas Alves Da Silva on 28.10.20.
//

import Cocoa
import MetalKit
import simd

struct Particle {
    var pos: SIMD2<Float>
    var vel: SIMD2<Float>
    var size: Float
};

enum MetalError: LocalizedError {
    case configurationFailed
}

final class TextureRenderer: NSObject {
    private let metalView: MTKView
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    
    private var computePipelineState: MTLComputePipelineState?
    
    private var numberOfParticles: Int = 30
    private var particlesBuffer: MTLBuffer?
    private var numberBuffer: MTLBuffer? { device?.makeBuffer(bytes: &numberOfParticles, length: MemoryLayout<Int>.stride, options: []) }
    
    init(metalView: MTKView) {
        self.metalView = metalView
        super.init()
        do {
            try configureMetal()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func start() {
        metalView.isPaused = false
    }
    
    func configureMetal() throws {
        device = MTLCreateSystemDefaultDevice()
        metalView.framebufferOnly = false
        metalView.delegate = self
        metalView.device = device
        metalView.isPaused = true
        commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        
        guard let computeFunction = library?.makeFunction(name: "computeParticles") else { throw MetalError.configurationFailed }
        computePipelineState = try device?.makeComputePipelineState(function: computeFunction)
        
        populateParticles()
    }
    
    func populateParticles() {
        let particles: [Particle] = Array(0..<numberOfParticles).map { _ in Particle(pos: .random(in: 0...Float(metalView.drawableSize.width)), vel: .random(in: 0...0.001), size: Float.random(in: 8...20)) }
        particlesBuffer = device?.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * particles.count, options: [])
    }
}

extension TextureRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard
            let drawable = metalView.currentDrawable,
            let commandBuffer = commandQueue?.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
            let computePipelineState = computePipelineState
        else { return }
        commandEncoder.setComputePipelineState(computePipelineState)
        commandEncoder.setTexture(drawable.texture, index: 0)
        commandEncoder.setBuffer(particlesBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(numberBuffer, offset: 0, index: 1)
        
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1)
        
        let threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
