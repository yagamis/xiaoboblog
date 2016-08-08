//
//  HomeTableViewController.swift
//  Blog
//
//  Created by yons on 16/8/7.
//  Copyright © 2016年 xiaobo. All rights reserved.
//

import UIKit
import SafariServices

class HomeTableViewController: UITableViewController, XMLParserDelegate {
    var articles: [Article] = []
    var article : Article!
    var currentElement = ""
    var isInParentElement = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
               
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loadXml()
        
        // 主标题行数不限, 副标题行数为1行 ,自动单元格大小才有效
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    
    func loadXml()  {
        
        let blogRSS = "http://www.xiaoboswift.com/feed"
        print("读取数据")
        guard  let url = URL(string: blogRSS) else {
            return
        }
        guard let parser = XMLParser(contentsOf: url) else {
            return
        }
        
        parser.delegate = self
        parser.parse()
        
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("开始解析XML")
    }
    
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("开始标签", elementName)
        self.currentElement = elementName
        
        if elementName == "item" {
            isInParentElement = true
            article = Article(title: "", link: "", comments: "", pubDate: "", description: "", category: "")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //跳过非item标签节点内的解析
        guard isInParentElement else {
            return
        }
        
        print("元素内容",string)
        
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !data.isEmpty {
                switch self.currentElement {
                case "title":
                    article.title += data
                case "link":
                    article.link += data
                case "description":
                    article.description += data
                case "pubDate":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss zzz"
                    dateFormatter.locale = Locale(identifier: "en_us")
                    let fd = dateFormatter.date(from: data)
                    
                    if let fd = fd  {
                        let formatStr = DateFormatter.dateFormat(fromTemplate: "Mdd", options: 0, locale: Locale.current)
                        dateFormatter.dateFormat = formatStr
                        article.pubDate = dateFormatter.string(from: fd)
                    }
    
                case "category":
                    article.category += data
                case "comments":
                    article.comments += data
                default:
                    break
                }
                dump(article)
   
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            articles.append(article!)
            isInParentElement = false
        }
        
      
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("XML解析结束")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
       
        tableView.reloadData()
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("解析出错:",parseError.localizedDescription)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath)
        let art = articles[indexPath.row]
        
        cell.textLabel!.text = art.title
        cell.detailTextLabel!.text = art.description
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 1
    
        
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 60))
        timeLabel.text = art.pubDate
        
        cell.accessoryView = timeLabel

       return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: articles[indexPath.row].link)!
        let sf = SFSafariViewController(url: url)
        self.present(sf, animated: true, completion: nil)
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destVC = segue.destination as? ViewController {
            let art = articles[(tableView.indexPathForSelectedRow!.row)]
            destVC.link = art.link
        }
    }
    

}
