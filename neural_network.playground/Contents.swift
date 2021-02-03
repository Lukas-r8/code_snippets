import UIKit
import simd

var str = "Hello, playground"

extension String: Error { }

final class NeuralNetwork {
    struct LayerLayout {
        let input: Int
        let hidden: Int
        let output: Int
    }
    
    private let layout: LayerLayout
    
    
    init(layout: LayerLayout) {
        self.layout = layout
    }
    
    func feedFoward(inputs: [Float]) throws {
        guard layout.input == inputs.count else { throw "Input doesnt match layout input layer, Should be \(layout.input)" }
        
    }
}

final class Matrix {
    let matrix_rows: Int
    let matrix_columns: Int
    var data: [[Float]] = []
    private var populated: Bool = false
    
    init(row: Int, column: Int) {
        self.matrix_rows = row
        self.matrix_columns = column
    }
    
    func populate(data: [[Float]]) throws {
        try validate(data: data)
        self.data = data
        populated = true
    }
    
    func randomize() {
        // TODO: add random values to this matrix with range
    }
    
    func matrixPrint() {
        print("Matrix \(matrix_rows)x\(matrix_columns)\n")
        data.forEach { print($0) }
        print("\n ====================================\n")
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


let m1Data: [[Float]] = [
    [1, 2, 3],
    [7, 3, 2]
]
let m1 = Matrix(row: 2, column: 3)
try! m1.populate(data: m1Data)

let m2Data: [[Float]] = [
    [2, 4, 1, 1],
    [2, 1, 1, 1],
    [8, 0, 1, 1]
]
let m2 = Matrix(row: 3, column: 4)
try! m2.populate(data: m2Data)

m1.matrixPrint()
m2.matrixPrint()

let resultMatrix = try! m1.multiply(m2: m2)
resultMatrix.matrixPrint()
