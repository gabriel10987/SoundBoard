//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Gabriel Anderson Ccama Apaza on 9/10/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoGrabacionLabel: UILabel!
    @IBOutlet weak var volumenSlider: UISlider!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer: Timer?
    var tiempoGrabacion: TimeInterval = 0
    var duracionFinal: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        tiempoGrabacionLabel.text = "0:00"
        volumenSlider.isEnabled = false
    }
    
    func configurarGrabacion() {
        do{
            // creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            // impresion de ruta donde se guardan los archivos
            print("********************")
            print(audioURL!)
            print("********************")
            
            // crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject
            
            // crear el objeto de grabación de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // detener la grabación
            grabarAudio?.stop()
            timer?.invalidate()
            
            do {
                let reproductorTemporal = try AVAudioPlayer(contentsOf: audioURL!)
                duracionFinal = reproductorTemporal.duration
            } catch {
                print("Error al obtener la duración del audio: \(error)")
            }
            
            // cambiar texto del boton grabar
            grabarButton.setTitle("Grabar", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            // empezar a grabar
            grabarAudio?.record()
            // cambiar el texto del boton grbaar a detener
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled = false
            agregarButton.isEnabled = false
            iniciarTemporizador()
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
            volumenSlider.isEnabled = true
        } catch {}
    }
    
    @IBAction func volumenCambiado(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = duracionFinal
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    func iniciarTemporizador() {
        tiempoGrabacion = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempo), userInfo: nil, repeats: true)
    }
    
    @objc func actualizarTiempo() {
        tiempoGrabacion += 1
        let minutos = Int(tiempoGrabacion) / 60
        let segundos = Int (tiempoGrabacion) % 60
        tiempoGrabacionLabel.text = String(format: "%d:%02d", minutos, segundos)
    }
    
}


