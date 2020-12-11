//
//  ToDoListViewController.swift
//  Todoey-CoreData
//
//  Created by Dayton on 11/12/20.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    //the value of category that was pressed
    var selectedCategory: Category? {
        didSet{
            // everything inside the didSet is going to happen as soon as selectedCategory get set with a value
            loadItems()
            
        }
    }
    
    // have access to appDelegate as an object and able to tap into its property
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         //accessing to the app file directory,
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
       
    }
    
    
    //MARK: - TableViewDataSource
    
    //how many row you want to display on the tableview and it will execute cellForRowAt function as many as this func
    // value that is returned.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ofcourse all of them
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        
        // Ternary: set cell accessory type depending on the item.done is true
        //if it's true set to checkmark and if it is not set it to none
        cell.accessoryType = item.done ? .checkmark : .none
        
      
        return cell
    
    }
    
    //MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //MARK:Update Core Data
        
//        a method to update your NSManagedObject by getting to the object at selected array,
//        setting the value of the object property to a custom value.
//        basically getting the selected row to change its title property value to "completed"
//       itemArray[indexPath.row].setValue("completed", forKey: "title")
        
        //MARK: DELETE Core Data
        
        /*you need to remove the NSManagedObject from the context first before we try to remove it on itemArray
         because we are using itemArray to try to grab the object.*/
        
        //removing the data from the context
//        context.delete(itemArray[indexPath.row])
        //it does nothing on core data and it need to update the itemArray to repopulate the tableview.
//        itemArray.remove(at: indexPath.row)
        
        
        //to add a checkmark accessory type and to remove the checkmark on second selection
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //to only reload to row that gets selected
        //tableView.reloadRows(at: [indexPath], with: .automatic)
        
        saveItem()
        
        //to disable hightlighting when selecting a row
               tableView.deselectRow(at: indexPath, animated: true)
        
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
            var textField = UITextField()
            
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // what will happen when user click user click add button
            
            // creating a new Item object temporarily inside the specified context
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            //parentCategory is the property of Item itself and not Category
            //the code is saying to set the newItem's parentCategory to be equal to the value of category that was selected before.
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItem()
            
        }
        
        
        alert.addTextField { (alertTextField) in
            
            //storing the temporary variable into a local variable to be displayed later
            textField = alertTextField
            
            alertTextField.placeholder = "Create new item"
            
            
           
        }
        
         alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: Model Manipulation Method
    
    func saveItem(){
        do{
            // saving the context. To commit unsaved changes to the persistent store.
            try context.save()
        }catch{
          print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
                    //adding a default value so when the func called without any input parameter,
                    // it immediately use the default value
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil){
                    //giving a datatype to the output.
        
        //the item's parent category need to match the parent category that is selected
        //this predicate is crucial for all kind of requests
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //checking whether there is any additional predicate to be considered on
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            
        }//if there is no additional predicate, proceed through with just the category predicate filter
        else{
            request.predicate = categoryPredicate
        }

        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}


//MARK: - Search bar method
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        // to query using core data we need to use NSPredicate
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //when we hit the X button to empty the search bar after we searched for data once.
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                //getting the search bar dismissed. Removing the keyboard and cursor on search bar.
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
