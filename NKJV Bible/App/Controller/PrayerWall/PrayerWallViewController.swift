//
//  PrayerWallViewController.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift

final class PrayerWallViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var isEmbeddedTab = false

    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool

    private var prayers: [PrayerWallItem] = []
    private var likeCounts: [String: Int] = [:]
    private var commentCounts: [String: Int] = [:]
    private var isLoading = false

    private let bannerView = UIView()
    private let titleLabel = UILabel()
    private let backImageView = UIImageView()
    private let backButton = UIButton(type: .system)
    private let addButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init() {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPrayers(showLoader: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isEmbeddedTab {
            App_Protocol.delegateReader?.hideBottomMenu(Status: true)
        }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isEmbeddedTab && (isMovingFromParent || isBeingDismissed) {
            App_Protocol.delegateReader?.hideBottomMenu(Status: false)
        }
    }

    private func setupUI() {
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.backgroundColor = isNight ? DarkModeColor : themeColor
        view.addSubview(bannerView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Prayer Wall"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        view.addSubview(titleLabel)

        backImageView.translatesAutoresizingMaskIntoConstraints = false
        backImageView.image = UIImage(named: "BackArrow")
        backImageView.contentMode = .scaleAspectFit
        view.addSubview(backImageView)
        ImageTint.sharedInstance.imageTintcolorMethod(img: backImageView, colorVu: .white)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .white
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        view.addSubview(addButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PrayerWallCell.self, forCellReuseIdentifier: PrayerWallCell.reuseId)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        view.addSubview(tableView)

        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No prayers yet.\nTap + to share the first prayer."
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.7) : .darkGray
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = isNight ? .white : themeColor
        view.addSubview(activityIndicator)

        let bannerHeight: CGFloat = StatusbarHeight > 30 ? 90 : 70

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: bannerHeight),

            titleLabel.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -15),

            backImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            backImageView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -15),
            backImageView.widthAnchor.constraint(equalToConstant: 20),
            backImageView.heightAnchor.constraint(equalToConstant: 20),

            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backButton.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 75),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),

            tableView.topAnchor.constraint(equalTo: bannerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        applyEmbeddedTabPresentationIfNeeded()
    }

    private func applyEmbeddedTabPresentationIfNeeded() {
        guard isEmbeddedTab else { return }
        backImageView.isHidden = true
        backButton.isHidden = true
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func addTapped() {
        if !NetworkManager.sharedInstance.isConnectedToInternet() {
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            return
        }
        let vc = CreatePrayerViewController()
        vc.onPrayerCreated = { [weak self] in
            self?.loadPrayers(showLoader: false)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func refreshPulled() {
        loadPrayers(showLoader: false)
    }

    private func loadPrayers(showLoader: Bool) {
        if !NetworkManager.sharedInstance.isConnectedToInternet() {
            refreshControl.endRefreshing()
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            return
        }
        if showLoader {
            activityIndicator.startAnimating()
        }
        isLoading = true

        PrayerWallService.shared.fetchPrayers { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()

            switch result {
            case .success(let items):
                self.prayers = items.filter { !$0.id.isEmpty }
                self.emptyStateLabel.isHidden = !self.prayers.isEmpty
                self.tableView.reloadData()
                self.loadCounts(for: self.prayers)
            case .failure(let error):
                self.view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
            }
        }
    }

    private func loadCounts(for prayers: [PrayerWallItem]) {
        for prayer in prayers {
            PrayerWallService.shared.fetchLikes(prayerId: prayer.id) { [weak self] result in
                guard let self = self else { return }
                if case .success(let response) = result {
                    self.likeCounts[prayer.id] = response.count ?? response.likes?.count ?? 0
                    self.tableView.reloadData()
                }
            }
            PrayerWallService.shared.fetchComments(prayerId: prayer.id) { [weak self] result in
                guard let self = self else { return }
                if case .success(let comments) = result {
                    self.commentCounts[prayer.id] = comments.count
                    self.tableView.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prayers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrayerWallCell.reuseId, for: indexPath) as! PrayerWallCell
        let prayer = prayers[indexPath.row]
        cell.configure(
            prayer: prayer,
            likeCount: likeCounts[prayer.id] ?? 0,
            commentCount: commentCounts[prayer.id] ?? 0,
            isNight: isNight,
            themeColor: themeColor
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = PrayerDetailViewController(prayer: prayers[indexPath.row])
        vc.onUpdated = { [weak self] in
            self?.loadPrayers(showLoader: false)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

private final class PrayerWallCell: UITableViewCell {
    static let reuseId = "PrayerWallCell"

    private let cardView = UIView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let metaLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        contentView.addSubview(cardView)

        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        contentView.addSubview(categoryLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 3
        cardView.addSubview(descriptionLabel)

        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        cardView.addSubview(metaLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            categoryLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            categoryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),

            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            metaLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            metaLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            metaLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            metaLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(prayer: PrayerWallItem, likeCount: Int, commentCount: Int, isNight: Bool, themeColor: UIColor) {
        cardView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        categoryLabel.text = prayer.category.uppercased()
        categoryLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.75) : themeColor
        titleLabel.text = prayer.title
        titleLabel.textColor = isNight ? .white : .black
        descriptionLabel.text = prayer.description
        descriptionLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.85) : .darkGray

        let author = prayer.isAnonymous || prayer.userName.isEmpty ? "Anonymous" : prayer.userName
        metaLabel.text = "\(author)  •  ♥ \(likeCount)  •  💬 \(commentCount)"
        metaLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.6) : .gray
    }
}
