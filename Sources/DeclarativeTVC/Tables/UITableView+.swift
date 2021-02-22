//
//  UITableView+.swift
//  Framework
//
//  Created by Dmitry Kocherovets on 09.02.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import UIKit

protocol Table: class {
    var model: TableModel? { get }
    var registeredCells: [String] { get set }
    var registeredHeadersAndFooters: [String] { get set }
    var tableView: UITableView! { get }
}

extension Table {
    func cell(for indexPath: IndexPath) -> UITableViewCell {
        guard let vm = model?.sections[indexPath.section].rows[indexPath.row] else { return UITableViewCell() }

        let cellTypeString = String(describing: type(of: vm).cellAnyType)

        switch vm.cellType() {
        case .storyboard:
            break
        case .xib:
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                let nib = UINib(nibName: cellTypeString, bundle: Bundle(for: type(of: vm).cellAnyType))
                tableView.register(nib, forCellReuseIdentifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
        case .code:
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                vm.register(tableView: tableView, identifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellTypeString, for: indexPath)

        vm.apply(to: cell)

        return cell
    }

    func header(for section: Int) -> UIView? {
        if let vm = model?.sections[section].header, !(vm is TitleWithoutViewTableHeaderModel) {
            let typeString = String(describing: type(of: vm).headerAnyType)

            switch vm.cellType() {
            case .storyboard:
                let header = tableView.dequeueReusableCell(withIdentifier: typeString)!
                vm.apply(to: header)
                return header.contentView
            case .xib:
                if registeredHeadersAndFooters.firstIndex(where: { $0 == typeString }) == nil {
                    let nib = UINib(nibName: typeString, bundle: Bundle(for: type(of: vm).headerAnyType))
                    tableView.register(nib, forHeaderFooterViewReuseIdentifier: typeString)
                    registeredHeadersAndFooters.append(typeString)
                }
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: typeString)!
                vm.apply(to: header)
                return header
            case .code:
                if registeredHeadersAndFooters.firstIndex(where: { $0 == typeString }) == nil {
                    vm.register(tableView: tableView, identifier: typeString)
                    registeredHeadersAndFooters.append(typeString)
                }
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: typeString)!
                vm.apply(to: header)
                return header
            }
        }
        return nil
    }

    func headerTitle(for section: Int) -> String? {
        (model?.sections[section].header as? TitleWithoutViewTableHeaderModel)?.title
    }

    func footer(for section: Int) -> UIView? {
        if let vm = model?.sections[section].footer, !(vm is TitleWithoutViewTableFooterModel) {
            let typeString = String(describing: type(of: vm).footerAnyType)

            switch vm.cellType() {
            case .storyboard:
                let footer = tableView.dequeueReusableCell(withIdentifier: typeString)!
                vm.apply(to: footer)
                return footer.contentView
            case .xib:
                if registeredCells.firstIndex(where: { $0 == typeString }) == nil {
                    let nib = UINib(nibName: typeString, bundle: Bundle(for: type(of: vm).footerAnyType))
                    tableView.register(nib, forHeaderFooterViewReuseIdentifier: typeString)
                    registeredCells.append(typeString)
                }
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: typeString)!
                vm.apply(to: footer)
                return footer
            case .code:
                if registeredCells.firstIndex(where: { $0 == typeString }) == nil {
                    vm.register(tableView: tableView, identifier: typeString)
                    registeredCells.append(typeString)
                }
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: typeString)!
                vm.apply(to: footer)
                return footer
            }
        }
        return nil
    }

    func footerTitle(for section: Int) -> String? {
        (model?.sections[section].footer as? TitleWithoutViewTableFooterModel)?.title
    }

    func heightForCell(at indexPath: IndexPath, tableFrame: CGRect) -> CGFloat {
        if let height = model?.sections[indexPath.section].rows[indexPath.row].height(tableFrame: tableFrame) {
            return height
        }
        return UITableView.automaticDimension
    }

    func heightForHeader(inSection section: Int, tableFrame: CGRect) -> CGFloat {
        guard let header = model?.sections[section].header else {
            return 0
        }
        return header.height(tableFrame: tableFrame) ?? UITableView.automaticDimension
    }

    func heightForFooter(inSection section: Int, tableFrame: CGRect) -> CGFloat {
        guard let footer = model?.sections[section].footer else {
            return 0
        }
        return footer.height(tableFrame: tableFrame) ?? UITableView.automaticDimension
    }
}
