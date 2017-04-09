//
//  ViewController.swift
//  Notes
//
//  Created by Nauroo on 08/04/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var noteDicts = Array<NoteMO>()
    var searchResults = Array<NoteMO>()
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    var inSearch = false

    @IBOutlet weak var noteList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        noteList.delegate = self
        noteList.dataSource = self
        noteList.separatorStyle = .none
        let modelFetch = NoteMO.modelFetchRequest()
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        modelFetch.sortDescriptors = [sortDescriptor]
        do {
            let models = try context?.fetch(modelFetch)
            noteDicts = models!
            noteList.reloadData()
        }catch{
            let alertVC = UIAlertController.init(title: "Couldn't save", message: "Saving unsuccessful, Try Again!!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
        configureSearchController()
        
    }
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        noteList.tableHeaderView = searchController.searchBar
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        noteList.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults{
            shouldShowSearchResults = true
            noteList.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
        //shouldShowSearchResults = false
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        let resultPredicate = NSPredicate(format: "self.tag contains[c] %@", searchString!)
        searchResults = noteDicts.filter({resultPredicate.evaluate(with: $0)})
        if(searchResults.count > 0){
            shouldShowSearchResults = true
        }
        print(searchResults.count)
        noteList.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults{
            return searchResults.count
        }
        return noteDicts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var noteDictArray = noteDicts
        if shouldShowSearchResults{
            noteDictArray = searchResults
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        cell.tagLabel.text = noteDictArray[indexPath.row].tag
        let updatedDate = (noteDictArray[indexPath.row].updatedAt! as NSDate).ToLocalStringWithFormat(dateFormat: "EEE, MMM d, yyyy - h:mm a")
        cell.updatedAt.text = String(describing: updatedDate)
        
        if indexPath.row == noteDictArray.count-1{
            if shouldShowSearchResults{
                shouldShowSearchResults = false
                inSearch = true
            }else{
            inSearch = false
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var noteDictArray = noteDicts
        if inSearch{
            noteDictArray = searchResults
            searchBarCancelButtonClicked(searchController.searchBar)
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
        vc.noteDict["tag"] = noteDictArray[indexPath.row].tag
        vc.noteDict["detail"] = noteDictArray[indexPath.row].detail
        vc.noteDict["updatedAt"] = noteDictArray[indexPath.row].updatedAt
        vc.noteDict["new"] = false

        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: {(action: UITableViewRowAction, indexPath: IndexPath) in
            let modelFetch = NoteMO.modelFetchRequest()
            let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            modelFetch.predicate = NSPredicate(format: "updatedAt = %@", self.noteDicts[indexPath.row].updatedAt as! CVarArg)
            do {
                let models = try context?.fetch(modelFetch)
                if((models?.count)! > 0){
                    context?.delete((models?[0])!)
                    do{
                        try context?.save()
                        self.noteDicts.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .right)
                    }catch{
                        DispatchQueue.main.async {
                            let alertVC = UIAlertController.init(title: "Couldn't save", message: "Saving unsuccessful, Try Again!!", preferredStyle: .alert)
                            alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                            self.present(alertVC, animated: true, completion: nil)
                        }
                        
                    }
                }

            }catch{
                let alertVC = UIAlertController.init(title: "Couldn't save", message: "Saving unsuccessful, Try Again!!", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
            }

            
        })
        delete.backgroundColor = UIColor.red
        return[delete]
    }
    

    
    @IBAction func addNew(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension NSDate {
    func ToLocalStringWithFormat(dateFormat: String) -> String {
        // change to a readable time format and change to local time zone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone.local
        let timeStamp = dateFormatter.string(from: self as Date)
        
        return timeStamp
    }
}













