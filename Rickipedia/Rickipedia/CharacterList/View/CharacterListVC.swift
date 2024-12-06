//
//  CharacterListVC.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 03/12/2024.
//

import UIKit
import Combine
import SwiftUI

final class CharacterListVC: UIViewController {
    private let viewModel = CharacterListVM()
    private var cancellables = Set<AnyCancellable>()
    private let filterCollectionList = Status.allCases.map(\.rawValue.capitalized)
    
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.isHidden = true
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "Characters"
        setupProgressView()
        setupCollectionView()
        setupTableView()
        setupLayout()
        bindViewModel()
        viewModel.fetchCharacters()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "CharacterCell")
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // CollectionView constraints
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 50),
            
            // TableView constraints
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupProgressView() {
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.progressView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.showErrorView(message: errorMessage.localizedDescription)
            }
            .store(in: &cancellables)
        
        viewModel.$characters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newItems in
                self?.animateTableViewChanges()
            }
            .store(in: &cancellables)
    }
    
    private func showErrorView(message: String) {
        let errorView = ErrorView(message: message) { [weak self] in
            self?.viewModel.fetchCharacters()
        }
        let hostingController = UIHostingController(rootView: errorView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        tableView.isHidden = true
    }
    
    private func showTableView() {
        children
            .filter { $0 is UIHostingController<ErrorView> }
            .forEach {
                $0.view.removeFromSuperview()
                $0.removeFromParent()
            }
        
        tableView.isHidden = false
    }
    
    private func animateTableViewChanges() {
        UIView.animate(withDuration: 0.5) {
            self.showTableView()
            self.tableView.reloadData()
        }
    }
}

// - MARK: CollectionView Data Source and Delegate
extension CharacterListVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterCollectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! FilterCollectionViewCell
        cell.configure(with: filterCollectionList[indexPath.row])
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let text = filterCollectionList[indexPath.row]
        let size = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
        return CGSize(width: size.width + 20, height: 40)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = collectionView.cellForItem(at: indexPath)
        if item?.isSelected ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
            viewModel.removeFilter()
            return false
        }
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        let selectedFilterStr = filterCollectionList[indexPath.row]
        if let selectedFilter = Status.allCases.first(where: { $0.rawValue.capitalized == selectedFilterStr }) {
            viewModel.filter(by: selectedFilter)
        }
        return true
    }
}

// - MARK: TableView Data Source and Delegate
extension CharacterListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterTableViewCell
        
        let character = viewModel.characters[indexPath.row]
        
        cell.configure(
            image: UIImage(systemName: "person.fill") ?? UIImage(),
            name: character.name,
            species: character.species
        )
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("✅✅✅✅ Selected row \(indexPath.row + 1)")
    }
}
