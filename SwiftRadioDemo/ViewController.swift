//
//  ViewController.swift
//  SwiftRadioDemo
//
//  Created by Jacqui on 2016/11/6.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    var backImage: UIImageView!     ///<    背景
    var tableview: UITableView!     ///<    列表
    var refreshControl: UIRefreshControl!   ///<    下拉刷新

    var playingRadioView: UIView!   ///<    底部视图
    var playingAnimationImages: UIImageView!    ///< 播放Radio时的动画ImageView
    var playingButton: UIButton!                ///< 播放Radio，进入详情按钮
    
    var searchController: UISearchController!   ///< 搜索controller
    
    var currentTrack: Track?
    var currentStation: RadioStation?
    var lastStation: RadioStation?
    var firstTime = true
    
    var datasource: [RadioStation] = []         ///< 存储Radio的数据源
    var searchedStation: [RadioStation] = []    ///< 搜索Radio结果数据
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Swift Radio"
        
        loadStationDataFromJSON()
        setupView()
        
        /// Set AVFoundation category, required for background audio
        var error: NSError?
        var success: Bool
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        
        if !success {
            if kDebugLog {
                print("Failed to set audio session category.  Error: \(error)")
            }
        }
        
        /// Set audioSession as active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error2 as NSError {
            error = error2
            if kDebugLog {
                print("audioSession setActive error \(error2)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If a station has been selected, create "Now Playing" button to get back to current station
        if !firstTime {
            setupPlayingBarButton()
        }
        
        // If a track is playing, display title & artist information and animation
        if currentTrack != nil && currentTrack!.isPlaying {
            let title = currentStation!.name + ":" + currentTrack!.title + "-" + currentTrack!.artist + "..."
            playingButton.setTitle(title, for: .normal)
            playingAnimationImages.startAnimating()
        } else {
            playingAnimationImages.stopAnimating()
            playingAnimationImages.image = UIImage(named: "NowPlayingBars")
        }
    }
    
    /// 刷新事件
    func refresh() {
        datasource.removeAll(keepingCapacity: true)
        loadStationDataFromJSON()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            self.refreshControl.endRefreshing()
            self.view.setNeedsDisplay()
        }
    }

//  MARK: -  加载视图
    func setupView() {
        setupBackImage()
        setupBarItem()
        setupTableView()
        setupPullRefresh()
        setupPlayingRadioView()
        setupSeacrchController()
    }
    
    func setupBarItem() {
        let leftItem = UIBarButtonItem.init(image: UIImage(named: "icon-hamburger"), style: .plain, target: self, action: #selector(presentMenuView))
        navigationItem.leftBarButtonItem = leftItem
    }
    
    /// 创建进入播放详情页面按钮
    func setupPlayingBarButton() {
        if self.navigationItem.rightBarButtonItem == nil {
            let btn = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(enterRadioDetail))
            btn.image = UIImage(named: "btn-nowPlaying")
            navigationItem.rightBarButtonItem = btn
        }
    }
    
    /// 创建下拉刷新
    func setupPullRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString.init(string: "Pull to refresh", attributes: [NSForegroundColorAttributeName : UIColor.white])
        refreshControl.tintColor = UIColor.white
        refreshControl.backgroundColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        tableview.refreshControl = refreshControl
        tableview.addSubview(refreshControl)
    }
    
    /// 创建背景视图
    func setupBackImage() {
        backImage = UIImageView()
        backImage.image = UIImage(named: "background")
        backImage.isUserInteractionEnabled = true
        view.addSubview(backImage)
        
        backImage.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-45)
        }
    }
    
    /// 创建tableview
    func setupTableView() {
        tableview = UITableView(frame: CGRect(), style: .plain)
        tableview.backgroundColor = UIColor.clear
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView()
        tableview.separatorStyle = .none
        tableview.register(RadioTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableview)
        
        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view).offset(-45)
        }
    }
    
    /// 创建searchController
    func setupSeacrchController() {
        searchController = UISearchController(searchResultsController: nil)
        
        if searchable {
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            
            tableview.tableHeaderView = searchController.searchBar
            tableview.tableHeaderView?.backgroundColor = UIColor.clear
            definesPresentationContext = true
            searchController.hidesNavigationBarDuringPresentation = false
            
            searchController.searchBar.barTintColor = UIColor.clear
            searchController.searchBar.tintColor = UIColor.white
            
            let searchTextField = searchController.searchBar.value(forKey: "_searchField") as! UITextField
            searchTextField.keyboardAppearance = UIKeyboardAppearance.dark
        }
    }
    
    /// 创建播放视图
    func setupPlayingRadioView() {
        playingRadioView = UIView()
        playingRadioView.backgroundColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 37/255.0, alpha: 1)
        
        playingAnimationImages = UIImageView()
        playingAnimationImages.image = UIImage(named: "NowPlayingBars")
        playingAnimationImages.animationImages = AnimationFrames.createFrames()
        playingAnimationImages.animationDuration = 0.7
        
        playingButton = UIButton()
        playingButton.setTitle("Choose a station above to begin", for: .normal)
        playingButton.contentHorizontalAlignment = .left
        playingButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        playingButton.setTitleColor(UIColor.gray, for: .normal)
        playingButton.addTarget(self, action: #selector(enterRadioDetail), for: .touchUpInside)
        
        view.addSubview(playingRadioView)
        playingRadioView.addSubview(playingAnimationImages)
        playingRadioView.addSubview(playingButton)
        
        playingRadioView.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(45)
        }
        
        playingAnimationImages.snp.makeConstraints { (make) in
            make.centerY.equalTo(playingRadioView)
            make.left.equalTo(playingRadioView).offset(10)
            make.width.equalTo(19)
            make.height.equalTo(19)
        }
        
        playingButton.snp.makeConstraints { (make) in
            make.left.equalTo(playingAnimationImages.snp.right).offset(10)
            make.centerY.equalTo(playingAnimationImages)
            make.right.equalTo(playingRadioView).offset(-10)
        }
    }
    
    /// 从本地JSON文件中读取数据
    func loadStationDataFromJSON() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DataManager.getDataFromFileWithSuccess { (data) in
            if kDebugLog { print("Stations JSON Found") }
            
            let json = JSON(data: data as Data)
            if let stationArray = json["station"].array {
                
                for stationJSON in stationArray {
                    let station = RadioStation.parseStation(stationJSON)
                    datasource.append(station)
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableview.reloadData()
                    self.view.setNeedsDisplay()
                })
            } else {
                if kDebugLog { print("JSON Station Loading Error") }
            }
            
            // Turn off network indicator in status bar
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource
extension ViewController : UITableViewDataSource {
    
    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController != nil && searchController.isActive {
            return searchedStation.count
        } else {
            if datasource.count == 0 {
                return 1
            } else {
                return datasource.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! RadioTableViewCell
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.clear
        } else {
            cell.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        let station = datasource[indexPath.row]
        cell.configureCell(station)
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        firstTime = false
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let nowPlayingVC = NowPlayingViewController()
        nowPlayingVC.delegate = self
        
        //  set station judge is searched or origin list
        if searchController.isActive {
            currentStation = searchedStation[indexPath.row]
        } else {
            currentStation = datasource[indexPath.row]
        }
        
        if lastStation != nil && currentStation == lastStation {
            if currentTrack != nil {
                nowPlayingVC.track = currentTrack
                nowPlayingVC.newStation = false
            } else {
                nowPlayingVC.newStation = true
                lastStation = currentStation
            }
        } else {
            nowPlayingVC.newStation = true
            lastStation = currentStation
        }
        nowPlayingVC.currentStation = currentStation
        navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
}

//  MARK: - Events
extension ViewController {
    /// 若radio正在播放，进入播放页面详情
    func enterRadioDetail() {
        if currentTrack == nil {
            return
        }
        
        let nowPlayingVC = NowPlayingViewController()
        nowPlayingVC.delegate = self
        
        nowPlayingVC.track = currentTrack
        nowPlayingVC.newStation = false
        nowPlayingVC.currentStation = currentStation
        navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
    
    func presentMenuView() {
        let menuVC = MenuViewController()
//        modalPresentationStyle
        self.present(menuVC, animated: true, completion: nil)
    }
}


// MARK: - NowPlayingViewControllerDelegate
extension ViewController : NowPlayingViewControllerDelegate {
    func songMetaDataDidUpdate(track: Track) {
        currentTrack = track
        let title = currentStation!.name + ": " + currentTrack!.title + " - " + currentTrack!.artist + "..."
        playingButton.setTitle(title, for: .normal)
    }
    
    func artworkDidUpdate(track: Track) {
        currentTrack?.artworkURL = track.artworkURL
        currentTrack?.artworkImage = track.artworkImage
    }
    
    func trackPlayingToggled(track: Track) {
        currentTrack?.isPlaying = track.isPlaying
    }
}

// MARK: - UISearchResultsUpdating
extension ViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchedStation.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (datasource as NSArray) .filtered(using: searchPredicate)
        searchedStation = array as! [RadioStation]
        
        tableview.reloadData()
    }
}
