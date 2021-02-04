import UIKit
import simd

var str = "Hello, playground"

extension String: Error { }

final class Matrix {
    let matrix_rows: Int
    let matrix_columns: Int
    var data: [[Float]] = []
    private var populated: Bool = false
    
    init(row: Int, column: Int) {
        self.matrix_rows = row
        self.matrix_columns = column
    }
    
    init(data: [[Float]]) throws {
        self.matrix_rows = data.count
        self.matrix_columns = data.first?.count ?? 0
        try populate(data: data)
    }
    
    func populate(data: [[Float]]) throws {
        try validate(data: data)
        self.data = data
        populated = true
    }
    
    func randomize(range: ClosedRange<Float> = 0...1) throws {
        let randomized = (0..<matrix_rows).map { _ in (0..<matrix_columns).map { _ in Float.random(in: range) } }
        try populate(data: randomized)
    }
    
    func applyToData(f: (Float) -> Float) {
        data = data.map { row in row.map(f) }
    }
    
    func matrixPrint() {
        print("Matrix \(matrix_rows)x\(matrix_columns)\n")
        data.forEach { print($0) }
        print("\n====================================\n")
    }
    
    func multiply(m2: Matrix) throws -> Matrix {
        let m1 = self
        try validateMultiplication(m1: self, m2: m2)
        let resultMatrix = Matrix(row: m1.matrix_rows, column: m2.matrix_columns)
        var resultData: [[Float]] = []
        
        for stepRow in 0 ..< m1.matrix_rows {
            var row: [Float] = []
            for stepColumn in 0 ..< m2.matrix_columns {
                let m2_column_data = m2.data.map { $0[stepColumn] }
                let mult_sum = zip(m1.data[stepRow], m2_column_data).map { $0.0 * $0.1 }.reduce(0, +)
                row.append(mult_sum)
            }
            resultData.append(row)
        }
        
        try resultMatrix.populate(data: resultData)
        
        return resultMatrix
    }
    
    private func validate(data: [[Float]]) throws {
        guard data.count == matrix_rows else { throw "This matrix should contain \(matrix_rows) rows, but got \(data.count)" }
        var columns_count: Int?
        for row in data {
            if columns_count == nil {
                columns_count = row.count
                continue
            } else if row.count != columns_count, row.count != matrix_columns {
                throw "Mismatched columns or columns don't match specified \(matrix_columns) columns, got \(row.count)"
            }
        }
    }
    
    private func validateMultiplication(m1: Matrix, m2: Matrix) throws {
        guard m1.populated && m2.populated else { throw "Matrices must be both populated!" }
        guard m1.matrix_columns == m2.matrix_rows else { throw "\(m1.matrix_rows)x\(m1.matrix_columns) matrix \(m2.matrix_rows)x\(m2.matrix_columns) matrix, columns of the first must match rows of the second matrix" }
    }
}

final class NeuralNetwork {
    struct LayerLayout {
        let input: Int
        let hidden: Int
        let output: Int
    }
    
    private let layout: LayerLayout
    
    private let ih_weights: Matrix
    private let ho_weights: Matrix
    
    private let inputLayer: Matrix
    private var hiddenLayer: Matrix!
    private var outputLayer: Matrix!
    
    init(layout: LayerLayout) throws {
        self.layout = layout
        
        ih_weights =  Matrix(row: layout.input, column: layout.hidden)
        try ih_weights.randomize()
        
        ho_weights = Matrix(row: layout.hidden, column: layout.output)
        try ho_weights.randomize()
        
        inputLayer = Matrix(row: 1, column: layout.input)
    }
    
    func sigmoid(_ value: Float) -> Float {
        return 1 / (1 + powf(Float(M_E), -value))
    }
    
    func feedFoward(inputs: [Float]) throws -> Matrix {
        guard layout.input == inputs.count else { throw "Input doesnt match layout input layer, Should be \(layout.input)" }
        try inputLayer.populate(data: [inputs])
        
        hiddenLayer = try inputLayer.multiply(m2: ih_weights)
        hiddenLayer.applyToData(f: sigmoid)
        
        outputLayer = try hiddenLayer.multiply(m2: ho_weights)
        outputLayer.applyToData(f: sigmoid)
        
        return outputLayer
    }
    
    func printNetwork() {
        inputLayer.matrixPrint()
        hiddenLayer.matrixPrint()
        outputLayer.matrixPrint()
    }
}

let neuralNetwork = try! NeuralNetwork(layout: NeuralNetwork.LayerLayout(input: 2, hidden: 3, output: 1))

let output = try! neuralNetwork.feedFoward(inputs: [-10,-10])
neuralNetwork.printNetwork()
