import Foundation

enum SkinConditionChange: String {
    case improved = "Improved"
    case worsened = "Worsened"
    case stayedTheSame = "Stayed the Same"
    case notEnoughData = "Not Enough Data"
    case noChange = "No Change" // Added for when confidence is exactly the same
}