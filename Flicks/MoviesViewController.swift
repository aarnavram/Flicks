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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    let errorBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 65, width: 600, height: 50))
    let refreshControl = UIRefreshControl()
    let refreshControlTwo = UIRefreshControl()
    let defaults = UserDefaults.standard
    let searchBar = UISearchBar()

    @IBOutlet weak var changeViewButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        

        super.viewDidLoad()
                
        configureSearchBar()
        collectionView.dataSource = self
        collectionView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        configureLayout()
        tableView.contentInset = UIEdgeInsetsMake(65,0,0,0);

        // Do any additional setup after loading the view.
        
        confirgureErrorButton()
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        refreshControlTwo.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        collectionView.insertSubview(refreshControl, at: 0)
        tableView.insertSubview(refreshControlTwo, at: 0)

        refreshControlAction(refreshControl: refreshControl)
        
        
        //defaults.set(0, forKey: "currentView") //use 0 for tableView
        
        if defaults.object(forKey: "currentView") != nil {
            if defaults.value(forKey: "currentView") as! Int == 0 {
                changeViewButton.image = UIImage(named: "grid")
            } else {
                changeViewButton.image = UIImage(named: "list")
            }
        } else {
            defaults.set(1, forKey: "currentView")
        }
        
        
    }
        
    
    func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for a movie"
        searchBar.showsCancelButton = false
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onViewChanged(_ sender: AnyObject) {
        if defaults.value(forKey: "currentView") as! Int == 0 {
            defaults.set(1, forKey: "currentView")
            changeViewButton.image = UIImage(named: "list")
            buttonCall()
        } else {
            defaults.set(0, forKey: "currentView")
            changeViewButton.image = UIImage(named: "grid")
            buttonCall()
        }
    }
    
    
    func confirgureErrorButton() {
        self.view.addSubview(errorBtn)
        NSLayoutConstraint(item: errorBtn, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: errorBtn, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: errorBtn, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1, constant: 65).isActive = true
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
                    self.filteredMovies = NSArray(array: self.movies!, copyItems: true) as? [NSDictionary]
                    self.filteredMovies = self.movies
                    self.errorBtn.isHidden = true
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    if self.defaults.value(forKey: "currentView") as! Int == 0 {
                        self.collectionView.isHidden = true
                        self.tableView.isHidden = false
                    } else {
                        self.tableView.isHidden = true
                        self.collectionView.isHidden = false
                    }
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
        if let movies = filteredMovies { //changed to filteredMovies
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let results:[NSDictionary]?
        if !searchText.isEmpty {
            results = self.movies?.filter({ movie in
                if let movieTitle = movie["title"] as? String {
                    return movieTitle.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                }
                return false
            })
        } else {
            results = self.movies
        }
        filteredMovies = NSArray(array: results!) as? [NSDictionary]
        tableView.reloadData()
        collectionView.reloadData()
        
    }
    
   // override var prefersStatusBarHidden: Bool {
     //   return true
    //}
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        //let movie = movies![indexPath.row]
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let description = movie["overview"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        let imageUrl = movie["poster_path"] as! String
        
        let fullUrl = baseUrl + imageUrl
        let imageRequest = URLRequest(url: URL(string: fullUrl)!)

        
        cell.posterView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                if imageResponse != nil {
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animate(withDuration: 0.4, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    cell.posterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                print("image was not loaded")
        })
        
        
        cell.titleLabel.text = title
        cell.descrLabel.text = description
        
        
        
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        searchBar.resignFirstResponder()
        if defaults.value(forKey: "currentView") as! Int == 0 {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let thisMovie = movies![indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = thisMovie
        } else {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            let thisMovie = movies![indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = thisMovie

            
        }
        
    }
    

}

extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let movie = filteredMovies![indexPath.row]
        let baseURL = "https://image.tmdb.org/t/p/w342"
        let imageURL = movie["poster_path"] as! String
        let fullURL = baseURL + imageURL
        let imageRequest = URLRequest(url: URL(string: fullURL)!)
        
        cell.posterImage.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                if imageResponse != nil {
                    cell.posterImage.alpha = 0.0
                    cell.posterImage.image = image
                    UIView.animate(withDuration: 0.4, animations: { () -> Void in
                        cell.posterImage.alpha = 1.0
                    })
                } else {
                    cell.posterImage.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                print("image was not loaded")
        })
        return cell
    }
}
