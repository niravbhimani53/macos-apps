//
//  ViewController.swift
//  Todo App
//
//  Created by Nirav Bhimani on 1/8/19.
//  Copyright © 2019 HARU. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var todoInputField: NSTextField!
    @IBOutlet weak var importantCheckbox: NSButton!
    @IBOutlet weak var deleteBtn: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var todoItemsArray: [TodoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // When view loads fill the data
        getTodoItemFromCoreData()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // Get data from core data
    func getTodoItemFromCoreData() {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            do {
                todoItemsArray = try context.fetch(TodoItem.fetchRequest())
            } catch {
                print(error)
            }
            
            // Update table with data
            tableView.reloadData()
            
        }
    }
    
    @IBAction func addBtn(_ sender: Any) {
        
        if(!todoInputField.stringValue.isEmpty) {
            
            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                // Create context to CoreData Model
                let todoItem = TodoItem(context: context)
                
                // Store value
                todoItem.item = todoInputField.stringValue
                
                // Check for checkbox value
                if importantCheckbox.state.rawValue != 0 {
                    todoItem.important = true
                } else {
                    todoItem.important = false
                }
                
                // Save action
                (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                
                // Reset Checkbox and Input box
                importantCheckbox.state = NSControl.StateValue.init(0)
                todoInputField.stringValue = ""
                
                getTodoItemFromCoreData()
            }
            
        }
        
    }
    
    // MARK: Table stuff
    
    // Find number of items stored
    func numberOfRows(in tableView: NSTableView) -> Int {
        return todoItemsArray.count
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        
        // To ensure that delete logic works only when item is selected
        if tableView.selectedRow != -1 {
            print(true)
            let itemToBeDeleted = todoItemsArray[tableView.selectedRow]
            
            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                context.delete(itemToBeDeleted)
                
                // Save action
                (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                
                getTodoItemFromCoreData()
                
                // Atlast hide the delete btn again
                deleteBtn.isHidden = true
            }
        }
        
    }
    
    // Display values in columns
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Store data into variable for each row
        let arr = todoItemsArray[row]
        
        // Find the column by identifier and update value accordingly to column
        if tableColumn!.identifier.rawValue == "importantColumn"  {
            
            // Check for cell identifier
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "importantCell"), owner: self) as? NSTableCellView {
                
                if arr.important {
                    cell.textField?.stringValue = "❗️"
                } else {
                    cell.textField?.stringValue = ""
                }
                
                return cell
            }
            
        } else {
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "listCell"), owner: self) as? NSTableCellView {
                
                
                cell.textField?.stringValue = arr.item ?? "Error"
                return cell
            }
            
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        deleteBtn.isHidden = false
    }
    
}

