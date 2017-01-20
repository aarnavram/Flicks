//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Aarnav Ram on 19/01/17.
//  Copyright © 2017 Aarnav Ram. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    let errorBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 600, height: 50))
    let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true

        // Do any additional setup after loading the view.
        
        confirgureErrorButton()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        refreshControlAction(refreshControl: refreshControl)

        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func confirgureErrorButton() {
        self.view.addSubview(errorBtn)
        NSLayoutConstraint(item: errorBtn, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: errorBtn, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1, constant: 20).isActive = true
        errorBtn.translatesAutoresizingMaskIntoConstraints = false
        errorBtn.backgroundColor = UIColor.black
        errorBtn.setTitle("⚠️ Network Error", for: .normal)
        errorBtn.isHidden = true
        errorBtn.isUserInteractionEnabled = true
        errorBtn.addTarget(self, action: #selector(buttonCall), for: UIControlEvents.touchUpInside)
    }
    
    func buttonCall() {
        refreshControlAction(refreshControl: refreshControl)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(hideHUD), userInfo: nil, repeats: false)
        
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.errorBtn.isHidden = true
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    refreshControl.endRefreshing()
                }
            } else {
                self.errorBtn.isHidden = false
                refreshControl.endRefreshing()
            }
        }
        MBProgressHUD.hide(for: self.view, animated: true)
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let description = movie["overview"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        let imageUrl = movie["poster_path"] as! String
        
        let fullUrl = URL(string: baseUrl + imageUrl)
        
    
        cell.titleLabel.text = title
        cell.descrLabel.text = description
        cell.posterView.setImageWith(fullUrl!)
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
