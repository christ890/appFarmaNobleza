//
//  RegisterViewController.swift
//  appFarmaNobleza
//
//  Created by DARK NOISE on 24/06/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    private let db = Firestore.firestore()
    
    @IBOutlet weak var nombreReg: UITextField!
    @IBOutlet weak var apeReg: UITextField!
    @IBOutlet weak var emailReg: UITextField!
    @IBOutlet weak var passReg: UITextField!
    @IBOutlet weak var cellReg: UITextField!
    @IBOutlet weak var dirReg: UITextField!
    @IBOutlet weak var regButton: UIButton!
    @IBOutlet weak var goLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func reg(_ sender: Any) {
        
        if let nombre = nombreReg.text,let ape = apeReg.text,let email = emailReg.text,let pass = passReg.text, let  cell = cellReg.text, let dir = dirReg.text {
            Auth.auth().createUser(withEmail: email, password: pass) { result, error  in
                if error == nil{
                    self.db.collection("users").document(email).setData([
                    "name" : nombre,
                    "last_name": ape,
                    "email" : email,
                    "pass" : pass,
                    "cell": cell,
                    "address": dir ])
                    let alert = UIAlertController(title: "Registro Exitoso", message: "Se ha registrado su cuenta \(email), ingrese desde el login", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (action: UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }else {
                    let alert = UIAlertController(title: "Error", message: "No se pudo procesar su ingreso, intentelo mas tarde", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
                }
            }
        }
        
    }
    
    @IBAction func goLog(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
