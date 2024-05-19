//
//  MainViewController.swift
//  StudentManage
//
//  Created by imac-3373 on 2024/3/2.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tbvStudent: UITableView!
    
    // MARK: - Variables
    
    var btnRegist: UIBarButtonItem?
    
    var btnReload: UIBarButtonItem?
    
    var btnAdd: UIBarButtonItem?

    var students: [Student]?

    var placeHolders: [String] = ["FirstName", "LastName", "Email"]
    
    var test: String?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
//        let test = NetworkManager.requestData(method: .get, path: , parameter: Empty(), completionHandler: )
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
        
        tbvStudent.delegate = self
        tbvStudent.dataSource = self
        tbvStudent.register(UINib(nibName: ProductCell.identifier, bundle: nil),
                            forCellReuseIdentifier: ProductCell.identifier)
    }
    
    func setupNavigation() {
        
        navigationController?.navigationBar.barTintColor = .systemBlue
        btnRegist = UIBarButtonItem(title: "註冊", style: .done, target: self, action: #selector(regist))
        
        btnReload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        
        btnAdd = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(add))
        
        
        navigationItem.rightBarButtonItem = btnRegist
        navigationItem.leftBarButtonItems = [btnReload!, btnAdd!]
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        title = "Home"
    }
    
    // MARK: - IBAction
    
    @objc func regist() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func reload() {
        
        /// async/await
        
//        Task {
//            students = try await requestData(method: .get, path: .student, parameter: Empty(), token: UserPreferences.shared.jwtToken)
//            self.tbvStudent.reloadData()
//        }
        
        /// escaping closure
        requestDataEscaping(method: .get,
                            path: .student,
                            parameter: Empty(),
                            token: UserPreferences.shared.jwtToken) { (result: Result<[Student], Error>) in
            switch result {
            case .success(let student):
                // 成功接收到产品列表
                // 在这里处理获取到的产品信息，例如更新UI
                self.students = student
                DispatchQueue.main.async {
                    self.tbvStudent.reloadData()
                }
                print(self.students ?? [])
            case .failure(let error):
                // 处理错误
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func add() {
        Alert().showInputAlert(vc: self,
                               title: "Add Student",
                               message: "輸入學生資料",
                               placeholders: placeHolders,
                               onConfirm: { inputs in
            
            let request = studentRegister(firstName: inputs[0],
                                          lastName: inputs[1],
                                          email: inputs[2])
            /// async/await
//            Task {
//                let request = studentRegister(firstName: inputs[0],
//                                              lastName: inputs[1],
//                                              email: inputs[2])
//                
//                let _: NoData = try await requestData(method: .post,
//                                                      path: .studentRegister,
//                                                      parameter: request,
//                                                      token: UserPreferences.shared.jwtToken)
//                self.reload()
//                Alert().showAlert(title: "Success", message: "Register Success", vc: self)
//            }
            
            /// escaping closure
            requestDataEscaping(method: .post,
                                 path: .studentRegister,
                                 parameter: request,
                                token: UserPreferences.shared.jwtToken) { (result: Result<NoData, Error>) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.reload()
                        Alert().showAlert(title: "Success", message: "Register Success", vc: self)
                    }
                    print("Form submitted successfully")
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
    }
}
// MARK: - Extension

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Product"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvStudent.dequeueReusableCell(withIdentifier: ProductCell.identifier,
                                                  for: indexPath) as! ProductCell
        cell.lbFirstName.text = students?[indexPath.row].firstName
        cell.lbLastName.text = students?[indexPath.row].lastName
        cell.lbEmail.text = students?[indexPath.row].email
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { (_, _, completionHandler) in
            
            guard let deleteId = self.students?[indexPath.row].id else { return }
            let request = studentDelete(id: deleteId)
            
            /// async/await
//            Task {
//                let request = studentDelete(id: deleteId)
//                let _: NoData = try await requestData(method: .delete,
//                                                      path: .student ,
//                                                      parameter: request,
//                                                      token: UserPreferences.shared.jwtToken)
//                DispatchQueue.main.async {
//                    self.students?.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .automatic)
//                }
//            }
            /// escaping closure
            requestDataEscaping(method: .delete,
                                path: .student,
                                parameter: request,
                                token: UserPreferences.shared.jwtToken) { (result: Result<NoData, Error>) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.students?.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor.red
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editAction = UIContextualAction(style: .normal, title: "edit") {(_, _, completionHandler) in
            
            Alert().showInputAlert(vc: self,
                                   title: "Edit Student",
                                   message: "編輯學生個人資料",
                                   placeholders: ["FirstName", "LastName", "Email"], onConfirm:  { inputs in
                
                let firstName = inputs[0].isEmpty ? self.students?[indexPath.row].email : inputs[0]
                let lastName = inputs[1].isEmpty ? self.students?[indexPath.row].email : inputs[1]
                let email = inputs[2].isEmpty ? self.students?[indexPath.row].email : inputs[2]
                
                /// async/await
//                Task {
//                    
//                    let request = studentUpdate(id: self.students?[indexPath.row].id ?? 0,
//                                                firstName: firstName ?? "",
//                                                lastName: lastName ?? "",
//                                                email: email ?? "")
//                    let _: NoData = try await requestData(method: .put,
//                                                          path: .student,
//                                                          parameter: request,
//                                                          token: UserPreferences.shared.jwtToken)
//                    self.reload()
//                    Alert().showAlert(title: "Success", message: "Edit Success", vc: self)
//                }
                /// escaping closure
                requestDataEscaping(method: .put,
                                    path: .student,
                                    parameter: studentUpdate(id: self.students?[indexPath.row].id ?? 0,
                                                            firstName: firstName ?? "",
                                                            lastName: lastName ?? "",
                                                            email: email ?? ""),
                                    token: UserPreferences.shared.jwtToken) { (result: Result<NoData, Error>) in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.reload()
                            Alert().showAlert(title: "Success", message: "Edit Success", vc: self)
                        }                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            })
            completionHandler(true)
        }
        editAction.backgroundColor = UIColor.systemGreen // 設置編輯操作的背景顏色
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [editAction])
        return swipeConfiguration
    }
}
// MARK: - Protocol


