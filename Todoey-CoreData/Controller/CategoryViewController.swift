//
//  ViewController.swift
//  Todoey-CoreData
//
//  Created by Dayton on 11/12/20.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    
    // have access to appDelegate as an object and able to tap into its property
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        print(categories.count)
        
       
        
    }
    
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ofcourse all of them
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
           performSegue(withIdentifier: "goToItems", sender: self)
       }
       
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "goToItems" {
               let destinationVC = segue.destination as! TodoListViewController
            
            
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categories[indexPath.row]
            }
            
            
            
            
            
           }
       }
    
    
    //MARK: - Data Manipulation Methods
    func saveCategories(){
        do{
            // saving the context. To commit unsaved changes to the persistent store.
            try context.save()
        }catch{
            print("Error saving Category \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //adding a default value so when the func called without any input parameter,
    // it immediately use the default value
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        //giving a datatype to the output.
        
        do{
            categories = try context.fetch(request)
        }catch{
            print("Error fetching data from Category \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // what will happen when user click user click add button
            
            // creating a new Item object temporarily inside the specified context
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addTextField { (alertTextField) in
            
            //storing the temporary variable into a local variable to be displayed later
            textField = alertTextField
            
            alertTextField.placeholder = "Create new Category"
            
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
}


