//
//  DailyVerseFullscreenView.swift
//  NKJV Bible
//

import SwiftUI

struct DailyVerseFullscreenView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var verse: DailyVerseSnapshot
    var onClose: () -> Void
    var onForward: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if let image = UIImage(named: verse.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "1C46B2"), Color(hex: "0B1B3A")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .id(verse.imageName)
                .gesture(
                    DragGesture(minimumDistance: 40)
                        .onEnded { value in
                            let dx = value.translation.width
                            let dy = value.translation.height
                            guard abs(dx) > abs(dy), dx < -40 else { return }
                            onForward()
                        }
                )

                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.2), Color.black.opacity(0.75)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    HStack {
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.35))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()

                        Button(action: onForward) {
                            HStack(spacing: 6) {
                                Text("Next")
                                    .font(.system(size: 15, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, max(geometry.safeAreaInsets.top, 16))

                    Spacer()

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(verse.reference)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Text(verse.text)
                                .font(.system(size: 22, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .frame(maxHeight: geometry.size.height * 0.55)

                    HStack {
                        Spacer()
                        ForEach(1..<9, id: \.self) { i in
                            Circle()
                                .fill(verse.imageName == "S\(i).jpg" ? Color.white : Color.white.opacity(0.35))
                                .frame(width: 7, height: 7)
                        }
                        Spacer()
                    }
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
                .zIndex(1)
            }
        }
        .ignoresSafeArea()
    }

    private func close() {
        onClose()
        dismiss()
    }
}
