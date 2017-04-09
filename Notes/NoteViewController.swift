//
//  NoteViewController.swift
//  Notes
//
//  Created by Nauroo on 09/04/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var detail: UITextView!
    @IBOutlet weak var titleTF: UITextField!

    var noteDict = ["tag": "", "detail": "", "updatedAt": Date(), "new": true] as [String : Any]
    //var noteMO: NoteMO?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        titleTF.delegate = self
        titleTF.layer.borderColor = UIColor.clear.cgColor
        detail.delegate = self
        deleteButton.isEnabled = false
        
        if(noteDict["new"] as! Bool == false){
            titleTF.text = noteDict["tag"] as! String?
            detail.text = noteDict["detail"] as! String!
            deleteButton.isEnabled = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.text != "" || textField.text != noteDict["tag"] as? String){
            saveNote()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text != "" || textView.text != noteDict["detail"] as? String){
            saveNote()
        }
    }
    func saveNote() {
        var titleText = titleTF.text
        let updateDate = Date()
        if titleTF.text == ""{
            titleText = "Untitled\(updateDate)"
        }
        
            let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
                let noteDictPrevious = noteDict
                noteDict["tag"] = titleText
                noteDict["detail"] = detail.text
                noteDict["updatedAt"] = updateDate as NSDate?
                DispatchQueue.global(qos: .default).async {
                    let modelFetch = NoteMO.modelFetchRequest()
                    if let queryDate = noteDictPrevious["updatedAt"] as? NSDate{
                        modelFetch.predicate = NSPredicate(format: "updatedAt = %@", queryDate as CVarArg)
                    }else{
                        modelFetch.predicate = NSPredicate(format: "updatedAt = %@", updateDate as CVarArg)
                    }
                    
                    do{
                        let models = try context?.fetch(modelFetch)
                        if (models?.count)! > 0{
                            let queryTobeSaved = (models?[0])!
                            queryTobeSaved.tag = self.noteDict["tag"] as! String?
                            queryTobeSaved.detail = self.noteDict["detail"] as! String?
                            queryTobeSaved.updatedAt = self.noteDict["updatedAt"] as! NSDate?
                         
                        }else{
                            let queryTobeSaved = NoteMO(context: context!)
                            queryTobeSaved.tag = self.noteDict["tag"] as! String?
                            queryTobeSaved.detail = self.noteDict["detail"] as! String?
                            queryTobeSaved.updatedAt = self.noteDict["updatedAt"] as! NSDate?                        }
                        do{
                            try context?.save()
                            self.noteDict["new"] = false
                            DispatchQueue.main.async {
                                self.viewWillAppear(false)
                            }
                        }catch{
                            self.noteDict = noteDictPrevious
                            DispatchQueue.main.async {
                                let alertVC = UIAlertController.init(title: "Couldn't save", message: "Saving unsuccessful, Try Again!!", preferredStyle: .alert)
                                alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                self.present(alertVC, animated: true, completion: nil)
                            }
                        }
                    }catch{
                        self.noteDict = noteDictPrevious
                        DispatchQueue.main.async {
                            let alertVC = UIAlertController.init(title: "Couldn't save", message: "Saving unsuccessful, Try Again!!", preferredStyle: .alert)
                            alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                            self.present(alertVC, animated: true, completion: nil)
                        }
                        
                    }
                }

    }
    

    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        DispatchQueue.global(qos: .default).async {
            let modelFetch = NoteMO.modelFetchRequest()
            
            modelFetch.predicate = NSPredicate(format: "updatedAt = %@", self.noteDict["updatedAt"] as! CVarArg)
            let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

            do{
                let models = try context?.fetch(modelFetch)
                if((models?.count)! > 0){
                    context?.delete((models?[0])!)
                    do{
                        try context?.save()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }catch{
                        DispatchQueue.main.async {
                            let alertVC = UIAlertController.init(title: "Couldn't save", message: "Saving unsuccessful, Try Again!!", preferredStyle: .alert)
                            alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                            self.present(alertVC, animated: true, completion: nil)
                        }

                    }
                }
            }catch{
                DispatchQueue.main.async {
                    let alertVC = UIAlertController.init(title: "Couldn't save", message: "Saving unsuccessful, Try Again!!", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
}





















