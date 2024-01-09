//
//  EntryButton.swift
//  WeighWise
//
//  Created by 625098 on 1/7/24.
//

import SwiftUI


struct EntryButton: View {
    private var label: String
    private let action: () -> Void
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
            let intensity: CGFloat
            switch label {
            case "\u{2190}":
                intensity = 2
            case ".":
                intensity = 2
            default:
                intensity = 4
            }
            impactFeedbackGenerator.prepare()
            impactFeedbackGenerator.impactOccurred(intensity: intensity)
        }) {
            Text(label)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.custom("JapandiRegular", size: label == "." ? 50 : 30))
                .foregroundColor(.black)
        }
    }
}
