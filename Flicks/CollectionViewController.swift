//
//  CollectionViewController.swift
//  Flicks
//
//  Created by Aarnav Ram on 20/01/17.
//  Copyright © 2017 Aarnav Ram. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class CollectionViewController: UIViewController {
    
    let errorBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 600, height: 50))
    let refreshControl = UIRefreshControl()
    var movies:[NSDictionary]?
    @IBOutlet weak var collectionView: UICollectionView!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        confirgureErrorButton()
        collectionView.isHidden = true
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        refreshControlAction(refreshControl: refreshControl)
        configureLayout()
        defaults.set(0, forKey: "currentView") //use 0 for tableView
        // Do any additional setup after loading the view.

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
    
    func configureLayout() {
        
        let leftAndRightPaddings: CGFloat = 5
        let numberOfItemsPerRow: CGFloat = 2
        
        let bounds = UIScreen.main.bounds
        let width = (bounds.size.width - leftAndRightPaddings*(numberOfItemsPerRow)) / numberOfItemsPerRow
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let size = CGSize(width: width, height: 1.5*width)
        layout.itemSize = size
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
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
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
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
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

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let movie = movies![indexPath.row]
        let baseURL = "https://image.tmdb.org/t/p/w342"
        let imageURL = movie["poster_path"] as! String
        let fullURL = URL(string: baseURL + imageURL)
        cell.posterImage.setImageWith(fullURL!)
        return cell
    }
}
