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
        let rowValues = Array<Float>(repeating: 0, count: column)
        self.data = Array<[Float]>(repeating: rowValues, count: row)
        populated = true
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
    
    func copy() -> Matrix {
        return try! Matrix(data: data)
    }
    
    func transposed() throws -> Matrix {
        let matrix = Matrix(row: matrix_columns, column: matrix_rows)
        for index in 1...matrix.matrix_columns {
            matrix[column: index] = self[row: index]
        }
        return matrix
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
    
    static func sameDimension(_ m1: Matrix,_ m2: Matrix) throws {
        guard (m1.matrix_rows == m2.matrix_rows) && (m1.matrix_columns == m2.matrix_columns) else {
            throw "Invalid training data expected output dimensions"
        }
    }
    
    static func multiply(_ scalar: Float, _ matrix: Matrix) -> Matrix {
        let copy = matrix.copy()
        copy.applyToData { $0 * scalar }
        return copy
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
        get {
            guard 1...matrix_columns ~= index else { fatalError("Columns out of bound") }
            return data.map { $0[index - 1] }
        }
        set {
            guard newValue.count == matrix_rows else { fatalError("Columns oversized \(newValue.count) != \(matrix_columns)") }
            for row in 1...matrix_rows {
                data[row - 1][index - 1] = newValue[row - 1]
            }
        }
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
    
    private var hiddenLayer: Matrix
    private let ho_weights: Matrix
    
    private var outputLayer: Matrix
    private var learningRate: Float = 0.5
    
    init(layout: LayerLayout) throws {
        self.layout = layout
        
        ih_weights =  Matrix(row: layout.input, column: layout.hidden)
        
        let fakeWeightIh: [[Float]] = [
            [0.5, 0.4, 0.6],
            [0.1, 0.8, 0.2]
        ]
        try ih_weights.populate(data: fakeWeightIh)
//        try ih_weights.randomize()
        
        ho_weights = Matrix(row: layout.hidden, column: layout.output)
        
        let fakeWeightHo: [[Float]] = [
            [0.7, 0.2],
            [0.1, 0.6],
            [0.9, 0.1]
        ]
        try ho_weights.populate(data: fakeWeightHo)
        
//        try ho_weights.randomize()
        
        inputLayer = Matrix(row: 1, column: layout.input)
        hiddenLayer = Matrix(row: 1, column: layout.hidden)
        outputLayer = Matrix(row: 1, column: layout.output)
    }
    
    func sigmoid(_ value: Float) -> Float {
        return 1 / (1 + exp(-value))
    }
    
    func primeSigmoid(sigmoidValue: Float) -> Float {
        return sigmoidValue * (1 - sigmoidValue)
    }
    
    func predict(inputs: [Float]) throws -> Matrix {
        guard layout.input == inputs.count else { throw "Input doesnt match layout input layer, Should be \(layout.input)" }
        try inputLayer.populate(data: [inputs])
        
        try hiddenLayer.populate(data: try inputLayer.multiply(m2: ih_weights).data)
        hiddenLayer.applyToData(f: sigmoid)
        
        try outputLayer.populate(data: try hiddenLayer.multiply(m2: ho_weights).data)
        outputLayer.applyToData(f: sigmoid)
        
        return outputLayer
    }
    
    func train(_ trainingData: [TrainingData]) throws {
        for data in trainingData {
            try validateTrainingData(data)
            let output = try predict(inputs: data.input)
            
            let outputError = calculateOutputCosts(output: output, expectedOutput: data.expectedOutput)
            print("Costs output:")
            outputError.matrixPrint()
            
            let ho_delta_weights = deltaWeights(for: ho_weights, error: outputError, layer: output, test: true)
            try ho_weights.add(m2: ho_delta_weights)
        
            // Hidden
            let hiddenErrors = backpropagateError(for: ho_weights, currentErrors: outputError)
            print("Costs Hidden layer:")
            hiddenErrors.matrixPrint()
            
            let ih_delta_weights = deltaWeights(for: ih_weights, error: hiddenErrors, layer: hiddenLayer, test: false)
            try ih_weights.add(m2: ih_delta_weights)
        }
    }
    
    func deltaWeights(for weights: Matrix, error: Matrix, layer: Matrix, test: Bool) -> Matrix {
        if test {
            let m = Matrix(row: 3, column: 2)
            try! m.randomize(range: 10...10)
            return m
        } else {
            let m = Matrix(row: 2, column: 3)
            try! m.randomize(range: 100...100)
            return m
        }
    }
    
    /// Returns the error for the previous layer based on previous weights
    func backpropagateError(for weights: Matrix, currentErrors: Matrix) -> Matrix {
        let proportion = Matrix(row: weights.matrix_rows, column: weights.matrix_columns)
        
        for index in 1...weights.matrix_columns {
            let column = weights[column: index]
            let sum = column.reduce(0, +)
            proportion[column: index] = column.map { $0 / sum }
        }
        
        return try! proportion.multiply(m2: currentErrors.transposed()).transposed()
    }
    
    func calculateOutputCosts(output: Matrix, expectedOutput: Matrix) -> Matrix {
        let errors = try! Matrix.subtract(expectedOutput, output)
        errors.applyToData { powf($0, 2) }
        return errors
    }
    
    func calculateTotalCost(output: Matrix, expectedOutput: Matrix) -> Float {
        let costs = calculateOutputCosts(output: output, expectedOutput: expectedOutput)
        return costs.data.reduce(0) { total, row in total + row.reduce(0, +) }
    }

    func printNetwork() {
        inputLayer.matrixPrint()
        ih_weights.matrixPrint()
        hiddenLayer.matrixPrint()
        ho_weights.matrixPrint()
        outputLayer.matrixPrint()
    }
    
    private func validateTrainingData(_ data: TrainingData) throws {
        try Matrix.sameDimension(outputLayer, data.expectedOutput)
        guard data.input.count == layout.input else { throw "Invalid Input, neural network expects input size to be \(layout.input), but got \(data.input.count)" }
    }
}

let neuralNetwork = try NeuralNetwork(layout: NeuralNetwork.LayerLayout(input: 2, hidden: 3, output: 2))

let expected = try Matrix(data: [[0, 1]] )
let expected2 = try Matrix(data: [[1, 0]] )
try neuralNetwork.train([.init(input: [4, 5], expectedOutput: expected), .init(input: [7, 3], expectedOutput: expected2)])

print("\n\nNeural network state:")
neuralNetwork.printNetwork()
