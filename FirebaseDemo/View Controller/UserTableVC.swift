//
//  UserTable.swift
//  FirebaseDemo
//
//  Created by Farhana Khan on 03/05/21.
//

import UIKit
import FirebaseFirestore
class UserTableVC: UIViewController {
    let database = Firestore.firestore()
    var service: UserTableVC?
    @IBOutlet weak var UserTV: UITableView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    var allusers = [appUser]() {
        didSet {
            DispatchQueue.main.async {
                self.users = self.allusers
            }
        }
    }
    var users = [appUser]() {
        didSet {
            DispatchQueue.main.async {
                self.UserTV.reloadData()
            }
        }
    }
    
    func get(collectionID: String, handler: @escaping ([appUser]) -> Void) {
        database.collection("users")
            .addSnapshotListener { querySnapshot, err in
                if let error = err {
                    print(error)
                    handler([])
                } else {
                    handler(appUser.build(from: querySnapshot?.documents ?? []))
                }
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        actInd.startAnimating()
        actInd.hidesWhenStopped = true
        UserTV.delegate = self
        UserTV.dataSource = self
        loadData()
    }
    
    func loadData() {
        actInd.stopAnimating()
        service = UserTableVC()
        service?.get(collectionID: "users") { users in
            self.allusers = users
        }
    }
}
extension UserTableVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("count \(userData.count)")
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UserTVC
        let dataResp = users[indexPath.row]
        cell.nameLb.text = "\(dataResp.firstName!) \(dataResp.lastName!)"
        return cell
    }
    
    
}



extension appUser {
    static func build(from documents: [QueryDocumentSnapshot]) -> [appUser] {
        var users = [appUser]()
        for document in documents {
            users.append(appUser(firstName: document["FirstName"] as? String ?? "",
                                 lastName: document["LastName"] as? String ?? ""))
        }
        return users
    }
}

struct appUser {
    let firstName: String?
    let lastName: String?
}
