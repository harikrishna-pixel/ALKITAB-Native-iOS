//
//  ChallengeAttemptsViewController.swift
//  NKJV Bible
//
//  Settings → Challenge Attempts
//  Lists my challenges, then players who attempted each one.
//

import UIKit
import Toast_Swift

final class ChallengeAttemptsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool

    private var challenges: [ChallengeSummary] = []
    private var attemptCounts: [String: Int] = [:]
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .large)

    /// Shared nav bar state from the screen we came from (restored when leaving).
    private var savedNavBarHidden: Bool?
    private var savedTintColor: UIColor?
    private var savedStandardAppearance: UINavigationBarAppearance?
    private var savedScrollEdgeAppearance: UINavigationBarAppearance?

    init() {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Challenge Attempts"
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        if let bar = navigationController?.navigationBar {
            savedNavBarHidden = navigationController?.isNavigationBarHidden
            savedTintColor = bar.tintColor
            savedStandardAppearance = bar.standardAppearance.copy()
            savedScrollEdgeAppearance = bar.scrollEdgeAppearance?.copy()
        }
        setupNavigation()
        setupUI()
        loadChallenges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Own header (same style as other screens) instead of the system bar.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Only when going back (not when pushing the attempts detail screen).
        guard isMovingFromParent, let nav = navigationController else { return }
        if let savedStandardAppearance = savedStandardAppearance {
            nav.navigationBar.standardAppearance = savedStandardAppearance
        }
        nav.navigationBar.scrollEdgeAppearance = savedScrollEdgeAppearance
        nav.navigationBar.tintColor = savedTintColor
        if let savedNavBarHidden = savedNavBarHidden {
            nav.setNavigationBarHidden(savedNavBarHidden, animated: animated)
        }
    }

    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = isNight ? .white : .white
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = isNight ? DarkModeColor : themeColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(loadChallenges)
        )
    }

    /// Blue header matching AI Chat / other screens: BackArrow, centered title, plain refresh icon.
    private func setupHeader() -> UIView {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = isNight ? DarkModeColor : themeColor
        view.addSubview(header)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Challenge Attempts"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        header.addSubview(titleLabel)

        let backImageView = UIImageView(image: UIImage(named: "BackArrow"))
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        backImageView.contentMode = .scaleAspectFit
        header.addSubview(backImageView)
        ImageTint.sharedInstance.imageTintcolorMethod(img: backImageView, colorVu: .white)

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        header.addSubview(backButton)

        let refreshButton = UIButton(type: .system)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        refreshButton.tintColor = .white
        refreshButton.addTarget(self, action: #selector(loadChallenges), for: .touchUpInside)
        header.addSubview(refreshButton)

        let headerHeight: CGFloat = StatusbarHeight > 30 ? 90 : 70
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: headerHeight),

            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -15),

            backImageView.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 30),
            backImageView.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -15),
            backImageView.widthAnchor.constraint(equalToConstant: 20),
            backImageView.heightAnchor.constraint(equalToConstant: 20),

            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            backButton.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 75),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            refreshButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            refreshButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 44),
            refreshButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        return header
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
        let header = setupHeader()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChallengeAttemptCell")
        // Prefer subtitle cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChallengeAttemptSubtitle")
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No challenges yet.\nCreate a challenge from Challenge Hub, then players’ attempts will show here."
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.7) : .darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func loadChallenges() {
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            return
        }

        // On refresh keep the current rows on screen; only the first load shows the center spinner.
        if challenges.isEmpty {
            spinner.startAnimating()
            emptyLabel.isHidden = true
        }

        CreatorChallengeService.shared.listChallenges { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.spinner.stopAnimating()
                self.challenges = []
                self.attemptCounts = [:]
                self.emptyLabel.isHidden = false
                self.emptyLabel.text = error.localizedDescription
                self.tableView.reloadData()
                print("[CreatorChallenge] listChallenges failed: \(error.localizedDescription)")
            case .success(let list):
                let active = list.filter { ($0.status ?? "active").lowercased() != "deleted" }
                if active.isEmpty {
                    self.challenges = active
                    self.attemptCounts = [:]
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                    self.emptyLabel.text = "No challenges yet.\nCreate a challenge from Challenge Hub, then players’ attempts will show here."
                    self.emptyLabel.isHidden = false
                } else {
                    self.loadAttemptCounts(for: active)
                }
            }
        }
    }

    private func loadAttemptCounts(for challenges: [ChallengeSummary]) {
        let group = DispatchGroup()
        var counts: [String: Int] = [:]

        for challenge in challenges {
            group.enter()
            CreatorChallengeService.shared.getAttempts(challengeId: challenge.id) { result in
                switch result {
                case .success(let attempts):
                    counts[challenge.id] = attempts.count
                    print("[CreatorChallenge] attempts for \(challenge.id): \(attempts.count)")
                case .failure(let error):
                    counts[challenge.id] = 0
                    print("[CreatorChallenge] attempts failed for \(challenge.id): \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.spinner.stopAnimating()
            self.challenges = challenges
            self.attemptCounts = counts
            self.emptyLabel.isHidden = !self.challenges.isEmpty
            self.tableView.reloadData()
        }
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ChallengeAttemptSubtitle")
        let challenge = challenges[indexPath.row]
        let count = attemptCounts[challenge.id]
        let title = challenge.title?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            ?? "Challenge"
        let countText: String
        if let count = count {
            countText = count == 1 ? "1 attempt" : "\(count) attempts"
        } else {
            countText = "Loading…"
        }
        let status = challenge.status ?? "active"

        cell.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.06) : .white
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = isNight ? .white : .black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.textLabel?.text = title
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.textColor = isNight ? UIColor.white.withAlphaComponent(0.65) : .darkGray
        cell.detailTextLabel?.text = "\(countText) · \(status)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let challenge = challenges[indexPath.row]
        let detail = ChallengeAttemptDetailViewController(challenge: challenge)
        // Detail screen still uses the system bar for its back button.
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - Detail: who played

final class ChallengeAttemptDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let challenge: ChallengeSummary
    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool

    private var attempts: [ChallengeAttempt] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .large)

    init(challenge: ChallengeSummary) {
        self.challenge = challenge
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = challenge.title?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "Attempts"
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        setupNavigation()
        setupUI()
        loadAttempts()
    }

    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .white
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = isNight ? DarkModeColor : themeColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AttemptRow")
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No one has attempted this challenge yet."
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.7) : .darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadAttempts() {
        spinner.startAnimating()
        CreatorChallengeService.shared.getAttempts(challengeId: challenge.id) { [weak self] result in
            guard let self = self else { return }
            self.spinner.stopAnimating()
            switch result {
            case .failure(let error):
                self.attempts = []
                self.emptyLabel.isHidden = false
                self.emptyLabel.text = error.localizedDescription
                self.tableView.reloadData()
            case .success(let list):
                self.attempts = list
                self.emptyLabel.text = "No one has attempted this challenge yet."
                self.emptyLabel.isHidden = !list.isEmpty
                self.tableView.reloadData()
                print("[CreatorChallenge] detail attempts count=\(list.count)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attempts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AttemptRow")
        let attempt = attempts[indexPath.row]
        let name = attempt.playerName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "Player"
        let score = attempt.score ?? 0
        let total = attempt.totalQuestions ?? 0
        let pct = attempt.percentage.map { Int($0.rounded()) } ?? 0
        let email = attempt.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        cell.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.06) : .white
        cell.selectionStyle = .none
        cell.textLabel?.textColor = isNight ? .white : .black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.textLabel?.text = name
        cell.detailTextLabel?.textColor = isNight ? UIColor.white.withAlphaComponent(0.65) : .darkGray
        cell.detailTextLabel?.numberOfLines = 2
        if email.isEmpty {
            cell.detailTextLabel?.text = "Score \(score)/\(total) · \(pct)%"
        } else {
            cell.detailTextLabel?.text = "\(email)\nScore \(score)/\(total) · \(pct)%"
        }
        return cell
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
