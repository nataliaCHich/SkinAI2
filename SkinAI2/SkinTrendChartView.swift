import SwiftUI
import Charts // Import Swift Charts

@available(iOS 16.0, macOS 13.0, *) // Ensure Swift Charts is available
struct SkinTrendChartView: View {
    @EnvironmentObject var entriesManager: SkinEntriesManager

    private var chartData: [ChartDataPoint] {
        // Get the last 5 entries, sorted by date (oldest first for charting)
        let sortedEntries = entriesManager.entries.sorted { $0.date < $1.date }
        let recentEntries = Array(sortedEntries.suffix(5))

        return recentEntries.map { entry in
            let label = parseClassificationLabel(from: entry.description)
            return ChartDataPoint(date: entry.date, confidence: entry.confidence, classificationLabel: label)
        }
    }

    private func parseClassificationLabel(from description: String) -> String {
        // Example description: "Prediction: Acne - Confidence: 75.5%"
        let parts = description.components(separatedBy: " - Confidence:")
        if let predictionPart = parts.first {
            return predictionPart.replacingOccurrences(of: "Prediction: ", with: "")
        }
        return "N/A" // Fallback if parsing fails
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Skin Confidence Trend (Last 5)")
                .font(.headline)
                .padding([.leading, .top])

            if chartData.count < 2 {
                ContentUnavailableView(
                    "Not Enough Data",
                    systemImage: "chart.line.uptrend.xyaxis.circle",
                    description: Text("At least two skin analysis entries are needed to show a trend.")
                )
                .frame(height: 200)
            } else {
                Chart(chartData) { dataPoint in
                    // Line Mark for the trend
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Confidence", dataPoint.confidence)
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom) // Smoother line

                    // Point Mark for each data point with annotation
                    PointMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Confidence", dataPoint.confidence)
                    )
                    .foregroundStyle(Color.blue)
                    .annotation(position: .overlay, alignment: .bottom, spacing: 5) {
                        Text(dataPoint.classificationLabel)
                            .font(.caption2)
                            .padding(3)
                            .background(Color.white.opacity(0.7).cornerRadius(3))
                            .foregroundColor(.black)
                    }
                     // RuleMark for tooltips (alternative or addition to annotation)
                    // RuleMark(x: .value("Date", dataPoint.date))
                    //     .foregroundStyle(.clear) // Make it invisible
                    //     .annotation(position: .top, alignment: .center, spacing: 0) { context in
                    //         if context.xPosition == .value("Date", dataPoint.date) { // Show only for the hovered point
                    //             VStack(alignment: .leading) {
                    //                 Text(dataPoint.date, style: .date)
                    //                 Text("Condition: \(dataPoint.classificationLabel)")
                    //                 Text("Confidence: \(dataPoint.confidence * 100, specifier: "%.1f")%")
                    //             }
                    //             .padding(8)
                    //             .background(Color.gray.opacity(0.8).cornerRadius(5))
                    //             .foregroundColor(.white)
                    //         }
                    //     }
                }
                .chartYAxis {
                    AxisMarks(preset: .automatic, values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(doubleValue * 100, specifier: "%.0f")%")
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .automatic, values: .automatic(desiredCount: 5)) { value in
                         AxisGridLine()
                         AxisTick()
                         AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 250) // Adjust height as needed
                .padding()
            }
        }
        .background(Color.gray.opacity(0.1).cornerRadius(10))
        .padding()
    }
}

// Preview Provider
@available(iOS 16.0, macOS 13.0, *)
struct SkinTrendChartView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = SkinEntriesManager()
        // Add some dummy data for preview
        let today = Date()
        if let image = UIImage(systemName: "photo") { // Dummy image
            manager.addEntry(SkinEntry(image: image, date: Calendar.current.date(byAdding: .day, value: -4, to: today)!, description: "Prediction: Acne - Confidence: 60.0%", confidence: 0.60))
            manager.addEntry(SkinEntry(image: image, date: Calendar.current.date(byAdding: .day, value: -3, to: today)!, description: "Prediction: Normal - Confidence: 30.0%", confidence: 0.30))
            manager.addEntry(SkinEntry(image: image, date: Calendar.current.date(byAdding: .day, value: -2, to: today)!, description: "Prediction: Dryness - Confidence: 75.0%", confidence: 0.75))
            manager.addEntry(SkinEntry(image: image, date: Calendar.current.date(byAdding: .day, value: -1, to: today)!, description: "Prediction: Acne - Confidence: 50.0%", confidence: 0.50))
            manager.addEntry(SkinEntry(image: image, date: today, description: "Prediction: Normal - Confidence: 20.0%", confidence: 0.20))
        }

        return SkinTrendChartView()
            .environmentObject(manager)
    }
}