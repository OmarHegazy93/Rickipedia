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
    let viewModel: CharacterListVM
    private var cancellables = Set<AnyCancellable>()
    private let filterCollectionList = Status.allCases.map(\.rawValue.capitalized)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: CharacterListVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let filtersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let charactersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "Characters"
        setupCollectionView()
        setupTableView()
        setupLayout()
        bindViewModel()
        Task { @MainActor in
            await viewModel.fetchCharacters()
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(filtersCollectionView)
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        filtersCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
    }
    
    private func setupTableView() {
        view.addSubview(charactersTableView)
        charactersTableView.dataSource = self
        charactersTableView.delegate = self
        charactersTableView.isHidden = true
        charactersTableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "CharacterCell")
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // CollectionView constraints
            filtersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filtersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            // TableView constraints
            charactersTableView.topAnchor.constraint(equalTo: filtersCollectionView.bottomAnchor, constant: 10),
            charactersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            charactersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            charactersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.charactersTableView.tableFooterView = nil
                }
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
            Task { @MainActor in
                await self?.viewModel.fetchCharacters()
            }
        }
        let hostingController = UIHostingController(rootView: errorView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        charactersTableView.isHidden = true
    }
    
    private func showTableView() {
        children
            .filter { $0 is UIHostingController<ErrorView> }
            .forEach {
                $0.view.removeFromSuperview()
                $0.removeFromParent()
            }
        
        charactersTableView.isHidden = false
    }
    
    private func animateTableViewChanges() {
        showTableView()
        charactersTableView.reloadData()
        UIView.animate(withDuration: 0.3, animations: {
            self.charactersTableView.alpha = 0.0
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.charactersTableView.alpha = 1.0
            }
        }
    }
    
    private func addLoadingIndicator() {
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.startAnimating()
        loadingIndicator.frame = CGRect(x: 0, y: 0, width: charactersTableView.bounds.width, height: 50)
        charactersTableView.tableFooterView = loadingIndicator
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
        guard !viewModel.isLoading else { return false }
        
        let item = collectionView.cellForItem(at: indexPath)
        if item?.isSelected ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
            DispatchQueue.main.async {
                self.viewModel.removeFilter()
            }
            return false
        }
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        let selectedFilterStr = filterCollectionList[indexPath.row]
        if let selectedFilter = Status.allCases.first(where: { $0.rawValue.capitalized == selectedFilterStr }) {
            DispatchQueue.main.async {
                self.viewModel.filter(by: selectedFilter)
            }
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
        cell.selectionStyle = .none
        cell.configure(
            imageURL: URL(string: character.image),
            name: character.name,
            species: character.species
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.showCharacter(at: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.size.height
        
        // Check if the user has scrolled near the bottom
        if position > contentHeight - tableViewHeight - 100 {
            if !viewModel.isLoading && viewModel.hasMoreData {
                addLoadingIndicator()
                Task { @MainActor in
                    await viewModel.fetchCharacters()
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == charactersTableView {
            filtersCollectionView.isUserInteractionEnabled = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == charactersTableView {
            filtersCollectionView.isUserInteractionEnabled = true
        }
    }
}
