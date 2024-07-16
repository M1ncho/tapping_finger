//
//  TapTrackingController.swift
//  Fingertapping_ios
//
//  Created by KJW on 2023/05/15.
//

import UIKit
import Vision
import AVFoundation
import WebKit
import Alamofire
import AVKit

class TapTrackingController: UIViewController {
    
    @IBOutlet weak var rightHandLabel: UILabel!
    @IBOutlet weak var leftHandLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var countTimerLabel: UILabel!
    @IBOutlet weak var countDownProgress: UIProgressView!
    @IBOutlet weak var tapCountLabel: UILabel!
    
    @IBOutlet weak var sec15Label: UILabel!
    @IBOutlet weak var sec10Label: UILabel!
    @IBOutlet weak var sec5Label: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var sendDataLabel: UILabel!
    @IBOutlet weak var showChartLabel: UILabel!
    
    @IBOutlet weak var delayCountLabel: UILabel!
    @IBOutlet weak var labelsView: UIView!
    
    @IBOutlet weak var webLayoutView: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    
    var userId = 0
    var selectTime = 15
    var count = 0
    var status = "out"
    var handType = 0
    
    var delayTimer: Timer?
    var timer: Timer?
    var timeNum = 0
    var delayNum = 0
    var timeProgress = 0
    
    var startAbsY = 0
    var countOkY = 0
    var inOkY = 0
    
    var tapDetailList: [TappingDetail] = []
    let dateformat = DateFormatter()
    
    private var captureSesstion: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private var overlayThumbLayer = CAShapeLayer()
    
    private var trackQueue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)
    let videoComposition = AVMutableVideoComposition()
    
    var avFormat: AVCaptureDevice.Format? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        

        sec15Label.layer.cornerRadius = 12
        sec15Label.layer.masksToBounds = true
        sec10Label.layer.cornerRadius = 12
        sec10Label.layer.masksToBounds = true
        sec5Label.layer.cornerRadius = 12
        sec5Label.layer.masksToBounds = true
        
        startLabel.layer.cornerRadius = 20
        startLabel.layer.masksToBounds = true
        
        
        // progress 설정
        countDownProgress.progressTintColor = UIColor(named: "carolinaBlue")
        countDownProgress.trackTintColor = UIColor(named: "lightPeach")
        
        
        // camera 설정
        captureSesstion = AVCaptureSession()
        captureSesstion.sessionPreset = .inputPriority
        captureSesstion.beginConfiguration()
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        if captureSesstion.canAddInput(input) {
            captureSesstion.addInput(input)
        }
        
        
        captureDevice.configureDesiredFrameRate(30)
        
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: trackQueue)
        output.alwaysDiscardsLateVideoFrames = true

        
        
        if captureSesstion.canAddOutput(output) {
            captureSesstion.addOutput(output)
        }

        
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSesstion)
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = UIScreen.main.bounds
        }
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.addSublayer(overlayThumbLayer)
        
        
        captureSesstion.commitConfiguration()
        captureSesstion.startRunning()

        
        
        let selectRight = UITapGestureRecognizer(target: self, action: #selector(selectRightHand(recognizer:)))
        rightHandLabel.addGestureRecognizer(selectRight)
        
        let selectLeft = UITapGestureRecognizer(target: self, action: #selector(selectLeftHand(recognizer:)))
        leftHandLabel.addGestureRecognizer(selectLeft)
        
        let sec15Click = UITapGestureRecognizer(target: self, action: #selector(select15Sec(_:)))
        sec15Label.addGestureRecognizer(sec15Click)
        
        let sec10Click = UITapGestureRecognizer(target: self, action: #selector(select10Sec(_:)))
        sec10Label.addGestureRecognizer(sec10Click)
        
        let sec5Click = UITapGestureRecognizer(target: self, action: #selector(select5Sec(_:)))
        sec5Label.addGestureRecognizer(sec5Click)
        
        let startClick = UITapGestureRecognizer(target: self, action: #selector(startTracking(recognizer:)))
        startLabel.addGestureRecognizer(startClick)
    }
    
    
    
    
    
    // MARK: - Objc Function
    // timer 동작 func
    @objc func delayTimerCallback() {
        delayCountLabel.text = "\(delayNum)"
        
        if delayNum == 0 {
            delayTimer?.invalidate()
            delayTimer = nil
            delayCountLabel.isHidden = true
            startTrackingTimer()
        }
        
        delayNum -= 1
    }
    
    @objc func trackingTimerCallback() {
        countTimerLabel.text = "\(timeNum)"
        
        if timeProgress < selectTime {
            countDownProgress.progress = Float(timeProgress) / Float(selectTime)
            timeProgress += 1
        }
        else {
            timer?.invalidate()
            timer = nil
            countDownProgress.progress = 1.0
            labelsView.isHidden = false
            
            print("태핑 데이터 크기 체크 -> \(tapDetailList.count)")
        }
        
        timeNum -= 1
    }
    
    
    @objc func selectRightHand(recognizer: UITapGestureRecognizer) {
        handType = 0
        
        rightHandLabel.backgroundColor = UIColor(named: "darkRoyalBlue")
        rightHandLabel.textColor = UIColor.white
        leftHandLabel.backgroundColor = UIColor(named: "carolinaBlue")
        leftHandLabel.textColor = UIColor(named: "darkGreyBlue")
    }
    
    @objc func selectLeftHand(recognizer: UITapGestureRecognizer) {
        handType = 1
        
        rightHandLabel.backgroundColor = UIColor(named: "carolinaBlue")
        rightHandLabel.textColor = UIColor(named: "darkGreyBlue")
        leftHandLabel.backgroundColor = UIColor(named: "darkRoyalBlue")
        leftHandLabel.textColor = UIColor.white
    }
    
    @objc func select15Sec(_ recognizer: UITapGestureRecognizer) {
        selectTime = 15
        countTimerLabel.text = "\(selectTime)"
        
        sec15Label.backgroundColor = UIColor(named: "darkRoyalBlue")
        sec15Label.textColor = UIColor.white
        sec10Label.backgroundColor = UIColor(named: "lightBlueGrey")
        sec10Label.textColor = UIColor(named: "greyBlue")
        sec5Label.backgroundColor = UIColor(named: "lightBlueGrey")
        sec5Label.textColor = UIColor(named: "greyBlue")
    }
    
    @objc func select10Sec(_ recognizer: UITapGestureRecognizer) {
        selectTime = 10
        countTimerLabel.text = "\(selectTime)"
        
        sec15Label.backgroundColor = UIColor(named: "lightBlueGrey")
        sec15Label.textColor = UIColor(named: "greyBlue")
        sec10Label.backgroundColor = UIColor(named: "darkRoyalBlue")
        sec10Label.textColor = UIColor.white
        sec5Label.backgroundColor = UIColor(named: "lightBlueGrey")
        sec5Label.textColor = UIColor(named: "greyBlue")
    }
    
    @objc func select5Sec(_ recognizer: UITapGestureRecognizer) {
        selectTime = 5
        countTimerLabel.text = "\(selectTime)"
        
        sec15Label.backgroundColor = UIColor(named: "lightBlueGrey")
        sec15Label.textColor = UIColor(named: "greyBlue")
        sec10Label.backgroundColor = UIColor(named: "lightBlueGrey")
        sec10Label.textColor = UIColor(named: "greyBlue")
        sec5Label.backgroundColor = UIColor(named: "darkRoyalBlue")
        sec5Label.textColor = UIColor.white
    }
    
    // tracking srart function
    @objc func startTracking(recognizer: UITapGestureRecognizer) {
        count = 0
        tapCountLabel.text = "\(count)"
        tapDetailList.removeAll()
        
        delayCountLabel.isHidden = false
        labelsView.isHidden = true
        
        startDelayTimer()
    }
    
    
    // MARK: - IBAction Function
    @IBAction func clickWebBack(_ sender: Any) {
        if webLayoutView.isHidden {
            self.dismiss(animated: true)
        }
        else {
            webLayoutView.isHidden = true
        }
    }
    
    
    
    
    
    
    // MARK: - Function
    // land marks 그리기
    func processPoints(_ points: [CGPoint?]) {
        var pointsConverted: [CGPoint] = []
        for point in points {
            pointsConverted.append(videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: point!))
        }
        
        let pointColor = UIColor.green
        let strokeColor = UIColor.red
        let fingerPath = UIBezierPath()
        
        // point 별 dot 그리기
        for tip in pointsConverted {
            fingerPath.move(to: tip)
            fingerPath.addArc(withCenter: tip, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        // point를 이을 line 그리기
        for (index, line) in pointsConverted.enumerated() {
            if index % 4 != 0 && index < 20 {
                fingerPath.move(to: line)
                fingerPath.addLine(to: pointsConverted[index + 1])
            }
            
            if index % 4 == 0 && index < 20 && index > 4 {
                fingerPath.move(to: line)
                fingerPath.addLine(to: pointsConverted[index + 4])
            }
            
            if index == 4 || index == 8 || index == 20 {
                fingerPath.move(to: line)
                fingerPath.addLine(to: pointsConverted[21])
            }
        }
        
        overlayThumbLayer.fillColor = strokeColor.cgColor
        overlayThumbLayer.strokeColor = strokeColor.cgColor
        overlayThumbLayer.lineWidth = 2.5
        overlayThumbLayer.lineCap = .round
        overlayThumbLayer.path = fingerPath.cgPath
    }
    
    // land marks 없애기
    func clearLayout() {
        let emptyPath = UIBezierPath()
        overlayThumbLayer.path = emptyPath.cgPath
    }
    
    // timer 시작
    func startDelayTimer() {
        delayNum = 3
        delayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(delayTimerCallback), userInfo: nil, repeats: true)
    }
    
    func startTrackingTimer() {
        timeNum = selectTime
        timeProgress = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(trackingTimerCallback), userInfo: nil, repeats: true)
    }
    
    
}






// MARK: - Extension
extension TapTrackingController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // vision 값들 얻어오기
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
            
            guard let observation = handPoseRequest.results?.first else {
                DispatchQueue.main.async {
                    self.clearLayout()
                }
                return
            }
            
            let wristPoint = try observation.recognizedPoints(.all)
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexPoints = try observation.recognizedPoints(.indexFinger)
            let middlePoints = try observation.recognizedPoints(.middleFinger)
            let ringPoints = try observation.recognizedPoints(.ringFinger)
            let littlePoints = try observation.recognizedPoints(.littleFinger)
            
            var allPointShort: [VNRecognizedPoint] = []
            let thumbTip = thumbPoints[.thumbTip]!
            let thumbIp = thumbPoints[.thumbIP]!
            let thumbMp = thumbPoints[.thumbMP]!
            let thumbCmc = thumbPoints[.thumbCMC]!
            allPointShort.append(thumbTip)
            allPointShort.append(thumbIp)
            allPointShort.append(thumbMp)
            allPointShort.append(thumbCmc)
            
            let indexTip = indexPoints[.indexTip]!
            let indexDip = indexPoints[.indexDIP]!
            let indexPip = indexPoints[.indexPIP]!
            let indexMcp = indexPoints[.indexMCP]!
            allPointShort.append(indexTip)
            allPointShort.append(indexDip)
            allPointShort.append(indexPip)
            allPointShort.append(indexMcp)
            
            let middleTip = middlePoints[.middleTip]!
            let middleDip = middlePoints[.middleDIP]!
            let middlePip = middlePoints[.middlePIP]!
            let middleMcp = middlePoints[.middleMCP]!
            allPointShort.append(middleTip)
            allPointShort.append(middleDip)
            allPointShort.append(middlePip)
            allPointShort.append(middleMcp)
            
            let ringTip = ringPoints[.ringTip]!
            let ringDip = ringPoints[.ringDIP]!
            let ringPip = ringPoints[.ringPIP]!
            let ringMcp = ringPoints[.ringMCP]!
            allPointShort.append(ringTip)
            allPointShort.append(ringDip)
            allPointShort.append(ringPip)
            allPointShort.append(ringMcp)
            
            let littleTip = littlePoints[.littleTip]!
            let littleDip = littlePoints[.littleDIP]!
            let littlePip = littlePoints[.littlePIP]!
            let littleMcp = littlePoints[.littleMCP]!
            allPointShort.append(littleTip)
            allPointShort.append(littleDip)
            allPointShort.append(littlePip)
            allPointShort.append(littleMcp)
            
            let wrist = wristPoint[.wrist]!
            allPointShort.append(wrist)
            
            
            var pointConverted = [CGPoint]()
            var marks = [CGPoint()]
            
            for item in allPointShort {
                let tip = CGPoint(x: item.location.x, y: 1 - item.location.y)
                marks.append(tip)
                
                pointConverted.append(videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: tip))
            }
            
            
            DispatchQueue.main.async {
                self.processPoints(marks)
            }
            
            
            // count 여부 확인 용도
            let intervalCY = abs(Int(thumbTip.location.y * 100) - Int(indexTip.location.y * 100))
            let countCY = Int((Float(intervalCY) / 10) * 9)
            let inCY = intervalCY / 10
            
            
            if delayTimer != nil {
                startAbsY = intervalCY
                countOkY = countCY
                inOkY = inCY
            }
            
            //print("max height check = \(startAbsY)")
            
            
            if timer != nil {
                if intervalCY <= inOkY {
                    status = "in"
                }
                if intervalCY >= countOkY && status == "in" {
                    status = "out"
                    count += 1
                    
                    DispatchQueue.main.async {
                        self.tapCountLabel.text = "\(self.count)"
                    }
                }
                
                
                let detailData = TappingDetail()
                detailData.time = dateformat.string(from: Date())
                detailData.thumb_x = thumbTip.location.x * 100
                detailData.thumb_y = thumbTip.location.y * 100
                detailData.thumb_z = 0.0
                detailData.index_x = indexTip.location.x * 100
                detailData.index_y = indexTip.location.y * 100
                detailData.index_z = 0.0
                tapDetailList.append(detailData)
            }
            
        }  catch { print("에러") }
    }
    
}


// camera 관련
extension AVCaptureDevice {
    
    func configureDesiredFrameRate(_ desiredFrameRate: Int) {
        var isFPS = false
        
        do {
            if let videoSupportFrameRange = activeFormat.videoSupportedFrameRateRanges as? [AVFrameRateRange] {
                for range in videoSupportFrameRange {
                    if range.maxFrameRate >= Double(desiredFrameRate) && range.minFrameRate <= Double(desiredFrameRate) {
                        isFPS = true
                        break
                    }
                }
            }
            
            
            if isFPS {
                try lockForConfiguration()
                
                activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(desiredFrameRate))
                activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(desiredFrameRate))
                unlockForConfiguration()
            }
            
        } catch {
            print("lockForConfiguration error: \(error.localizedDescription)")
        }
        
    }
    
}
