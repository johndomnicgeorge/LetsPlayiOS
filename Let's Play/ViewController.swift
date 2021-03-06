//
//  ViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 4/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txt_username: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showError(message: String) {
        DispatchQueue.main.async(execute: {
            self.present(Constants.createAlert(title: "Error", message: message), animated: true, completion: nil)
        })
    }

    func showOrHideActivityIndicator(show: Bool) {
        if (show) {
            activityIndicator?.center = self.view.center
            activityIndicator?.hidesWhenStopped = true
            activityIndicator?.activityIndicatorViewStyle = .whiteLarge
            view.addSubview(activityIndicator!)
            UIApplication.shared.beginIgnoringInteractionEvents()
            activityIndicator?.startAnimating()
        } else {
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator?.stopAnimating()
        }
    }

    @IBAction func didTapLogin(_ sender: UIButton) {
        let uname = txt_username.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = txt_password.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if (uname!.isEmpty) {
            self.present(Constants.createAlert(title: "Error", message: "Please enter your username"), animated: true, completion: nil)
            return
        }

        if (pass!.isEmpty) {
            self.present(Constants.createAlert(title: "Error", message: "Please enter your password"), animated: true, completion: nil)
            return
        }
        showOrHideActivityIndicator(show: true)
        let postString = "username=\(String(describing: uname!))&password=\(String(describing: pass!))&device=ios"

        let request = Constants.createRequest(url: Constants.loginURL, postString: postString)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                self.showOrHideActivityIndicator(show: false)
            })

            guard let data = data, error == nil else {
                self.showError(message: Constants.error_internet)
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { self.showError(message: Constants.error_server)
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? [String: Any]
                let status = (json!["status"] as? String)!
                let message = (json!["message"] as? String)!
                DispatchQueue.main.async(execute: {
                    if (status == "s") {
                        UserDefaults.standard.set("\(String(describing: uname!))", forKey: "username")
                        let homeController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                        self.navigationController?.pushViewController(homeController!, animated: true)
                    } else {
                        self.present(Constants.createAlert(title: "Error", message: message), animated: true, completion: nil)
                    }
                })
            } catch _ as NSError {
                self.showError(message: Constants.error_general)
            }
        }
        task.resume()
    }

    @IBAction func didTapRegister(_ sender: UIButton) {
        let registerController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
        self.navigationController?.pushViewController(registerController!, animated: true)
    }


    @IBAction func didTapForgotPassword(_ sender: UIButton) {
        let forgotPassController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPassViewController") as? ForgotPassViewController
        self.navigationController?.pushViewController(forgotPassController!, animated: true)
    }
}

