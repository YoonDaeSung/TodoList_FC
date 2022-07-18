//
//  ViewController.swift
//  TodoList_FC
//
//  Created by YoonDaeSung on 2022/07/18.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	var tasks = [Task]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	@IBAction func tapEditButton(_ sender: UIBarButtonItem) {
	}
	
	@IBAction func tapAddButton(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
		
		// weak self 미 사용시에 강한참조의 ARC로 메모리 누수발생
		let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
			guard let title = alert.textFields?[0].text else { return }
			let task = Task(title: title, done: false)
			
			// alert창에 할일을 등록할때마다 tasks배열에 할일들이 추가가 됨
			self?.tasks.append(task)
			
		})
		let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
		alert.addAction(cancelButton)
		alert.addAction(registerButton)
		
		// alert에 표시하는 textField 클로져
		alert.addTextField(configurationHandler: { textField in
			textField.placeholder = "할 일을 입력해주세요."
		})
		self.present(alert, animated: true, completion: nil)
	}
}

