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
    
    func randomize(range: ClosedRange<Float> = 2...2) throws {
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
    
    func add(m2: Matrix) throws {
        try Matrix.validateAddOrSubtraction(m1: self, m2: m2)
        data = zip(data, m2.data).map { rows in zip(rows.0, rows.1).map(+) }
    }
    
    func subtract(m2: Matrix) throws {
        try Matrix.validateAddOrSubtraction(m1: self, m2: m2)
        data = zip(data, m2.data).map { rows in zip(rows.0, rows.1).map(-) }
    }
}

//Static methods
extension Matrix {
    static func add(_ m1: Matrix,_ m2: Matrix) throws -> Matrix {
        try Matrix.validateAddOrSubtraction(m1: m1, m2: m2)
        return try Matrix(data: zip(m1.data, m2.data).map { rows in zip(rows.0, rows.1).map(+) })
    }
    
    static func subtract(_ m1: Matrix,_ m2: Matrix) throws -> Matrix {
        try Matrix.validateAddOrSubtraction(m1: m1, m2: m2)
        return try Matrix(data: zip(m1.data, m2.data).map { rows in zip(rows.0, rows.1).map(-) })
    }
    
    static func sameDimension(_ m1: Matrix,_ m2: Matrix) -> Bool {
        return (m1.matrix_rows == m2.matrix_rows) && (m1.matrix_columns == m2.matrix_columns)
    }
}

private extension Matrix {
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
    
    private static func validateAddOrSubtraction(m1: Matrix, m2: Matrix) throws {
        guard (m1.matrix_rows == m2.matrix_rows) && (m1.matrix_columns == m2.matrix_columns) else { throw "Matrix dimensions doens't match" }
    }
}

// Subscripts
extension Matrix {
    subscript(row: Int, column: Int) -> Float {
        get {
            guard 1...matrix_columns ~= column else { fatalError("Columns out of bound") }
            guard 1...matrix_rows ~= row else { fatalError("Rows out of bound") }
            return data[row - 1][column - 1]
        }
        set {
            guard 1...matrix_columns ~= column else { fatalError("Columns out of bound") }
            guard 1...matrix_rows ~= row else { fatalError("Rows out of bound") }
            data[row - 1][column - 1] = newValue
        }
    }
    
    subscript(row index: Int) -> [Float] {
        guard 1...matrix_rows ~= index else { fatalError("Rows out of bound") }
        return data[index - 1]
    }
    
    subscript(column index: Int) -> [Float] {
        guard 1...matrix_columns ~= index else { fatalError("Columns out of bound") }
        return data.map { $0[index - 1] }
    }
}

// Neural network
final class NeuralNetwork {
    struct LayerLayout {
        let input: Int
        let hidden: Int
        let output: Int
    }
    
    struct TrainingData {
        let input: [Float]
        let expectedOutput: Matrix
    }
    
    private let layout: LayerLayout

    private let inputLayer: Matrix
    private let ih_weights: Matrix
    
    private var hiddenLayer: Matrix!
    private let ho_weights: Matrix
    
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
        return 1 / (1 + exp(-value))
    }
    
    func predict(inputs: [Float]) throws -> Matrix {
        guard layout.input == inputs.count else { throw "Input doesnt match layout input layer, Should be \(layout.input)" }
        try inputLayer.populate(data: [inputs])
        
        hiddenLayer = try inputLayer.multiply(m2: ih_weights)
        hiddenLayer.applyToData(f: sigmoid)
        
        outputLayer = try hiddenLayer.multiply(m2: ho_weights)
        outputLayer.applyToData(f: sigmoid)
        
        return outputLayer
    }
    
    func train(_ trainingData: [TrainingData]) throws {
        for data in trainingData {
            try validateTrainingData(data)
            let output = try predict(inputs: data.input)
            let cost = calculateCost(output: output, expectedOutput: data.expectedOutput)
            print(cost)
            
        }
    }
    
    func calculateCost(output: Matrix, expectedOutput: Matrix) -> Float {
        let difference = try! Matrix.subtract(output, expectedOutput)
        difference.applyToData { powf($0, 2) }
        return difference.data.reduce(0) { total, row in total + row.reduce(0, +) }
    }

    func printNetwork() {
        inputLayer.matrixPrint()
        ih_weights.matrixPrint()
        hiddenLayer.matrixPrint()
        ho_weights.matrixPrint()
        outputLayer.matrixPrint()
    }
    
    private func validateTrainingData(_ data: TrainingData) throws {
        guard Matrix.sameDimension(outputLayer, data.expectedOutput) else {
            throw "Invalid training data expected output dimensions \(outputLayer.matrix_rows)x\(outputLayer.matrix_columns), but got \(data.expectedOutput.matrix_rows)x\(data.expectedOutput.matrix_columns)"
        }
        guard data.input.count == layout.input else { throw "Invalid Input, neural network expects input size to be \(layout.input), but got \(data.input.count)" }
    }
}

let neuralNetwork = try NeuralNetwork(layout: NeuralNetwork.LayerLayout(input: 2, hidden: 3, output: 2))

let output = try neuralNetwork.predict(inputs: [3,4])
neuralNetwork.printNetwork()
