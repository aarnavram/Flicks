//
//  DetailViewController.swift
//  Flicks
//
//  Created by Aarnav Ram on 31/01/17.
//  Copyright © 2017 Aarnav Ram. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        scrollView.backgroundColor = UIColor.black
        
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
