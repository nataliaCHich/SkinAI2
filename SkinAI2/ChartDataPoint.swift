import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let confidence: Double // Y-axis value (0.0 to 1.0)
    let classificationLabel: String // Annotation for the point
}