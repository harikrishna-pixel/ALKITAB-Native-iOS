//
//  OnboardingNotificationView.swift
//  NKJV Bible
//

import SwiftUI
import UserNotifications

struct OnboardingNotificationView: View {
    @State private var navigateForward = false
    @State private var dailyVerseOn = true
    @State private var journeyReminderOn = true
    @State private var memoryChallengeOn = false
    @State private var prayerWallOn = false
    @State private var isSaving = false

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        GeometryReader { geometry in
            // One scale for every device: iPad larger, small phones (SE / mini) slightly tighter.
            let compact = !isPad && geometry.size.height < 700
            let s: CGFloat = isPad ? 1.3 : (compact ? 0.9 : 1.0)
            let maxContentWidth: CGFloat = isPad ? 560 : .infinity

            ZStack {
                OnboardingTheme.darkPageGradient.ignoresSafeArea()

                RadialGradient(
                    colors: [OnboardingTheme.gold.opacity(0.14), Color.clear],
                    center: UnitPoint(x: 0.45, y: 0.62),
                    startRadius: 0,
                    endRadius: 230 * s
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    GeometryReader { scrollArea in
                        ScrollView(showsIndicators: false) {
                            content(scale: s)
                                .frame(maxWidth: maxContentWidth)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: scrollArea.size.height)
                        }
                    }

                    VStack(spacing: 0) {
                        Text("Two gentle reminders a day. Nothing more, unless you ask.")
                            .font(.system(size: 12.5 * s))
                            .foregroundColor(OnboardingTheme.dim)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 26)
                            .padding(.bottom, 16 * s)

                        OnboardingPrimaryButton(title: "Keep Me Rooted") {
                            requestNotificationsThenContinue()
                        }
                        .disabled(isSaving)
                        .padding(.horizontal, 26)

                        OnboardingGhostButton(title: "Maybe Later") {
                            navigateForward = true
                        }
                        .padding(.horizontal, 26)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, compact ? 8 : 12)
                }
            }
            .background(
                NavigationLink(
                    destination: Onboarding4(),
                    isActive: $navigateForward,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
        .navigationBarHidden(true)
    }

    // MARK: - Content

    private func content(scale s: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12 * s)

            OnboardingSerifTitle(
                lines: ["Keep God's", "Word Close"],
                size: 34 * s,
                alignment: .center
            )
            .padding(.horizontal, 26)

            Text("Your verse, waiting for you each morning.")
                .font(.system(size: 15.5 * s))
                .lineSpacing(3)
                .foregroundColor(OnboardingTheme.dim)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 48)
                .padding(.top, 12 * s)

            Spacer(minLength: 18 * s)

            Text("WHAT YOU'LL RECEIVE")
                .font(.system(size: 11 * s, weight: .heavy))
                .tracking(1.8)
                .foregroundColor(OnboardingTheme.gold)

            VStack(spacing: 10 * s) {
                NotificationPreviewCard(
                    scale: s,
                    title: "Today's Verse",
                    time: "8:00 AM",
                    message: "\"\(OnboardingBibleVerse.text)\" · \(OnboardingBibleVerse.reference)"
                )
                NotificationPreviewCard(
                    scale: s,
                    title: "One step left today",
                    time: "8:00 PM",
                    message: "Take a minute to reflect on today's verse."
                )
            }
            .padding(.horizontal, 26)
            .padding(.top, 12 * s)

            Spacer(minLength: 14 * s)

            VStack(spacing: 0) {
                NotificationToggleRow(
                    scale: s,
                    title: "Your daily verse",
                    time: "8:00 AM",
                    note: nil,
                    isOn: $dailyVerseOn
                )
                NotificationToggleRow(
                    scale: s,
                    title: "Journey reminder",
                    time: "8:00 PM",
                    note: "only if today isn't finished",
                    isOn: $journeyReminderOn,
                    showDivider: false
                )
                // Memory challenge and Prayer Wall hidden on onboarding.
                // OnboardingToggleRow(
                //     title: "Memory challenge",
                //     detail: "Off by default",
                //     isOn: $memoryChallengeOn
                // )
                // OnboardingToggleRow(
                //     title: "Prayer Wall activity",
                //     detail: "Off by default",
                //     isOn: $prayerWallOn,
                //     showDivider: false
                // )
            }
            .padding(.horizontal, 26)

            Spacer(minLength: 14 * s)
        }
    }

    private func requestNotificationsThenContinue() {
        guard !isSaving else { return }
        isSaving = true
        OnboardingNotificationScheduler.applyFromOnboarding(
            dailyVerse: dailyVerseOn,
            journey: journeyReminderOn,
            memory: memoryChallengeOn,
            prayer: prayerWallOn
        ) {
            isSaving = false
            navigateForward = true
        }
    }
}

// MARK: - Notification preview card ("What you'll receive")

private struct NotificationPreviewCard: View {
    let scale: CGFloat
    let title: String
    let time: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12 * scale) {
            Image(systemName: "book.fill")
                .font(.system(size: 16 * scale, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36 * scale, height: 36 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 9 * scale, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "3B82F6"), OnboardingTheme.primaryBlueDark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )

            VStack(alignment: .leading, spacing: 3 * scale) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.system(size: 14.5 * scale, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 8)
                    Text(time)
                        .font(.system(size: 12 * scale))
                        .foregroundColor(OnboardingTheme.dim)
                }
                Text(message)
                    .font(.system(size: 14 * scale))
                    .lineSpacing(2)
                    .foregroundColor(Color.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14 * scale)
        .padding(.vertical, 14 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
}

// MARK: - Toggle row with time pill

private struct NotificationToggleRow: View {
    let scale: CGFloat
    let title: String
    let time: String
    let note: String?
    @Binding var isOn: Bool
    var showDivider: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6 * scale) {
                    Text(title)
                        .font(.system(size: 16 * scale, weight: .bold))
                        .foregroundColor(.white)
                    HStack(spacing: 8 * scale) {
                        Text(time)
                            .font(.system(size: 12.5 * scale, weight: .bold))
                            .foregroundColor(OnboardingTheme.gold)
                            .padding(.horizontal, 11 * scale)
                            .padding(.vertical, 4 * scale)
                            .background(Capsule().fill(OnboardingTheme.gold.opacity(0.12)))
                            .overlay(Capsule().stroke(OnboardingTheme.gold.opacity(0.7), lineWidth: 1))
                        if let note = note {
                            Text(note)
                                .font(.system(size: 12 * scale))
                                .foregroundColor(OnboardingTheme.dim)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                Spacer(minLength: 8)
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(OnboardingSwitchStyle())
            }
            .padding(.vertical, 16 * scale)
            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.09))
                    .frame(height: 1)
            }
        }
    }
}

#Preview {
    OnboardingNotificationView()
}
