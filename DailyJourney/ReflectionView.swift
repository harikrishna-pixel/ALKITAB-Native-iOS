//
//  ReflectionView.swift
//  NKJV Bible
//

import SwiftUI
import IQKeyboardManager

struct ReflectionView: View {
    let verse: DailyVerseSnapshot
    @ObservedObject var store: DailyJourneyStore
    var isLockedReview: Bool = false
    var lockedText: String = ""
    var lockedOption: Int? = nil
    var onDone: () -> Void

    @State private var selectedOption: Int?
    @State private var text: String = ""
    /// True while the note field is being edited. The save and skip buttons stay hidden.
    @State private var keyboardVisible = false
    @State private var keyboardHeight: CGFloat = 0
    /// True when reflection was already completed before this visit (edit / review day).
    @State private var wasAlreadyCompleted = false

    private let options: [(icon: String, title: String)] = [
        ("heart.fill", "I feel encouraged"),
        ("bookmark.fill", "I want to remember this"),
        ("arrow.triangle.2.circlepath", "I need to trust God more"),
        ("person.2.fill", "I want to share this with someone")
    ]

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView(showsIndicators: false) {
                // Keyboard inset is handled below so this scroll view does not jump on its own.
                VStack(alignment: .leading, spacing: 16) {
                    Text(isLockedReview || wasAlreadyCompleted ? "Your Reflection" : "My Reflection")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    Text(verse.reference)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1C46B2"))

                    Text(isLockedReview
                          ? "Completed for this day."
                          : (wasAlreadyCompleted
                             ? "You can still add or change your reflection today."
                             : "What spoke to you? What will you take from today's verse?"))
                        .font(.system(size: 15))
                        .foregroundColor(Color.black.opacity(0.55))

                    VStack(spacing: 10) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                selectedOption = index
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: option.icon)
                                        .foregroundColor(selectedOption == index ? Color(hex: "1C46B2") : Color.black.opacity(0.35))
                                        .frame(width: 24)
                                    Text(option.title)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: selectedOption == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedOption == index ? Color(hex: "1C46B2") : Color.black.opacity(0.2))
                                }
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedOption == index ? Color(hex: "1C46B2") : Color.black.opacity(0.08), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isLockedReview)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(isLockedReview || wasAlreadyCompleted ? "Your thoughts" : "Write your thoughts...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.black.opacity(0.45))

                        ZStack(alignment: .topLeading) {
                            if isLockedReview {
                                Text(text.isEmpty ? "No note saved." : text)
                                    .font(.system(size: 16))
                                    .foregroundColor(text.isEmpty ? Color.black.opacity(0.35) : .black)
                                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                                    .padding(12)
                            } else {
                                if text.isEmpty {
                                    Text("A short note to yourself...")
                                        .foregroundColor(Color.black.opacity(0.3))
                                        .padding(.top, 12)
                                        .padding(.leading, 12)
                                }
                                StableReflectionEditor(text: $text)
                                    .frame(minHeight: 120)
                                    .padding(8)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                        if !isLockedReview {
                            Text("\(min(text.count, 300))/300")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black.opacity(0.35))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }

                    if wasAlreadyCompleted && !isLockedReview {
                        Text("Completed for today")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "1B7A3D"))
                    }
                }
                .padding(20)
                .padding(.bottom, keyboardHeight)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            VStack(spacing: 10) {
                Button(action: save) {
                    Text(reflectionButtonTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(canSaveReflection ? reflectionButtonColor : Color.gray.opacity(0.4))
                        .cornerRadius(27)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canSaveReflection)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .padding(.top, 8)
            .opacity(keyboardVisible ? 0 : 1)
            .allowsHitTesting(!keyboardVisible)
            .accessibilityHidden(keyboardVisible)
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { note in
            keyboardVisible = true
            if let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardVisible = false
            keyboardHeight = 0
        }
        .onAppear {
            IQKeyboardManager.shared().isEnabled = false
            if isLockedReview {
                wasAlreadyCompleted = true
                text = String(lockedText.prefix(300))
                selectedOption = lockedOption
                if selectedOption == nil {
                    selectedOption = options.firstIndex(where: { lockedText.contains($0.title) })
                }
                return
            }
            wasAlreadyCompleted = store.reflectionCompleted
            text = String(store.reflectionText.prefix(300))
            selectedOption = store.reflectionOptionIndex
            if selectedOption == nil {
                selectedOption = options.firstIndex(where: { store.reflectionText.contains($0.title) })
            }
        }
        .onDisappear {
            keyboardVisible = false
            IQKeyboardManager.shared().isEnabled = true
        }
        .onChange(of: text) { newValue in
            if newValue.count > 300 {
                text = String(newValue.prefix(300))
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.08))
                Capsule()
                    .fill(Color(hex: "1C46B2"))
                    .frame(width: geo.size.width * (wasAlreadyCompleted || store.reflectionCompleted ? 1.0 : 0.75))
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var reflectionButtonTitle: String {
        if isLockedReview || wasAlreadyCompleted { return "Today's Journey Completed" }
        return "Save Reflection"
    }

    private var reflectionButtonColor: Color {
        isLockedReview || wasAlreadyCompleted ? Color(hex: "1C7A3D") : Color(hex: "1C46B2")
    }

    private var canSaveReflection: Bool {
        if isLockedReview || wasAlreadyCompleted { return true }
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasText || selectedOption != nil
    }

    private func save() {
        if isLockedReview {
            onDone()
            return
        }
        guard canSaveReflection else { return }
        var combined = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let selectedOption = selectedOption {
            let label = options[selectedOption].title
            if combined.isEmpty {
                combined = label
            } else if !combined.contains(label) {
                combined = "\(label). \(combined)"
            }
        }
        // Re-saving after completion only updates content; streak reward is already guarded for today.
        store.markReflectionCompleted(text: combined, optionIndex: selectedOption)
        store.markVerseCompleted()
        onDone()
    }
}

/// Text box that does not scroll its parent when focused, so the Reflection screen does not jump.
private struct StableReflectionEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = ReflectionTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .black
        textView.tintColor = UIColor(red: 0.11, green: 0.27, blue: 0.70, alpha: 1)
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = false
        textView.clipsToBounds = true
        textView.contentInset = .zero
        textView.contentInsetAdjustmentBehavior = .never
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        textView.text = text
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 16)
        if textView.text != text {
            textView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        init(text: Binding<String>) { self.text = text }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text ?? ""
        }
    }
}

/// Keeps the typed note inside the box and shifts the page only enough to clear the keyboard.
private final class ReflectionTextView: UITextView {
    private var watchingKeyboard = false
    private var offsetObservation: NSKeyValueObservation?
    private var restingOffset: CGFloat = 0
    private var hasRestingOffset = false
    private var keyboardVisible = false
    /// Highest the page may move while the keyboard is open.
    private var maxContentOffsetY: CGFloat?
    private var isClamping = false

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 120)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopWatchingKeyboard()
        } else {
            startWatchingKeyboard()
        }
    }

    deinit {
        stopWatchingKeyboard()
    }

    override func becomeFirstResponder() -> Bool {
        if !keyboardVisible {
            rememberRestingOffset()
        }
        let accepted = super.becomeFirstResponder()
        showTypedText()
        return accepted
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !keyboardVisible && !isFirstResponder {
            rememberRestingOffset()
        }
        showTypedText()
    }

    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        showTypedText()
    }

    private func showTypedText() {
        guard bounds.height > 1 else { return }
        textColor = .black
        if contentInset != .zero {
            contentInset = .zero
        }
        let maxY = max(0, contentSize.height - bounds.height)
        let next = contentSize.height <= bounds.height + 1 ? 0 : min(max(0, contentOffset.y), maxY)
        if abs(contentOffset.y - next) > 0.5 {
            contentOffset.y = next
        }
    }

    private func rememberRestingOffset() {
        guard let scroll = enclosingScrollView() else { return }
        restingOffset = scroll.contentOffset.y
        hasRestingOffset = true
    }

    private func startWatchingKeyboard() {
        guard !watchingKeyboard else { return }
        watchingKeyboard = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        attachOffsetClamp()
    }

    private func attachOffsetClamp() {
        guard offsetObservation == nil, let scroll = enclosingScrollView() else { return }
        offsetObservation = scroll.observe(\.contentOffset, options: [.new]) { [weak self] scroll, _ in
            guard let self = self, !self.isClamping, let maxY = self.maxContentOffsetY else { return }
            if scroll.contentOffset.y > maxY + 1 {
                self.isClamping = true
                scroll.setContentOffset(CGPoint(x: 0, y: maxY), animated: false)
                self.isClamping = false
            }
        }
    }

    private func stopWatchingKeyboard() {
        guard watchingKeyboard else { return }
        watchingKeyboard = false
        NotificationCenter.default.removeObserver(self)
        offsetObservation?.invalidate()
        offsetObservation = nil
        maxContentOffsetY = nil
    }

    @objc private func keyboardWillChange(_ note: Notification) {
        guard isFirstResponder, let window = window else { return }
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        IQKeyboardManager.shared().isEnabled = false
        keepHostInPlace()
        attachOffsetClamp()
        let keyboardTop = window.convert(frame, from: nil).minY
        guard keyboardTop < window.bounds.height - 1 else { return }
        keyboardVisible = true
        // Do not lock the page here. The extra space under the note is added on the
        // next layout, and an early lock kept the box under the keyboard.
        maxContentOffsetY = nil
        moveBoxAboveKeyboard(keyboardTop: keyboardTop)
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isFirstResponder, self.keyboardVisible else { return }
            self.moveBoxAboveKeyboard(keyboardTop: keyboardTop)
            self.keepHostInPlace()
            self.showTypedText()
        }
    }

    /// Scrolls only far enough for the note box to sit above the keyboard.
    private func moveBoxAboveKeyboard(keyboardTop: CGFloat) {
        guard let window = window, let scroll = enclosingScrollView() else { return }
        if !hasRestingOffset {
            restingOffset = scroll.contentOffset.y
            hasRestingOffset = true
        }
        let base = restingOffset
        let alreadyShifted = scroll.contentOffset.y - base
        let fieldBottomAtRest = convert(bounds, to: window).maxY + alreadyShifted
        let shift = max(0, fieldBottomAtRest - (keyboardTop - 16))
        let maxOffset = max(0, scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom)
        let target = min(maxOffset, base + shift)
        if abs(scroll.contentOffset.y - target) > 1 {
            isClamping = true
            scroll.setContentOffset(CGPoint(x: scroll.contentOffset.x, y: target), animated: false)
            isClamping = false
        }
        showTypedText()
    }

    private func keepHostInPlace() {
        var responder: UIResponder? = self
        while let current = responder {
            if let controller = current as? UIViewController, controller.view.frame.origin.y < 0 {
                controller.view.frame.origin.y = 0
                return
            }
            responder = current.next
        }
    }

    @objc private func keyboardWillHide() {
        maxContentOffsetY = nil
        if let scroll = enclosingScrollView() {
            let base = hasRestingOffset ? restingOffset : 0
            scroll.setContentOffset(CGPoint(x: 0, y: base), animated: false)
        }
        keyboardVisible = false
        showTypedText()
    }

    private func enclosingScrollView() -> UIScrollView? {
        var view = superview
        while let current = view {
            if let scroll = current as? UIScrollView, scroll !== self {
                return scroll
            }
            view = current.superview
        }
        return nil
    }
}
