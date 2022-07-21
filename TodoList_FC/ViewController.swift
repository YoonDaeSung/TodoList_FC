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
		self.tableView.dataSource = self
	}
	
	@IBAction func tapEditButton(_ sender: UIBarButtonItem) {
	}
	
	@IBAction func tapAddButton(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
		
		// weak self 미 사용시에 강한참조의 ARC로 메모리 누수발생
		let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
			
			// 입력한 텍스트 제목을 task 구조에 담아주기
			guard let title = alert.textFields?[0].text else { return }
			let task = Task(title: title, done: false)
			
			// task배열에 append해준이후 tableView reroad 해주기
			self?.tasks.append(task)
			self?.tableView.reloadData()
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

extension ViewController: UITableViewDataSource {
	// 행의 갯수
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tasks.count
	}
	
	// cell 그리는 함수
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// withIdentifier을 사용하여 SB에서 이름을 찾아 삽입
		// for 인자 해당 cell을 재사용하도록 도움
		// cell자체를 재사용하여 메모리 누수방지를 위한 dequeueReusableCell을 활용
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let task = self.tasks[indexPath.row]
		cell.textLabel?.text = task.title
		return cell
	}
}
