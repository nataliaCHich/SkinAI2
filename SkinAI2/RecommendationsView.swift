import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject var entriesManager: SkinEntriesManager
    private let recommendationEngine = RecommendationEngine()
    @State private var currentRecommendations: [SkincareRecommendation] = []
    @State private var currentAdvisedCondition: AdvisedSkinCondition = .normal

    // Group recommendations by type for sectioned display
    private var groupedRecommendations: [RecommendationType: [SkincareRecommendation]] {
        Dictionary(grouping: currentRecommendations, by: { $0.type })
    }
    
    private var recommendationTypesInOrder: [RecommendationType] = [.generalTip, .ingredientToSeek, .ingredientToAvoid]

    private var sortedRecommendationGroups: [(type: RecommendationType, recommendations: [SkincareRecommendation])] {
        return recommendationTypesInOrder.compactMap { type -> (RecommendationType, [SkincareRecommendation])? in
            guard let recommendations = groupedRecommendations[type], !recommendations.isEmpty else {
                return nil
            }
            return (type, recommendations)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.pink.opacity(0.0)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

                VStack {
                    Text("Personalized Advice for \(currentAdvisedCondition.rawValue) Skin")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding()

                    if currentRecommendations.isEmpty {
                        ContentUnavailableView(
                            "No Recommendations Yet",
                            systemImage: "sparkles",
                            description: Text("Analyze your skin or add journal entries to get personalized advice.")
                        ).padding()
                    } else {
                        List {
                            ForEach(sortedRecommendationGroups, id: \.type) { group in
                                // Explicitly create a Section for each group
                                Section(header: Text(group.type.rawValue).font(.headline).foregroundColor(.blue.opacity(0.8))) {
                                    ForEach(group.recommendations) { recommendation in
                                        RecommendationRow(recommendation: recommendation)
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("Skincare Advice")
                .onAppear(perform: loadRecommendations)
                .onChange(of: entriesManager.entries) { _, _ in
                    loadRecommendations()
                }
            }
        }
    }

    private func loadRecommendations() {
        // Determine current skin condition
        // This uses the logic from MyProductsView for now.
        // Consider a more centralized way to get current advised skin condition.
        let latestPrediction: String
        if let lastEntry = entriesManager.entries.sorted(by: { $0.date > $1.date }).first {
            let parts = lastEntry.description.components(separatedBy: " - Confidence:")
            if let predictionPart = parts.first {
                latestPrediction = predictionPart.replacingOccurrences(of: "Prediction: ", with: "")
            } else {
                latestPrediction = "Normal" // Default
            }
        } else {
            latestPrediction = "Normal" // Default if no entries
        }
        
        currentAdvisedCondition = mapMLPredictionToAdvisedCondition(latestPrediction)
        currentRecommendations = recommendationEngine.generateRecommendations(for: currentAdvisedCondition)
    }
}

struct RecommendationRow: View {
    let recommendation: SkincareRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(recommendation.title)
                .font(.headline)
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}

struct RecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationsView()
            .environmentObject(SkinEntriesManager()) // Provide a dummy manager for preview
    }
}
