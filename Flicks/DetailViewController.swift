//
//  DetailViewController.swift
//  Flicks
//
//  Created by Aarnav Ram on 31/01/17.
//  Copyright © 2017 Aarnav Ram. All rights reserved.
//

import UIKit
import Alamofire


class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var videoView: UIWebView!
    var videoID = "" //change this 

    var movie: NSDictionary!
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let movieID = movie["id"] as? NSNumber
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID!)/videos?api_key=\(apiKey)&language=en-US")!
        
        Alamofire.request(url).responseJSON { response in
            if let reponseJSON = response.result.value {
                print("JSON: \(reponseJSON)")
                let JSON = reponseJSON as! NSDictionary
                let results = JSON.value(forKeyPath: "results") as! [NSDictionary]
                self.videoID = results[0].value(forKeyPath: "key") as! String
                self.videoView.loadHTMLString("<iframe id=\"ytplayer\" type=\"text/html\" width=\"360\" height=\"195\" src=\"https://www.youtube.com/embed/\(self.videoID)?autoplay=1\" frameborder=\"0\"></iframe>", baseURL: nil)
                print(self.videoID)
            }
        }
        
        videoView.allowsInlineMediaPlayback = true
        videoView.backgroundColor = UIColor.black
        
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        scrollView.backgroundColor = UIColor.clear
        self.scrollView.layer.allowsGroupOpacity = false
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height + videoView.frame.size.height + 50)
        
        titleLabel.text = movie["title"] as? String
        overviewLabel.text = movie["overview"] as? String
        
        // Do any additional setup after loading the view.
        
        let baseUrlLowRes = "https://image.tmdb.org/t/p/w45"
        let baseUrlHighRes = "https://image.tmdb.org/t/p/original"
        
        if let imageUrl = movie["poster_path"] as? String {
            let lowFullUrl = baseUrlLowRes + imageUrl
            let HighFullUrl = baseUrlHighRes + imageUrl
            let smallImageRequest = URLRequest(url: URL(string: lowFullUrl)!)
            let largeImageRequest = URLRequest(url: URL(string: HighFullUrl)!)
            
            posterImageView.setImageWith(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    if smallImageResponse != nil {
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = smallImage
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            
                            self.posterImageView.alpha = 1.0
                            
                            }, completion: { (sucess) -> Void in

                                self.posterImageView.setImageWith(
                                    largeImageRequest,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        
                                        self.posterImageView.image = largeImage;
                                        
                                    },
                                    failure: { (request, response, error) -> Void in
                                        self.posterImageView.image = smallImage
                                })
                        })
                        
                    } else {
                        self.posterImageView.setImageWith(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterImageView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                self.posterImageView.image = smallImage
                        })
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    print("image was not loaded")
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
