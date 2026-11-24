//
//  GiftCardCongratsView.swift
//  NKJV Bible
//
//  Gift Card claim UI — matches referral: chest + ribbon + ×2 / Claim.
//

import SwiftUI
import UIKit

final class GiftCardCongratsHost: UIView {
    private let hosting: UIHostingController<GiftCardCongratsCard>

    var onDoubleAd: (() -> Void)?
    var onClaim: (() -> Void)?

    init(credits: Int) {
        let host = UIHostingController(rootView: GiftCardCongratsCard(
            credits: credits,
            isLoadingAd: false,
            onDoubleAd: {},
            onClaim: {}
        ))
        self.hosting = host
        super.init(frame: .zero)
        backgroundColor = .clear
        host.view.backgroundColor = .clear
        addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: topAnchor),
            host.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        refreshRoot(credits: credits, isLoadingAd: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(credits: Int, isLoadingAd: Bool) {
        refreshRoot(credits: credits, isLoadingAd: isLoadingAd)
    }

    private func refreshRoot(credits: Int, isLoadingAd: Bool) {
        hosting.rootView = GiftCardCongratsCard(
            credits: credits,
            isLoadingAd: isLoadingAd,
            onDoubleAd: { [weak self] in self?.onDoubleAd?() },
            onClaim: { [weak self] in self?.onClaim?() }
        )
    }
}

struct GiftCardCongratsCard: View {
    var credits: Int
    var isLoadingAd: Bool
    var onDoubleAd: () -> Void
    var onClaim: () -> Void

    private let titleBlue = Color(hex: "12315C")
    private let buttonBlue = Color(hex: "1C46B2")
    private let creditYellow = Color(hex: "FFE56A")
    private let cardCream = Color(hex: "F6E9C8")
    private let screenBg = Color(hex: "E8E8E8")

    var body: some View {
        VStack(spacing: 18) {
            card
            doubleButton
            claimButton
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(screenBg.ignoresSafeArea())
    }

    private var card: some View {
        GeometryReader { geo in
            let side = geo.size.width
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(cardCream)

                // Scale past PNG margins so cream art covers top + bottom (no white strip).
                Image("GiftCardChest")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.22)
                    .frame(width: side, height: side)
                    .clipped()

                Text("Congratulations!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(titleBlue)
                    .padding(.top, 14)

                VStack {
                    Spacer(minLength: 0)
                    ZStack {
                        Image("GiftCardRibbon")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 0)

                        collectText
                            .offset(y: -2)
                    }
                    .padding(.bottom, 4)
                }
            }
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.16), radius: 12, y: 6)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var collectText: some View {
        HStack(spacing: 6) {
            Text("Collect")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text("\(credits)")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(creditYellow)
            Text("Credits")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private var doubleButton: some View {
        Button(action: onDoubleAd) {
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2F6BFF"), buttonBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 56)

                if isLoadingAd {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    HStack(spacing: 0) {
                        // Referral: movie clapper / video asset
                        Group {
                            if UIImage(named: "video") != nil {
                                Image("video")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "movieclapper")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 56, height: 28)

                        Rectangle()
                            .fill(Color.white.opacity(0.65))
                            .frame(width: 1.5, height: 28)

                        HStack(spacing: 10) {
                            Image("GiftCardCoin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                            Text("×  2")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 6)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoadingAd)
    }

    private var claimButton: some View {
        Button(action: onClaim) {
            Text("Claim")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(buttonBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Capsule().fill(Color.white))
                .overlay(Capsule().stroke(buttonBlue, lineWidth: 2.5))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoadingAd)
    }
}
