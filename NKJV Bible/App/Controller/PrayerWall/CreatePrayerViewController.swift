//
//  CreatePrayerViewController.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift

final class CreatePrayerViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var onPrayerCreated: (() -> Void)?

    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleField = UITextField()
    private let categoryField = UITextField()
    private let durationField = UITextField()
    private let nameField = UITextField()
    private let descriptionView = UITextView()
    private let descriptionPlaceholder = UILabel()
    private let anonymousSwitch = UISwitch()
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let categories = ["Family", "Health", "Guidance", "Thankfulness", "Peace", "Strength", "Other"]
    private let categoryPicker = UIPickerView()
    private let durationPicker = UIPickerView()
    private let durationOptions = Array(1...30)

    init() {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(coder: coder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Share Prayer"
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        setupNavigation()
        setupForm()
    }

    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = isNight ? .white : themeColor
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = isNight ? DarkModeColor : themeColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        navigationController?.navigationBar.barTintColor = isNight ? DarkModeColor : themeColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    private func setupForm() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        durationPicker.delegate = self
        durationPicker.dataSource = self

        titleField.placeholder = "Prayer title"
        categoryField.placeholder = "Category"
        durationField.placeholder = "Duration (days)"
        nameField.placeholder = "Your name (optional)"
        titleField.borderStyle = .roundedRect
        categoryField.borderStyle = .roundedRect
        durationField.borderStyle = .roundedRect
        nameField.borderStyle = .roundedRect
        categoryField.inputView = categoryPicker
        durationField.inputView = durationPicker
        categoryField.text = categories.first
        durationField.text = "7"
        titleField.delegate = self

        descriptionView.font = UIFont.systemFont(ofSize: 16)
        descriptionView.layer.cornerRadius = 8
        descriptionView.layer.borderWidth = 0.5
        descriptionView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionView.delegate = self
        descriptionView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        descriptionView.textColor = isNight ? .white : .black

        descriptionPlaceholder.text = "Prayer description"
        descriptionPlaceholder.font = UIFont.systemFont(ofSize: 16)
        descriptionPlaceholder.textColor = .placeholderText
        descriptionView.addSubview(descriptionPlaceholder)
        descriptionPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        let anonymousLabel = makeLabel("Post anonymously")
        anonymousSwitch.isOn = true

        submitButton.setTitle("Post Prayer", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = isNight ? DarkModeColor : themeColor
        submitButton.layer.cornerRadius = 12
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white

        let stack = UIStackView(arrangedSubviews: [
            makeFieldBlock(label: "Title", field: titleField),
            makeFieldBlock(label: "Category", field: categoryField),
            makeFieldBlock(label: "Keep prayer for (days)", field: durationField),
            makeFieldBlock(label: "Name", field: nameField),
            makeDescriptionBlock(),
            makeSwitchRow(label: anonymousLabel, control: anonymousSwitch),
            submitButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        submitButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        submitButton.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 6),

            activityIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor)
        ])
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = isNight ? .white : .black
        return label
    }

    private func makeFieldBlock(label: String, field: UITextField) -> UIStackView {
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        field.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        field.textColor = isNight ? .white : .black
        let stack = UIStackView(arrangedSubviews: [makeLabel(label), field])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeDescriptionBlock() -> UIStackView {
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        let stack = UIStackView(arrangedSubviews: [makeLabel("Description"), descriptionView])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeSwitchRow(label: UILabel, control: UISwitch) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        return row
    }

    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }

    @objc private func submitTapped() {
        let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let category = (categoryField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let duration = Int(durationField.text ?? "") ?? 0
        let userName = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, title.count <= 120 else {
            view.makeToast("Enter a title up to 120 characters.", duration: 2.0, position: .bottom)
            return
        }
        guard !description.isEmpty, description.count <= 2000 else {
            view.makeToast("Enter a description up to 2000 characters.", duration: 2.0, position: .bottom)
            return
        }
        guard !category.isEmpty, category.count <= 60 else {
            view.makeToast("Choose a category.", duration: 2.0, position: .bottom)
            return
        }
        guard (1...366).contains(duration) else {
            view.makeToast("Duration must be between 1 and 366 days.", duration: 2.0, position: .bottom)
            return
        }

        PrayerWallLoginGate.requireLogin(from: self) { [weak self] in
            guard let self = self else { return }
            self.submitButton.isEnabled = false
            self.activityIndicator.startAnimating()

            PrayerWallService.shared.createPrayer(
                title: title,
                description: description,
                category: category,
                durationDays: duration,
                userName: userName,
                isAnonymous: self.anonymousSwitch.isOn
            ) { [weak self] result in
                guard let self = self else { return }
                self.submitButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                switch result {
                case .success:
                    self.onPrayerCreated?()
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self.view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
                }
            }
        }
    }
}

extension CreatePrayerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == categoryPicker ? categories.count : durationOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return categories[row]
        }
        return "\(durationOptions[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            categoryField.text = categories[row]
        } else {
            durationField.text = "\(durationOptions[row])"
        }
    }
}
