//
//  ViewController.swift
//  appFarmaNobleza
//
//  Created by DARK NOISE on 23/06/21.
//

import UIKit
import FirebaseFirestore
import Alamofire
import AlamofireImage
import SwiftyJSON
import FirebaseAuth

private var productoList : [productoModel] = []
private var productoListCarrito : [productoModel] = []
private let db = Firestore.firestore()
let df = DateFormatter()

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getPro()
        
    }
    
    func getPro(){
        DispatchQueue.main.async {
        let url = "https://private-52d58-farmanobleza.apiary-mock.com/productos"
        AF.request(url).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                let data = json["data"]
                data["products"].array?.forEach({ (products) in
                    let producto = productoModel(id: products["id"].stringValue, name: products["name"].stringValue, desc: products["desc"].stringValue, stock: products["stock"].int32Value, precio: products["precio"].doubleValue, imagen: products["imagen"].stringValue)
                    productoList.append(producto)
                    self.tableView.reloadData()
                })
            case .failure(let error):
                print("Ocurrio un error: \(error)")
            }
        }
        }
    }

}

extension ViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellTableViewCell
        cell.nombreP.text = productoList[indexPath.row].name
        cell.descP.text?.append(productoList[indexPath.row].desc)
        cell.precioP.text?.append(String(productoList[indexPath.row].precio))
        let urlImage = productoList[indexPath.row].imagen
        
        AF.request(urlImage).responseImage { (response) in
            DispatchQueue.main.async {
                cell.imagenp.image = try! response.result.get()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var myIndex = indexPath.row
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = UIAlertController(title: "Añadir", message: "Deseas añadir este producto a tu carrito?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Si", style: .default, handler: { (action : UIAlertAction) in
            let alertNew = UIAlertController(title: "Cantidad", message: "Cuantos \(productoList[myIndex].name) desea agregar?", preferredStyle: .alert)
            alertNew.addTextField(configurationHandler: nil)
            alertNew.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (action: UIAlertAction) in
                let defaults = UserDefaults.standard
                let cantidad = alertNew.textFields?.first?.text!
                db.collection("carrito").document(defaults.value(forKey: "email") as! String).collection("productos").document(productoList[myIndex].id).setData([
                    "precio" :  productoList[myIndex].precio,
                    "nombre": productoList[myIndex].name,
                    "cantidad": cantidad!,
                    "imagen": productoList[myIndex].imagen
                ])
            }))
            self.present(alertNew, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
     
    
}
//=================================================================

class CarViewController: UIViewController {

    @IBOutlet weak var tableCarrito: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        godata()
    }

    func godata(){
        DispatchQueue.main.async {
            let defaults = UserDefaults.standard
           db.collection("carrito").document(defaults.value(forKey: "email") as! String).collection("productos").getDocuments { (query, error) in
                if error == nil{
                    for pro in query!.documents {
                        let model : productoModel = productoModel(id: pro.documentID, name: pro.value(forKey: "nombre") as! String, desc: "", stock: 0, precio: Double(pro.value(forKey: "precio") as! String)!, imagen: pro.value(forKey: "imagen") as! String)
                        productoListCarrito.append(model)
                    }
                }
            }
            print(productoListCarrito)
        }
    }

}

extension CarViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productoListCarrito.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellcar", for: indexPath) as! CarritoCellTableViewCell
        return cell
    }
    
    
    
    
}


//==================================================================

class OrdersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

//=====================================================================

class ProfileViewController: UIViewController {
    
    private var email : String = ""
    
        
    
    @IBOutlet weak var loginStackViewProfile: UIStackView!
    @IBOutlet weak var actionsDataStackViewProfile: UIStackView!
    @IBOutlet weak var dataStackViewProfile: UIStackView!
    @IBOutlet weak var nameProfileTextField: UITextField!
    @IBOutlet weak var lastnameProfileTextField: UITextField!
    @IBOutlet weak var addressProfileTextField: UITextField!
    @IBOutlet weak var cellphoneProfileTextField: UITextField!
    @IBOutlet weak var emailProfileTextField: UITextField!
    @IBOutlet weak var permiteUpdateButton: UIButton!
    @IBOutlet weak var saveDataProfileButton: UIButton!
    @IBOutlet weak var loginButtonProfile: UIButton!
    @IBOutlet weak var signUpProfileButtton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String{
            self.email = email
            loginStackViewProfile.isHidden=true
            saveDataProfileButton.isHidden = true
            llenaDatos()
            
        }else {
            dataStackViewProfile.isHidden=true
            actionsDataStackViewProfile.isHidden = true
        }
        
    }
    
    @IBAction func permiteUpdateButtonAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Actualizar datos", message: "Esta seguro de actualizar sus datos?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Aceptar", style: .default) { (action : UIAlertAction) in
            self.nameProfileTextField.isEnabled = true
            self.lastnameProfileTextField.isEnabled = true
            self.addressProfileTextField.isEnabled=true
            self.cellphoneProfileTextField.isEnabled=true
            self.permiteUpdateButton.isHidden=true
            self.saveDataProfileButton.isHidden=false
            self.nameProfileTextField.becomeFirstResponder()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (action: UIAlertAction) in
            
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveDataProfileButtonAction(_ sender: Any) {
        
        if let nombre = nameProfileTextField.text,let ape = lastnameProfileTextField.text, let  cell = cellphoneProfileTextField.text, let dir = addressProfileTextField.text {
                    db.collection("users").document(email).setData([
                    "name" : nombre,
                    "last_name": ape,
                    "cell": cell,
                    "address": dir ])
            llenaDatos()
            self.nameProfileTextField.isEnabled = false
            self.lastnameProfileTextField.isEnabled = false
            self.addressProfileTextField.isEnabled = false
            self.cellphoneProfileTextField.isEnabled = false
            self.permiteUpdateButton.isHidden = false
            self.saveDataProfileButton.isHidden = true
            self.permiteUpdateButton.isHidden = false
                    let alert = UIAlertController(title: "Actualizacion Exitosa", message: "Se ha actualizado su cuenta.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func loginProfileButtonAction(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Ingresar", message: "Ingrese su email", preferredStyle: .alert)
        
        let siguiente = UIAlertAction(title: "Continuar", style: .default) { (action: UIAlertAction) in
            
            let tF = alert.textFields!.first
            let email = tF!.text!
            
            let loguinAlert = UIAlertController(title: "Ingresar", message: "Ingrese su Contraseña", preferredStyle: .alert)
            
            let iniciar = UIAlertAction(title: "Ingresar", style: .default) { (ingresar : UIAlertAction) in
                
                let textPas = loguinAlert.textFields!.first
                let pass = textPas!.text!
                
                Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
                    
                    if let result = result , error == nil{
                        
                        self.loginStackViewProfile.isHidden=true
                        self.dataStackViewProfile.isHidden=false
                        self.actionsDataStackViewProfile.isHidden = false
                        self.saveDataProfileButton.isHidden = true
                        let userD = UserDefaults.standard
                        userD.setValue(result.user.email, forKey: "email")
                        userD.synchronize()
                        self.llenaDatos()
                        let alertController = UIAlertController(title: "Bienvenido!", message: "Recuerda que tenemos promociones exclusivas para ti!", preferredStyle: .alert)
                                            
                        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                                            
                        self.present(alertController, animated: true, completion: nil)
                        
                    }else{
                    
                        let alertController = UIAlertController(title: "Atención", message: "Verifique los datos ingresados", preferredStyle: .alert)
                                            
                        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                                            
                        self.present(alertController, animated: true, completion: nil)                        
                    }
                }
                
            }
            let cancelPassAction = UIAlertAction(title: "Cancelar", style: .cancel) { (action: UIAlertAction) in }
            loguinAlert.addTextField { (textField : UITextField) in textField.placeholder = "Ingrese su Contraseña"
                textField.isSecureTextEntry = true
            }
            loguinAlert.addAction(iniciar)
            loguinAlert.addAction(cancelPassAction)
            self.present(loguinAlert, animated: true, completion: nil)
            
        }
        
        let cancelEmailAction = UIAlertAction(title: "Cancelar", style: .cancel) { (action: UIAlertAction) in }
        
        alert.addTextField { (textField : UITextField) in
            textField.placeholder = "Ingrese su Email"
            textField.textContentType = .emailAddress
        }
        alert.addAction(siguiente)
        alert.addAction(cancelEmailAction)
        present(alert, animated: true,completion: nil)
        
    }
    
    func deleteUserDefaults (){
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "email")
            defaults.synchronize()
        }
    
    @IBAction func logoutProfileButtonAction(_ sender: Any) {
        
        deleteUserDefaults()
        do {
            try Auth.auth().signOut()
            dataStackViewProfile.isHidden=true
            actionsDataStackViewProfile.isHidden = true
            loginStackViewProfile.isHidden=false
            
        } catch  {
            // Se ha producido un error
            let alertController = UIAlertController(title: "Error", message: "Se ha producido un error al cerrar su sesión, vuelva a intentarlo en unos momentos", preferredStyle: .alert)
                                
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                                
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func llenaDatos(){
        
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String{
            
            db.collection("users").document(email).getDocument { documentSnapshot, error in
                if let document = documentSnapshot, error == nil{
                 
                    self.emailProfileTextField.text = email
                    
                    if let name = document.get("name") as? String {
                        self.nameProfileTextField.text = name
                    } else { self.nameProfileTextField.text = "" }
                    
                    if let lastname = document.get("last_name") as? String {
                        self.lastnameProfileTextField.text = lastname
                    } else { self.lastnameProfileTextField.text = "" }
                    
                    if let address = document.get("address") as? String {
                        self.addressProfileTextField.text = address
                    } else { self.addressProfileTextField.text = "" }
                    
                    if let cellphone = document.get("cell") as? String {
                        self.cellphoneProfileTextField.text = cellphone
                    } else { self.cellphoneProfileTextField.text = "" }
                }
            }
            
        }
        
        
        
    }
    @IBAction func signUpProfileButtonAction(_ sender: Any) {
        
        navigationController?.pushViewController(RegisterViewController(), animated: true)
        
    }
    
}
