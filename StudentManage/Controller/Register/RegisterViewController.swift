//
//  RegisterViewController.swift
//  StudentManage
//
//  Created by imac-3373 on 2024/3/3.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var txfFirstname: UITextField!
    
    @IBOutlet weak var txfLastname: UITextField!
    
    @IBOutlet weak var txfEmail: UITextField!
    
    @IBOutlet weak var txfPassword: UITextField!
    
    @IBOutlet weak var btnRegist: UIButton!
    
    @IBOutlet weak var tbvAuth: UITableView!
    
    
    // MARK: - Variables
    
    var btnAuthenticate: UIBarButtonItem?
    
    var firstName: String = ""
    
    var lastName: String = ""

    var email: String = ""
    
    var password: String = ""
    
    var placeHolders: [String] = ["email", "password"]
    
    var users: [User]?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        
        txfFirstname.tag = 1
        txfLastname.tag = 2
        txfEmail.tag = 3
        txfPassword.tag = 4
        
        tbvAuth.delegate = self
        tbvAuth.dataSource = self
        
        tbvAuth.register(UINib(nibName: AuthCell.identifier, bundle: nil), forCellReuseIdentifier: AuthCell.identifier)
    }
    
    func setupNavigation() {
        
        navigationController?.navigationBar.barTintColor = .systemTeal
        btnAuthenticate = UIBarButtonItem(title: "登入", style: .done, 
                                          target: self, action: #selector(login))
        navigationItem.rightBarButtonItem = btnAuthenticate
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        title = "註冊"
    }
    
    func setUsers() {
        /// async/await
//        Task {
//            users = try await requestData(method: .get, path: .users, parameter: Empty())
//            tbvAuth.reloadData()
//        }
        /// escaping closute
        requestDataEscaping(method: .get, 
                            path: .users,
                            parameter: Empty()) { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                self.users = users
                DispatchQueue.main.async {
                    self.tbvAuth.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func inputText(_ sender: UITextField) {
        switch sender.tag {
        case 1:
            firstName = sender.text ?? ""
        case 2:
            lastName = sender.text ?? ""
        case 3:
            email = sender.text ?? ""
        default:
            password = sender.text ?? ""
        }
        
    }
    
    @IBAction func registed(_ sender: Any) {
        
        let request = authRegister(firstname: firstName,
                                   lastname: lastName,
                                   email: email,
                                   password: password)
        
        /// async / await
//        Task {
//            
//            let response: Jwttoken = try await requestData(method: .post, 
//                                                           path: .authRegister,
//                                                           parameter: request)
//            
//            UserPreferences.shared.jwtToken = response.token
//            Alert().showAlert(title: "Success", message: "Register success", vc: self)
//            setUsers()
//            txfFirstname.text = ""
//            txfLastname.text = ""
//            txfEmail.text = ""
//            txfPassword.text = ""
//        }
        
        /// escaping closure
        requestDataEscaping(method: .post,
                            path: .authRegister,
                            parameter: request) { (result: Result<Jwttoken, Error>) in
            switch result {
            case .success(let response):
                UserPreferences.shared.jwtToken = response.token
                DispatchQueue.main.async {
                    Alert().showAlert(title: "Success", message: "Register success", vc: self)
                    self.txfFirstname.text = ""
                    self.txfLastname.text = ""
                    self.txfEmail.text = ""
                    self.txfPassword.text = ""
                }
                self.setUsers()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func login() {
        
        Alert().showInputAlert(vc: self,
                               title: "Authenticate",
                               message: "輸入信箱和密碼", 
                               placeholders: placeHolders,
                               onConfirm: { inputs in
            
            /// async / await
//            Task {
//                let request = authLogin(email: inputs[0], password: inputs[1])
//                let response: Jwttoken = try await requestData(method: .post,
//                                                               path: .authLogin,
//                                                               parameter: request)
//                UserPreferences.shared.jwtToken = response.token
//                Alert().showAlert(title: "Success", message: "Login success", vc: self)
//                print("===========Login===========")
//                print(UserPreferences.shared.jwtToken)
//            }
            
            /// escaping closure
            requestDataEscaping(method: .post,
                                path: .authLogin,
                                parameter: authLogin(email: inputs[0], password: inputs[1])) { (result: Result<Jwttoken, Error>) in
                switch result {
                case .success(let response):
                    UserPreferences.shared.jwtToken = response.token
                    DispatchQueue.main.async {
                        Alert().showAlert(title: "Success", message: "Login success", vc: self)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
        
        
        
    }
}
// MARK: - Extension

extension RegisterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Auth Users"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AuthCell.identifier, for: indexPath) as! AuthCell
        
        cell.lbFirstname.text = users?[indexPath.row].firstname ?? ""
        cell.lbLastname.text = users?[indexPath.row].lastname ?? ""
        cell.lbEmail.text = users?[indexPath.row].email ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
// MARK: - Protocol


