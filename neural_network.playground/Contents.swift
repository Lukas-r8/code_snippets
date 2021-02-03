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
        
    }
    
    func multiply(m2: Matrix) throws -> Matrix {
        try validateMultiplication(m1: self, m2: m2)
        
        
        
        return Matrix(row: 0, column: 0)
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
