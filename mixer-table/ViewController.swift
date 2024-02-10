//
//  ViewController.swift
//  mixer-table
//
//  Created by Alexander Zhuchkov on 10.02.2024.
//

import UIKit

/**
 На весь экран таблица, в таблице минимум 30 ячеек.

 - По нажатию на ячейку она анимировано перемещается на первое место, а справа появляется галочка.
 - Если нажать на ячейку с галочкой, то галочка пропадает.
 - Справа вверху кнопка анимировано перемешивает ячейки.
 */

struct Item: Identifiable, CustomStringConvertible {
    let id: Int
    var isChecked: Bool = false
    
    var description: String {
        return "\(id)"
    }
}

class ViewController: UIViewController {

    // MARK: - Properties
    lazy var items: [Item] = {
        return (0...30).map { Item.init(id: $0) }
    }()
    
    // !!!!!!!!!!!!!!
    // Тут важно, что в DataSource мы должны хранить не сами Item, а их идентификаторы
    // Это описано в официальном гайде от Apple
    // https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/updating_collection_views_using_diffable_data_sources
    //
    // !!!!!!!!!!!!!!
    lazy var dataSource = UITableViewDiffableDataSource<String, Item.ID>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        
        // Dequeqe Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure Cell with Item
        if let item = self?.items.first(where: { $0.id == itemIdentifier }) {
            cell.textLabel?.text = "\(item)"
            cell.accessoryType = item.isChecked ? .checkmark : .none
        }
        
        return cell
    }
    
    // MARK: - Subviews
    private lazy var tableView: UITableView = {
        // Initialize
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //
        return tableView
    }()

    // MARK: - Methods
    private func updateSnapshot(updatedIdentifiers: [Item.ID] = []) {
         
        let itemIds = items.map { $0.id }
        
        var snapshot = NSDiffableDataSourceSnapshot<String, Item.ID>()
        snapshot.appendSections([""])
        snapshot.appendItems(itemIds)
        snapshot.reconfigureItems(updatedIdentifiers)
        
        dataSource.apply(snapshot)
    }
    
    
    private func setupView() {
        view.addSubview(tableView)
        
        title = "Task 4"
        navigationItem.rightBarButtonItem = .init(title: "Shuffle", image: nil, primaryAction: .init(handler: { [weak self] _ in
            self?.items.shuffle()
            self?.updateSnapshot()
        }))
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Item index
        let index = indexPath.row
        let itemId = items[index].id
        
        // Toggle
        items[index].isChecked.toggle()
        
        // Move to top if needed
        if items[index].isChecked {
            let item = items.remove(at: index)
            items.insert(item, at: 0)
        }
        
        // Update
        updateSnapshot(updatedIdentifiers: [itemId])
    }
}

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupView()
        updateSnapshot()
    }
    

}

