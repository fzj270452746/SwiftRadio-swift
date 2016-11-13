//
//  NowPlayingViewController.swift
//  SwiftRadioDemo
//
//  Created by Fan on 2016/11/7.
//  Copyright © 2016年 Jugg. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer
import Spring

//*****************************************************************
// Protocol
// Updates the StationsViewController when the track changes
//*****************************************************************

protocol NowPlayingViewControllerDelegate : class {
    func songMetaDataDidUpdate(track: Track)
    func artworkDidUpdate(track: Track)
    func trackPlayingToggled(track: Track)
}

class NowPlayingViewController: UIViewController {
    
    var backImage: UIImageView!         ///<    background
    var coverImage : SpringImageView!   ///<    cover image
    var desLbl : UILabel!               ///<    des
    var stopBtn : UIButton!             ///<    stop button
    var playBtn : UIButton!             ///<    play button
    var minVoiceImg : UIImageView!      ///<    the mininum voice
    var maxVoiceImg : UIImageView!      ///<    the max voice
    
    var mpVolumeSlide : UISlider!
    var voiceSlide : UISlider!          ///<    change the voice
    
    var songLbl : SpringLabel!          ///<    show the play status
    var artistLbl : UILabel!            ///<    show the radio name
    var swiftLogoBtn : UIButton!        ///<    show detail about the project
    var shareBtn : UIButton!            ///<    share button
    var detailBtn : UIButton!           ///<    detail info about this radio
    
    var nowPlayingAnimationImg : UIImageView!   ///< while is playing, play animations
    
    var currentStation: RadioStation!           ///< current play radio station
    var track: Track!
    
    var radioPlayer = Player.radio
    var downloadTask: URLSessionDownloadTask?
    
    var newStation = true
    var justBecameActive = false
    
    
    weak var delegate : NowPlayingViewControllerDelegate?
    
    
//******************************************
//  MARK: - life cycle
//******************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        setupView()
        setupPlayer()
        setupData()
        
        //Notification for MediaPlayer metadata updated
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NowPlayingViewController.metadataUpdated(notification:)),
                                               name: Notification.Name.MPMoviePlayerTimedMetadataUpdated,
                                               object: nil)
        
        // Notification for when app becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NowPlayingViewController.didBecomeActiveNotificationReceived(notification:)),
                                               name: Notification.Name("UIApplicationDidBecomeActiveNotification"),
                                               object: nil)
        
        // Notification for AVAudioSession Interruption (e.g. Phone call)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NowPlayingViewController.sessionInterrupted),
                                               name: Notification.Name.AVAudioSessionInterruption,
                                               object: AVAudioSession.sharedInstance())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// when receive control from background
    override func remoteControlReceived(with receivedEvent: UIEvent?) {
        super.remoteControlReceived(with: receivedEvent)
        
        if receivedEvent!.type == UIEventType.remoteControl {
            
            switch receivedEvent!.subtype {
            case .remoteControlPlay:
                playPressed()
            case .remoteControlPause:
                stopPressed()
            default:
                break
            }
        }
    }
}

//*****************************************************************
// MARK: - Notification
//*****************************************************************

private extension NowPlayingViewController {
    //*****************************************************************
    // MARK: - MetaData Updated Notification
    //*****************************************************************
    @objc func metadataUpdated(notification: Notification)  {
        if radioPlayer.timedMetadata != nil && radioPlayer.timedMetadata.count > 0 {
            // start animation
            startNowPlayingAnimation()
            
            let firstMeta: MPTimedMetadata = radioPlayer.timedMetadata.first as! MPTimedMetadata
            let metaData = firstMeta.value as! String
            
            var stringParts = [String]()
            if metaData.range(of: " - ") != nil {
                stringParts = metaData.components(separatedBy: " - ")
            } else {
                stringParts = metaData.components(separatedBy: "-")
            }
            
            let currentSongName = track.title
            track.artist = stringParts[0]
            track.title = stringParts[0]
            
            if stringParts.count > 1 {
                track.title = stringParts[1]
            }
            
            if track.artist == "" && track.title == "" {
                track.artist = currentStation.desc
                track.title = currentStation.name
            }
            
            DispatchQueue.main.async(execute: {
                if currentSongName != self.track.title {
                    if kDebugLog {
                        print("METADATA artist: \(self.track.artist) | title: \(self.track.title)")
                    }
                    
                    self.artistLbl.text = self.track.artist
                    self.songLbl.text = self.track.title
                    
                    self.songLbl.animation = "zoomIn"
                    self.songLbl.duration = 1.5
                    self.songLbl.damping = 1
                    self.songLbl.animate()
                    
                    self.resetAlbumArtwor()
                    self.queryAblumArt()
                    self.updateLockScreen()
                    self.delegate?.songMetaDataDidUpdate(track: self.track)
                }
            })
            
        }
    }
    
    @objc func didBecomeActiveNotificationReceived(notification: Notification) {
        
        if track.isPlaying {
            updateLbl()
            justBecameActive = true
            updateAblumArtwork()
        }
    }
    
    @objc func sessionInterrupted(notification: Notification) {
        if let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber {
            if let type = AVAudioSessionInterruptionType(rawValue: typeValue.uintValue) {
                if type == .began {
                    print("interruption: began")
                } else {
                    print("interruption: ended")
                    // Add your code here
                }
            }
        }
    }
    
    func updateLockScreen() {
        var albumArtWork : MPMediaItemArtwork!
        if (track.artworkImage != nil) {
            albumArtWork = MPMediaItemArtwork(image: track.artworkImage!)
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle : track.title,
            MPMediaItemPropertyArtist : track.artist,
            MPMediaItemPropertyArtwork : albumArtWork
        ]
    }
}

//*****************************************************************
// MARK: - Player Controls (Play/Pause/Volume)
//*****************************************************************

private extension NowPlayingViewController {
    @objc func playPressed() {
        track.isPlaying = true
        playButtonEnable(false)
        radioPlayer.play()
        updateLbl()
        
        songLbl.animation = "flash"
        songLbl.animate()
        
        nowPlayingAnimationImg.startAnimating()
        
        self.delegate?.trackPlayingToggled(track: track)
    }
    
    @objc func stopPressed() {
        track.isPlaying = false
        
        playButtonEnable()
        
        radioPlayer.stop()
        updateLbl(statusMessage: "Station Loading...")
        nowPlayingAnimationImg.stopAnimating()
        
        self.delegate?.trackPlayingToggled(track: track)
    }
    
    @objc func changeVolum() {
        mpVolumeSlide.value = voiceSlide.value
    }
}

//******************************************
//  MARK: - setup view and data
//******************************************
private extension NowPlayingViewController {
    
    func setupData() {
        if newStation {
            track = Track()
            stationDidChange()
        } else {
            updateLbl()
            
            if track != nil {
                coverImage.image = track.artworkImage
                if !track.isPlaying {
                    stopPressed()
                } else {
                    nowPlayingAnimationImg.startAnimating()
                    playButtonEnable(false)
                }
            }
        }
    }
    
    func setupPlayer() {
        radioPlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        radioPlayer.view.sizeToFit()
        radioPlayer.movieSourceType = .streaming
        radioPlayer.isFullscreen = false
        radioPlayer.shouldAutoplay = true
        radioPlayer.prepareToPlay()
        radioPlayer.controlStyle = .none
    }
    
    func setupView() {
        self.title = currentStation.name
        setupRightBarBtn()
        setupBackImage()
        
        /// cover image
        coverImage = SpringImageView()
        coverImage.contentMode = .scaleAspectFit
        coverImage.backgroundColor = UIColor.clear
        view.addSubview(coverImage)
        
        desLbl = UILabel()
        desLbl.textColor = UIColor.white
        desLbl.font = UIFont.systemFont(ofSize: 17.0)
        desLbl.textAlignment = .center
        view.addSubview(desLbl)
        
        stopBtn = createButton("btn-pause")
        stopBtn.addTarget(self, action: #selector(stopPressed), for: .touchUpInside)
        
        view.addSubview(stopBtn)
        
        playBtn = createButton("btn-play")
        playBtn.addTarget(self, action: #selector(playPressed), for: .touchUpInside)
        view.addSubview(playBtn)
        
        setupVolumeSlide()
        
        songLbl = SpringLabel()
        songLbl.textColor = UIColor.white
        songLbl.font = UIFont.boldSystemFont(ofSize: 20.0)
        songLbl.textAlignment = .center
        view.addSubview(songLbl)
        
        artistLbl = UILabel()
        artistLbl.textColor = UIColor.white
        artistLbl.font = UIFont.systemFont(ofSize: 17.0)
        artistLbl.textAlignment = .center
        view.addSubview(artistLbl)
        
        swiftLogoBtn = createButton("swift-radio")
        view.addSubview(swiftLogoBtn)
        
        shareBtn = createButton("share")
        view.addSubview(shareBtn)
        
        detailBtn = createButton("icon-info")
        view.addSubview(detailBtn)
        
        coverImage.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(100)
            make.left.equalTo(view).offset(70)
            make.centerX.equalTo(view)
            make.height.equalTo(180)
        }
        
        desLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(coverImage.snp.bottom).offset(-20)
        }
        
        stopBtn.snp.makeConstraints { (make) in
            make.top.equalTo(coverImage.snp.bottom).offset(40)
            make.right.equalTo(coverImage.snp.centerX).offset(-10)
            make.width.height.equalTo(45)
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.top.equalTo(coverImage.snp.bottom).offset(40)
            make.left.equalTo(coverImage.snp.centerX).offset(10)
            make.width.height.equalTo(45)
        }
        
        voiceSlide.snp.makeConstraints { (make) in
            make.top.equalTo(playBtn.snp.bottom).offset(25)
            make.left.equalTo(view).offset(15)
            make.centerX.equalTo(view)
        }
        
        songLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(voiceSlide.snp.bottom).offset(25)
        }
        
        artistLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(songLbl.snp.bottom).offset(10)
        }
        
        swiftLogoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(10)
            make.bottom.equalTo(view.snp.bottom).offset(-10)
            make.width.equalTo(90)
            make.height.equalTo(36)
        }
        
        detailBtn.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-10)
            make.bottom.equalTo(view.snp.bottom).offset(-10)
            make.width.equalTo(22)
            make.height.equalTo(22)
        }
        
        shareBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(detailBtn)
            make.right.equalTo(detailBtn.snp.left).offset(-5)
            make.width.equalTo(detailBtn)
            make.height.equalTo(detailBtn)
        }
    }
    
    func setupVolumeSlide() {
        voiceSlide = UISlider()
        voiceSlide.minimumValueImage = UIImage(named: "vol-min")
        voiceSlide.maximumValueImage = UIImage(named: "vol-max")
        voiceSlide.setThumbImage(UIImage(named: "slider-ball"), for: .normal)
        voiceSlide.addTarget(self, action: #selector(changeVolum), for: .valueChanged)
        view.addSubview(voiceSlide)
        
        let mpVolumView = MPVolumeView()
        for view in mpVolumView.subviews {
            let uiview = view as UIView
            if NSStringFromClass(uiview.classForCoder) == "MPVolumeSlider" {
                mpVolumeSlide = uiview as! UISlider
                
                voiceSlide.value = 0.3
                mpVolumeSlide.value = 0.3
            }
        }
    }
    
    /// 创建背景视图
    func setupBackImage() {
        backImage = UIImageView()
        backImage.image = UIImage(named: "background")
        backImage.isUserInteractionEnabled = true
        view.addSubview(backImage)
        
        backImage.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    func setupRightBarBtn() {
        nowPlayingAnimationImg = UIImageView()
        nowPlayingAnimationImg.image = UIImage(named: "NowPlayingBars-3")
        nowPlayingAnimationImg.autoresizingMask = []
        nowPlayingAnimationImg.contentMode = .center
        
        nowPlayingAnimationImg.animationImages = AnimationFrames.createFrames()
        nowPlayingAnimationImg.animationDuration = 0.7
        
        let rightBarBtn = UIButton(type: .custom)
        rightBarBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightBarBtn.addSubview(nowPlayingAnimationImg)
        nowPlayingAnimationImg.center = rightBarBtn.center
        
        let barItem = UIBarButtonItem(customView: rightBarBtn)
        self.navigationItem.rightBarButtonItem = barItem
    }
}

//******************************************
//  MARK: - Private Method
//******************************************
private extension NowPlayingViewController {
    
    func createButton(_ imageName: String) -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), for: .normal)
//        btn.addTarget(self, action: #selector(playOrStop), for: .touchUpInside)
        return btn
    }
    
    func stationDidChange() {
        radioPlayer.stop()
        radioPlayer.contentURL = URL(string: currentStation.streamURL)
        radioPlayer.prepareToPlay()
        radioPlayer.play()
        
        stopBtn.isEnabled = true
        playBtn.isEnabled = false
        
        updateLbl(statusMessage: "Station Loading...")
        
        songLbl.animation = "flash"
        songLbl.repeatCount = 3
        songLbl.animate()
        
        resetAlbumArtwor()
        
        track.isPlaying = true
    }
    
    func playButtonEnable(_ enable: Bool = true) {
        if enable {
            playBtn.isEnabled = true
            stopBtn.isEnabled = false
            track.isPlaying = false
        } else {
            playBtn.isEnabled = false
            stopBtn.isEnabled = true
            track.isPlaying = true
        }
    }
    
    func updateLbl(statusMessage: String = "") {
        if statusMessage != "" {
            songLbl.text = statusMessage
            artistLbl.text = currentStation.name
            desLbl.text = currentStation.desc
        } else {
            if track != nil {
                songLbl.text = track.title
                artistLbl.text = track.artist
            }
        }
        
        if track != nil && track.artworkLoaded  {
            desLbl.isHidden = true
        } else {
            desLbl.isHidden = false
            desLbl.text = currentStation.desc
        }
    }
    
    func updateAblumArtwork() {
        track.artworkLoaded = false
        
        if track.artworkURL.contains("http") {
            
            DispatchQueue.main.async(execute: {
                self.desLbl.isHidden = true
            })
            
            if let url = URL(string: track.artworkURL) {
                downloadTask = coverImage.loadImageWithURL(url, callback: { (image) in
                    
                    self.track.artworkImage = image
                    self.track.artworkLoaded = true
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    //Animate cover
                    self.coverImage.animation = "wobble"
                    self.coverImage.duration = 2
                    self.coverImage.animate()
                    
                    self.desLbl.isHidden = true
                    
                    self.updateLockScreen()
                    
                    self.delegate?.artworkDidUpdate(track: self.track)
                })
            }
            
            if track.artworkLoaded && !justBecameActive {
                desLbl.isHidden = true
                justBecameActive = false
            }
        } else if track.artworkURL != "" {
            coverImage.image = UIImage(named: track.artworkURL)
            track.artworkImage = coverImage.image
            track.artworkLoaded = true
        } else {
            // No Station or API art found, use default art
            coverImage.image = UIImage(named: "albumArt")
            track.artworkImage = coverImage.image
            
            self.delegate?.artworkDidUpdate(track: track)
        }
        
        view.setNeedsDisplay()
    }
    
    func resetAlbumArtwor() {
        track.artworkLoaded = false
        track.artworkURL = currentStation.imageURL
        updateAblumArtwork()
        desLbl.isHidden = false
    }
    
    func startNowPlayingAnimation() {
        nowPlayingAnimationImg.startAnimating()
    }
    
    func queryAblumArt()  {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let queryURL : String
        if useLastFM {
            queryURL = String(format:"http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=%@&artist=%@&track=%@&format=json", apiKey, track.artist, track.title)
        } else {
            queryURL = String(format: "https://itunes.apple.com/search?term=%@+%@&entity=song", track.artist, track.title)
        }
        
        let escapedURL = queryURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        //Query API
        DataManager.getTrackDataWithSuccess(queryURL: escapedURL!) { (data) in
            if kDebugLog {
                print("API SUCCESSFUL RETURN")
                print("url: \(escapedURL!)")
            }
            
            let json = JSON(data: data! as Data)
            if useLastFM {
                if let imageArray = json["track"]["album"]["image"].array {
                    let arrayCount = imageArray.count
                    let lastImage = imageArray[arrayCount - 1]
                    
                    if let artURL = lastImage["#text"].string {
                        if artURL.range(of: "/noimage/") != nil {
                            self.resetAlbumArtwor()
                        } else {
                            self.track.artworkURL = artURL
                            self.track.artworkLoaded = true
                            self.updateAblumArtwork()
                        }
                    } else {
                        self.resetAlbumArtwor()
                    }
                } else {
                    self.resetAlbumArtwor()
                }
            } else {
                if let artURL = json["results"][0]["artworkUrl100"].string {
                    if kDebugLog { print("iTunes artURL: \(artURL)") }
                    
                    self.track.artworkURL = artURL
                    self.track.artworkLoaded = true
                    self.updateAblumArtwork()
                } else {
                    self.resetAlbumArtwor()
                }
            }
        }
    }
}
