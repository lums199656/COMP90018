//
//  ViewController.swift
//  Messager
//
//  Created by 陆敏慎 on 18/9/20.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

    
    //MARK: - IBOutlet
    //labels
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordLabelOutlet: UILabel!
    
    //textFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    
    //Views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: self.isLogin() ? "Login":"Register"){
            // login or Register
            if isLogin() {
                loginUser()
            }else{
                registerUser()
            }
        }else{
            ProgressHUD.showFailed("All Fields Are Required !")
        }
    }
    
    @IBAction func forgetButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password"){
            // reset password
        }else{
            ProgressHUD.showFailed("Email Is Required !")
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        if loginButton.title(for: .normal) == "Register"{
            updateUIFor(login: false)
        }else{
            updateUIFor(login: true)
        }
    }
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("_x LoginView")
        setupTestFieldDelegates()
        setupBackgroundTap()
        
        
    }

    //MARK: - Setup
    // 设置 textField 被点下时的触发器
    private func setupTestFieldDelegates(){
        emailTextField.addTarget(self, action: #selector(textFieldDidTouchDown(_:)), for: .touchDown)
        passwordTextField.addTarget(self, action: #selector(textFieldDidTouchDown(_:)), for: .touchDown)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidTouchDown(_:)), for: .touchDown)

    }
    
    // 用来捕捉 tap 动作
    private func setupBackgroundTap(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // 切换 login 和 signup 状态下的 UI
    private func updateUIFor(login: Bool){
        if login == true{
            loginButton.setTitle("Register", for: .normal)
            signupButton.setTitle("  Login", for: .normal)
            askButton.setTitle("Have an account ?        ", for: .normal)
            self.forgetPasswordButton.setTitle(" ", for: .normal)
        }else{
            loginButton.setTitle("Login", for: .normal)
            signupButton.setTitle("Sign Up", for: .normal)
            askButton.setTitle("Don't have an account ?", for: .normal)
            self.forgetPasswordButton.setTitle("Forget Password ?", for: .normal)
        }
        
        UIView.animate(withDuration: 0.4){
            self.repeatPasswordTextField.isHidden = !login
            self.repeatPasswordLineView.isHidden = !login
            self.repeatPasswordLabelOutlet.isHidden = !login
            
        }

    }
    
    // 当某一个 textField 被点下时，其他空的 textField 要恢复他们的 placeholder
    @objc func textFieldDidTouchDown(_ texField: UITextField){
        if texField != emailTextField && emailTextField.placeholder == ""{
            emailTextField.placeholder = "Email"
        }
        if texField != passwordTextField && passwordTextField.placeholder == ""{
            passwordTextField.placeholder = "Password"
        }
        if texField != repeatPasswordTextField && repeatPasswordTextField.placeholder == ""{
            repeatPasswordTextField.placeholder = "Repeat Password"
        }
        texField.placeholder = ""

    }
    
    // 当背景被点击时所触发的反应
    @objc func backgroundTap(){
        // command shift k -> 调出键盘
        view.endEditing(false)
        if emailTextField.placeholder == ""{
            emailTextField.placeholder = "Email"
        }
        if passwordTextField.placeholder == ""{
            passwordTextField.placeholder = "Password"
        }
        if repeatPasswordTextField.placeholder == ""{
            repeatPasswordTextField.placeholder = "Repeat Password"
        }
    }
    
    private func isLogin() -> Bool{
        return loginButton.title(for: .normal) == "Login"
    }
    
    
    private func isDataInputedFor(type: String) -> Bool{
        switch type {
        case "Login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "Register":
            return emailTextField.text != "" && passwordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    private func registerUser(){
        if passwordTextField.text! == repeatPasswordTextField.text! {
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                if error == nil {
                    ProgressHUD.showSuccess("Verification email sent!")
                }else{
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }
        } else {
            ProgressHUD.showFailed("The passwords don't match!")
        }
    }
    
    private func loginUser(){
        FirebaseUserListener.shared.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            if error == nil {
                if isEmailVerified {
                    print(self.emailTextField.text!, " has logged in!")
                    self.goToApp()
                }else{
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    private func goToApp() {
        
        // 获取 mainView 控制
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
        
    }
}

