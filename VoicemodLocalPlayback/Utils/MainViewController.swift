//
//  ViewController.swift
//  VoicemodLocalPlayback
//
//  Created by Banto Balazs on 11/06/2024.
//

import SwitchboardSDK
import UIKit

class MainViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Bundle.main.executableURL!.lastPathComponent

        ExampleProvider.initialize()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExampleCell")
    }

    func example(for indexPath: IndexPath) -> Example {
        if let groups = ExampleProvider.exampleGroups {
            return groups[indexPath.section].examples[indexPath.row]
        } else {
            return ExampleProvider.examples![indexPath.row]
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        ExampleProvider.exampleGroups?.count ?? 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groups = ExampleProvider.exampleGroups {
            return groups[section].examples.count
        } else {
            return ExampleProvider.examples?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let example = example(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath)
        cell.textLabel?.text = example.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let groups = ExampleProvider.exampleGroups {
            return groups[section].title
        } else {
            return nil
        }
    }

    // MARK: - Table view delegate

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = example(for: indexPath)
        let viewController = example.viewController.init()
        viewController.title = example.title
        navigationController?.pushViewController(viewController, animated: true)
    }
}

