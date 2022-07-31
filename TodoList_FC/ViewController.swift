//
//  ViewController.swift
//  TodoList_FC
//
//  Created by YoonDaeSung on 2022/07/18.
//

import UIKit

class ViewController: UIViewController {

	// weak으로 선언하게 되면 Edit -> Done으로 변경시 메모리 헤제로인하여 재사용이 불가하게 됨
	@IBOutlet var editButton: UIBarButtonItem!
	@IBOutlet weak var tableView: UITableView!
	var dondButton: UIBarButtonItem?
	var tasks = [Task]() {
		didSet {
			self.saveTasks()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.dondButton = UIBarButtonItem(
			barButtonSystemItem: .done,
			target: self,
			action: #selector(doneButtonTap)
		)
		self.tableView.dataSource = self
		self.tableView.delegate = self
		
		// didLoad를 통하여 저장된 할일들을 불러온다.
		self.loadTasks()
	}
	
	// swift에서 선언한 메소드를 object-c에서도 인식하도록 선언(@objc)
	@objc func doneButtonTap() {
		// done 클릭시 다시 edit버튼으로 전환
		self.navigationItem.leftBarButtonItem = self.editButton
		
		// tableView 편집기능 끝나도록 설정
		self.tableView.setEditing(false, animated: true)
	}
	
	@IBAction func tapEditButton(_ sender: UIBarButtonItem) {
		// ! not 연산을 붙여줌으로써 isEmpty는 비어있으면이 아닌 비어있지 않으면이란 조건이됨
		// tasks가 비어있지 않을 때 편집모드 전환되도록 방어코드 작성
		guard !self.tasks.isEmpty else { return }
		
		// edit클릭시 done으로 전환
		self.navigationItem.leftBarButtonItem = self.dondButton
		
		// tableView가 편집모드로 전환되도록 설정
		self.tableView.setEditing(true, animated: true)
		
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
	
	// UserDefault에 데이터 저장하기 (싱글톤인 사유로 하나의 인스턴스만 존재)
	func saveTasks() {
		let data = self.tasks.map {
			[
				"title": $0.title,
				"done": $0.done
			]
		}
		let userDefaults = UserDefaults.standard
		userDefaults.set(data, forKey: "tasks")
	}
	
	// UserDefault저장된 데이터 불러오기
	func loadTasks() {
		let userDefaults = UserDefaults.standard
		
		// key값 선택하여 불러오기
		guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
		self.tasks = data.compactMap {
			guard let title = $0["title"] as? String else { return nil }
			guard let done = $0["done"] as? Bool else { return nil }
			return Task(title: title, done: done)
		}
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
		
		// task.done 이 true이면 checkmark 아니면 없는 상태
		if task.done {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		return cell
	}
	
	// 편집모드에서 삭제버튼 클릭시 선택된 cell이 어떤cell인지 알려줌
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		// task내에서 삭제
		self.tasks.remove(at: indexPath.row)
		
		// tableView내에서 삭제
		// 편집모드에 들어가지않아도 swipe delete로 삭제가능
		self.tableView.deleteRows(at: [indexPath], with: .automatic)
		
		// 모든셀이 삭제되면 doneButton 호출하여 편집모드 탈출
		if self.tasks.isEmpty {
			self.doneButtonTap()
		}
	}
	
	// edit모드에서 행의 위치를 변경 가능
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	// 행의 위치변경시 어디에서 어디로 가는지 알려주는 함수
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		// task(할일 저장하는 메소드)배열에서도 동일하게 재정렬되도록 구현
		// 앱을 껏다켜도 변경된 tasks를 읽어서 변경된 tableView를 보여줌
		var tasks = self.tasks
		let task = tasks[sourceIndexPath.row] // 기존 위치의 task
		tasks.remove(at: sourceIndexPath.row) // tasks배열에서 기존 작업 삭제
		tasks.insert(task, at: destinationIndexPath.row) // 기존 task를 변경된 행위치에 해당되는 배열에 insert
		self.tasks = tasks // 정렬된 tasks를 self tasks에 대입
	}
}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// 몇 번째 task에 접근하는지 확인하기
		var task = self.tasks[indexPath.row]
		task.done = !task.done
		self.tasks[indexPath.row] = task
		
		// 선택된 cell만 reroad하도록 선언 (좌측 우측 등으로 자동으로 애니메이션 선택)
		self.tableView.reloadRows(at: [indexPath], with: .automatic)
	}
}
