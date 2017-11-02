//
//  MainTableViewController.swift
//  Feeding2
//
//  Created by D7703_15 on 2017. 11. 2..
//  Copyright © 2017년 D7703_15. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, XMLParserDelegate {
    
    //http 막혀있기때문에 맞춰야함
    //왼쪽 프로젝트 네비게이터 눌러서 맨위에누름 그리고 info 누른다음 아무곳에나 플러스 누르고 App친다음 트랜스퍼 치면됨
    //그리고 그거를 딕셔너리 니깐 화살표 밑으로내려서 항목중 첫번째는 전체 두번째는 웹컨텐츠만마지막은 제외 항목 설정
    let listEndPoint = "http://apis.data.go.kr/6260000/BusanFreeFoodProvidersInfoService/getFreeProvidersListInfo"
    let detailEndPoint = "http://apis.data.go.kr/6260000/BusanFreeFoodProvidersInfoService/getFreeProvidersDetailsInfo"
    let serviceKey = "tbkRHovJzFjj5nnamShOHKHBHo7AQ%2FzPRqfK0FEAttBG1Ky17MM90gULHixVa3bQTdkrVZJj6hBInHlOozfVxg%3D%3D"
    
    //키밸류
    //var item:[String:String]?이렇게하면 옵셔널써야한다
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var key = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager.default
        //pathcomfonent 이건 슬러쉬다/
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("data.plist")
        
        print(url!)
        //파일이 있는지 체크
        //앱솔루는파일 점점 슬러쉬 까지 다있고 패스는 그게없음
        if fileManager.fileExists(atPath: url!.path){
            items = NSArray(contentsOf: url!) as! Array
        }else{
            //최포에 파일이 없을경우에 읽어오고 아니면 피리스트 에서 읽어옴
            getList()
            //저장공간을 같이 쓰기 위해 비워줘야한다
            //복사해놓고 비우기 위해 디테일 정보에도 넣기위해
            let tempItems = items
            items = []
            //detail 을 하나하나 다담을거임
            for dic in tempItems {
                getDetail(idx: dic["idx"]!)
            }
            //어레이는 스위프트 배열타입 NS어레이는ios프레임에서 제공 기능많고 파일저장기능 있음
            let temp = items as NSArray
            temp.write(to: url!, atomically: true)
        }
        
        
    }
    
    func getDetail(idx:String){
        //매개변수로 idx넘겨받음
        //이건 idx가 필요함
        let str = detailEndPoint + "?serviceKey=\(serviceKey)&idx=\(idx)"
        
        if let url = URL(string: str){
            if let parser = XMLParser(contentsOf: url){
                
                parser.delegate = self
                //리턴값 이 bool이다
                let success = parser.parse()
                if success {
                    print("파싱성공")
                    print(items)
                }else{
                    print("파싱실패")
                }
            }
            
        }
    }
    
    func getList(){
        //한글없으니 퍼센트 인코딩 안해도됨
        //반환형이 옵셔널이기때문에 언랩핑 해야됨
        //공백데이터 는 트림잉
        //한번에 다받기 api예시에서 받기 numofRows
        let str = listEndPoint + "?serviceKey=\(serviceKey)&numofRows=5"
        
        if let url = URL(string: str){
            if let parser = XMLParser(contentsOf: url){
                
                parser.delegate = self
                
                let success = parser.parse()
                if success {
                    print("파싱성공")
                    print(items)
                }else{
                    print("파싱실패")
                }
            }
            
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //잘못된 api있을수 있기때문에 트림으로 공백제거함
        //in:이것이 enum열거형 이기때문에 .찍으면 나온다
        //시작했을때 엘리먼트 네임 저장
        key = elementName.trimmingCharacters(in: .whitespaces)
        //딕셔너리 생성
        if key == "item"{
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //api 문제 나타날수있음 두번 비워지기 때문에
        print("key: \(key) value :\(string)")
        if item[key] == nil {
            item[key] = string.trimmingCharacters(in: .whitespaces)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //끝났을때 배열에다가 딕셔너리 저장
        if elementName == "item"{
            items.append(item)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //섹션 한개
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //reuseIdentifier
        let dic = items[indexPath.row]
        
        cell.textLabel?.text = dic["name"]

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
