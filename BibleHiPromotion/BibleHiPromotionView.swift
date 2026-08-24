//
//  BibleHiPromotionView.swift
//  NKJV Bible
//
//  Created on 31/12/25.
//

import SwiftUI

@available(iOS 15.0, *)
struct BibleHiPromotionView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var imageHeight: CGFloat {
        isIPad ? 220 : 180  // Increased significantly
    }
    
    private var horizontalPadding: CGFloat {
        isIPad ? 80 : 24
    }
    
    private var featureCardPadding: CGFloat {
        isIPad ? 100 : 40
    }
    
    private var buttonSize: CGFloat {
        isIPad ? 36 : 32
    }
    
    private var topPadding: CGFloat {
        isIPad ? 16 : 12
    }
    
    private var sidePadding: CGFloat {
        isIPad ? 20 : 16
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.96, green: 0.97, blue: 0.99),
                    Color(red: 0.90, green: 0.94, blue: 0.98)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Book illustration with X button
                    ZStack(alignment: .top) {
                        Image("BibleChat")
                            .resizable()
                            .scaledToFit()
                            .frame(height: imageHeight)
                            .frame(maxWidth: .infinity)
                            .padding(.top, isIPad ? 10 : 5)
                        
                        // X button on the right
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                dismiss()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.25))
                                        .frame(width: buttonSize, height: buttonSize)
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: isIPad ? 16 : 14, weight: .medium))
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal, sidePadding)
                        .padding(.top, topPadding)
                    }
                    
                    // BibleHi Logo
                    HStack(spacing: isIPad ? 16 : 12) {
                        Image("BibleHiLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: isIPad ? 60 : 50, height: isIPad ? 60 : 50)
                        
                        HStack(spacing: 0) {
                            Text("NLT Bible")
                                .font(.system(size: isIPad ? 48 : 42, weight: .bold))
                                .foregroundColor(Color.black)
                            
//                            Text("Hi")
//                                .font(.system(size: isIPad ? 48 : 42, weight: .bold))
//                                .foregroundColor(Color(hex: "1C46B2"))
                        }
                    }
                    //.padding(.top, 2)
                    .padding(.bottom, 0)
                    
                    // Main title
                    Text("Understand God's Word")
                        .font(.system(size: isIPad ? 34 : 28, weight: .bold))
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, isIPad ? 14 : 10)
                    
                    // Subtitle
                    Text("Get clear explanations and chapter summaries instantly.")
                        .font(.system(size: isIPad ? 18 : 16, weight: .regular))
                        .foregroundColor(Color(red: 0.4, green: 0.45, blue: 0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, isIPad ? 80 : 35)
                        .padding(.bottom, isIPad ? 26 : 22)
                    
                    // Feature cards - 2x2 grid
                    let columns: [GridItem] = [
                        GridItem(.flexible(), spacing: isIPad ? 18 : 12),
                        GridItem(.flexible(), spacing: isIPad ? 18 : 12)
                    ]

                    LazyVGrid(columns: columns, spacing: isIPad ? 18 : 14) {
                        FeatureCard(iconName: "Bible", systemIcon: "book.fill", title: "Verse Explanations", isIPad: isIPad)
                        FeatureCard(iconName: "Bulb", systemIcon: "lightbulb.fill", title: "Chapter Summaries", isIPad: isIPad)
                        FeatureCard(iconName: "Prayer", systemIcon: "message.fill", title: "Daily Verse & Prayer", isIPad: isIPad)
                        FeatureCard(iconName: "Chat", systemIcon: "bird.fill", title: "Ask Bible Questions", isIPad: isIPad)
                    }
                    .padding(.horizontal, isIPad ? 80 : 30)
                    .padding(.bottom, isIPad ? 18 : 14)

                    // Special badge
                    HStack(spacing: isIPad ? 8 : 6) {
                        if let _ = UIImage(named: "gift") {
                            Image("gift")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIPad ? 18 : 16, height: isIPad ? 18 : 16)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "gift.fill")
                                .font(.system(size: isIPad ? 14 : 13, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Text("Special for Bible Readers")
                            .font(.system(size: isIPad ? 15 : 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, isIPad ? 24 : 20)
                    .padding(.vertical, isIPad ? 12 : 10)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.65, blue: 0.3),
                                Color(red: 1.0, green: 0.75, blue: 0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .padding(.bottom, isIPad ? 18 : 14)
                    
                    // Open BibleHi button
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/us/app/new-living-translation-nlt/id6459818399") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        Text("Open NLT Bible")
                            .font(.system(size: isIPad ? 20 : 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isIPad ? 18 : 16)
                            .background(Color(hex: "1C46B2"))
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, featureCardPadding)
                    .padding(.bottom, isIPad ? 18 : 14)
                    
                    // Continue reading here
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Continue reading here")
                            .font(.system(size: isIPad ? 17 : 15, weight: .regular))
                            .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.6))
                    }
                    .padding(.bottom, isIPad ? 40 : 32)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct FeatureCard: View {
    let iconName: String?
    let systemIcon: String
    let title: String
    let isIPad: Bool

    private var displayTitle: String {
        switch title {
        case "Verse Explanations": return "Verse\nExplanations"
        case "Chapter Summaries":  return "Chapter\nSummaries"
        case "Daily Verse & Prayer": return "Daily Verse\n& Prayer"
        case "Ask Bible Questions": return "Ask Bible \nQuestions"
        default: return title
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: isIPad ? 12 : 10) {
            // Icon
            if let iconName = iconName, UIImage(named: iconName) != nil {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: isIPad ? 28 : 24, height: isIPad ? 28 : 24)
                    .foregroundColor(Color(red: 0.5, green: 0.7, blue: 0.95))
            }
            else if UIImage(named: systemIcon) != nil {
                Image(systemIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: isIPad ? 28 : 24, height: isIPad ? 28 : 24)
                    .foregroundColor(Color(red: 0.5, green: 0.7, blue: 0.95))
            }
            else {
                Image(systemName: systemIcon)
                    .font(.system(size: isIPad ? 18 : 15, weight: .medium))
                    .foregroundColor(Color(red: 0.5, green: 0.7, blue: 0.95))
                    .frame(width: isIPad ? 26 : 22, height: isIPad ? 26 : 22)
            }

            // Text
            Text(displayTitle)
                .font(.system(size: isIPad ? 15 : 14, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.35))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, isIPad ? 12 : 10)
        .padding(.vertical, isIPad ? 14 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: isIPad ? 65 : 55)
        .background(Color(red: 0.95, green: 0.96, blue: 0.98))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.88, green: 0.90, blue: 0.93), lineWidth: 0.5)
        )
    }
}

struct BibleHiPromotionView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            BibleHiPromotionView()
        }
    }
}
