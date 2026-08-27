//
//  PrayerBlockedUsersViewController.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift

final class PrayerBlockedUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool

    private var blockedIds: [String] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    init() {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blocked Users"
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        setupNavigation()
        setupUI()
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        reload()
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
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BlockedUserCell")
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No blocked users.\nWhen you block someone, they appear here."
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.7) : .darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func reload() {
        blockedIds = PrayerWallService.shared.allBlockedUserIds()
        emptyLabel.isHidden = !blockedIds.isEmpty
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedIds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserCell", for: indexPath)
        let id = blockedIds[indexPath.row]
        let name = PrayerWallService.shared.blockedUserDisplayName(for: id)
        cell.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.06) : .white
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.textColor = isNight ? .white : .black
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

        let unblock = UIButton(type: .system)
        unblock.setTitle("Unblock", for: .normal)
        unblock.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        unblock.setTitleColor(themeColor, for: .normal)
        unblock.tag = indexPath.row
        unblock.addTarget(self, action: #selector(unblockButtonTapped(_:)), for: .touchUpInside)
        unblock.sizeToFit()
        cell.accessoryView = unblock
        return cell
    }

    @objc private func unblockButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        guard blockedIds.indices.contains(row) else { return }
        let id = blockedIds[row]
        confirmUnblock(id)
    }

    private func confirmUnblock(_ id: String) {
        let name = PrayerWallService.shared.blockedUserDisplayName(for: id)
        let alert = UIAlertController(
            title: "Unblock",
            message: "Unblock \(name)? Their prayers will show on Prayer Wall again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Unblock", style: .default, handler: { [weak self] _ in
            self?.performUnblock(id)
        }))
        present(alert, animated: true)
    }

    private func performUnblock(_ id: String) {
        if !NetworkManager.sharedInstance.isConnectedToInternet() {
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            return
        }
        PrayerWallService.shared.unblockUser(blockedUserId: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.view.makeToast("User unblocked", duration: 2.0, position: .bottom)
                self.reload()
            case .failure(let error):
                self.view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
            }
        }
    }
}
