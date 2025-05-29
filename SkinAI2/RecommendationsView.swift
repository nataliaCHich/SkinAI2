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
                        .fontWeight(.medium) 
                        .foregroundColor(Color.blue.opacity(0.9))
                        .padding()
                        // .background(Color.white.opacity(0.7)) 
                        // .cornerRadius(10)
                        .padding(.top)


                    if currentRecommendations.isEmpty {
                        ContentUnavailableView(
                            "No Recommendations Yet",
                            systemImage: "sparkles",
                            description: Text("Analyze your skin or add journal entries to get personalized advice.")
                        )
                        .padding()
                        .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(sortedRecommendationGroups, id: \.type) { group in
                                Section(
                                    header: Text(group.type.rawValue)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.blue)
                                        .padding(.leading)
                                ) {
                                    ForEach(group.recommendations) { recommendation in
                                        RecommendationRow(recommendation: recommendation)
                                            .listRowBackground(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white.opacity(0.8))
                                                    .padding(.vertical, 4)
                                                    .padding(.horizontal, 8)
                                            )
                                            .listRowSeparator(.hidden)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
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
        let latestPrediction: String
        if let lastEntry = entriesManager.entries.sorted(by: { $0.date > $1.date }).first {
            let parts = lastEntry.description.components(separatedBy: " - Confidence:")
            if let predictionPart = parts.first {
                latestPrediction = predictionPart.replacingOccurrences(of: "Prediction: ", with: "")
            } else {
                latestPrediction = "Normal"
            }
        } else {
            latestPrediction = "Normal"
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
                .foregroundColor(Color.blue.opacity(0.85))
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(Color.black)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 5)
    }
}

struct RecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = SkinEntriesManager()
        if let dummyImage = UIImage(systemName: "photo") {
             let entry1 = SkinEntry(image: dummyImage, date: Date(), description: "Prediction: Acne - Confidence: 0.8", confidence: 0.8)
             manager.addEntry(entry1)
        }
        return RecommendationsView()
            .environmentObject(manager)
    }
}
