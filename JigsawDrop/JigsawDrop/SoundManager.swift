import Foundation
import AVFoundation
import UIKit
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var layeredAudioPlayers: [AudioLayer: [String: AVAudioPlayer]] = [:]
    private var systemSounds: [String: SystemSoundID] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    private var isSoundEnabled = true
    private var isHapticEnabled = true
    private var isMusicEnabled = true
    private var musicVolume: Float = 0.3 // Lower volume for background music
    private var ambientVolume: Float = 0.2
    private var currentComboMultiplier: Int = 1
    private var adaptiveMusicLayers: [AVAudioPlayer] = []
    
    // Sound effect names
    enum SoundEffect: String, CaseIterable {
        case piecePlacement = "piece_placement"
        case rowCompletion = "row_completion"
        case pieceRotation = "piece_rotation"
        case buttonTap = "button_tap"
        case gameOver = "game_over"
        case incorrectPlacement = "incorrect_placement"
        case pieceSpawn = "piece_spawn"
        case perfectPlacement = "perfect_placement"
        case comboMultiplier = "combo_multiplier"
        case themeChange = "theme_change"
        case levelUp = "level_up"
        case magneticSnap = "magnetic_snap"
        case ambientWind = "ambient_wind"
        case ambientWater = "ambient_water"
        case ambientForest = "ambient_forest"
    }
    
    // Audio layers for advanced mixing
    enum AudioLayer {
        case ambient      // Background atmosphere
        case music        // Melodic background music
        case interface    // UI interaction sounds
        case gameplay     // Game mechanic sounds
        case feedback     // Success/failure audio
    }
    
    // Haptic feedback types
    enum HapticType {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
    }
    
    private init() {
        setupAudioSession()
        setupSystemSounds()
        preloadHighQualitySounds()
        setupBackgroundMusic()
        setupAdaptiveMusicSystem()
        setupAmbientSounds()
        loadSettings()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupSystemSounds() {
        // Map certain sounds to high-quality iOS system sounds
        systemSounds[SoundEffect.buttonTap.rawValue] = 1104 // Modern click sound
        systemSounds[SoundEffect.incorrectPlacement.rawValue] = 1053 // Error sound
    }
    
    private func preloadHighQualitySounds() {
        for soundEffect in SoundEffect.allCases {
            // Skip sounds that use system sounds
            if systemSounds[soundEffect.rawValue] == nil {
                createHighQualityAudioPlayer(for: soundEffect)
            }
        }
    }
    
    private func createHighQualityAudioPlayer(for soundEffect: SoundEffect) {
        let audioData: Data?
        
        switch soundEffect {
        case .piecePlacement:
            // Pleasant bell-like sound with harmonics
            audioData = generateBellSound(frequency: 523.25, duration: 0.3) // C note
        case .rowCompletion:
            // Triumphant major chord
            audioData = generateChordSound(frequencies: [523.25, 659.25, 783.99], duration: 0.6) // C major chord
        case .pieceRotation:
            // Quick chirp sound
            audioData = generateChirpSound(startFreq: 440, endFreq: 660, duration: 0.15)
        case .gameOver:
            // Dramatic descending tone
            audioData = generateDescendingTone(startFreq: 440, endFreq: 220, duration: 1.0)
        case .pieceSpawn:
            // Bright ascending arpeggio
            audioData = generateArpeggioSound(baseFreq: 440, duration: 0.4)
        case .perfectPlacement:
            // Triumphant perfect fifth chord
            audioData = generateChordSound(frequencies: [523.25, 783.99, 1046.50], duration: 0.8)
        case .comboMultiplier:
            // Rising harmonic series
            audioData = generateHarmonicSeries(baseFreq: 220, harmonics: 5, duration: 0.6)
        case .themeChange:
            // Magical transformation sound
            audioData = generateTransformationSound(duration: 1.2)
        case .levelUp:
            // Victory fanfare
            audioData = generateFanfareSound(duration: 1.5)
        case .magneticSnap:
            // Quick magnetic click
            audioData = generateMagneticSound(duration: 0.2)
        case .ambientWind, .ambientWater, .ambientForest:
            // Ambient sounds handled separately
            audioData = generateAmbientBase(type: soundEffect, duration: 10.0)
        default:
            // Fallback to simple tone for other sounds
            audioData = generateEnhancedTone(frequency: 440, duration: 0.2)
        }
        
        if let data = audioData {
            do {
                let player = try AVAudioPlayer(data: data)
                player.prepareToPlay()
                audioPlayers[soundEffect.rawValue] = player
            } catch {
                print("Failed to create high-quality audio player for \(soundEffect): \(error)")
            }
        }
    }
    
    private func setupBackgroundMusic() {
        guard let musicData = generateBackgroundMusic() else {
            print("Failed to generate background music")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(data: musicData)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = musicVolume
            backgroundMusicPlayer?.prepareToPlay()
        } catch {
            print("Failed to setup background music player: \(error)")
        }
    }
    
    // MARK: - High-Quality Sound Generation
    
    private func generateBellSound(frequency: Float, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let envelope = exp(-t * 3.0) // Exponential decay like a bell
            
            // Combine fundamental frequency with harmonics for rich bell sound
            let fundamental = sin(2.0 * Float.pi * frequency * t)
            let harmonic2 = sin(2.0 * Float.pi * frequency * 2.0 * t) * 0.3
            let harmonic3 = sin(2.0 * Float.pi * frequency * 3.0 * t) * 0.1
            
            let sample = (fundamental + harmonic2 + harmonic3) * envelope * 0.7
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateChordSound(frequencies: [Float], duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let envelope = 1.0 - (t / Float(duration)) // Linear fade out
            
            var combinedSample: Float = 0.0
            for frequency in frequencies {
                combinedSample += sin(2.0 * Float.pi * frequency * t)
            }
            combinedSample /= Float(frequencies.count) // Normalize
            combinedSample *= envelope * 0.8
            
            let scaledSample = Int16(combinedSample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateChirpSound(startFreq: Float, endFreq: Float, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let progress = t / Float(duration)
            let currentFreq = startFreq + (endFreq - startFreq) * progress
            let envelope = 1.0 - progress // Fade out
            
            let sample = sin(2.0 * Float.pi * currentFreq * t) * envelope * 0.6
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateDescendingTone(startFreq: Float, endFreq: Float, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let progress = t / Float(duration)
            let currentFreq = startFreq * pow(endFreq / startFreq, progress)
            let envelope = 1.0 - progress * 0.5 // Gradual fade
            
            let sample = sin(2.0 * Float.pi * currentFreq * t) * envelope * 0.5
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateArpeggioSound(baseFreq: Float, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        let notes = [1.0, 1.25, 1.5, 2.0] // Major arpeggio ratios
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let noteIndex = Int(t / Float(duration) * Float(notes.count))
            let clampedIndex = min(noteIndex, notes.count - 1)
            let frequency = baseFreq * Float(notes[clampedIndex])
            let envelope = sin(Float.pi * t / Float(duration)) // Sine envelope
            
            let sample = sin(2.0 * Float.pi * frequency * t) * envelope * 0.4
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateEnhancedTone(frequency: Float, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let envelope = sin(Float.pi * t / Float(duration)) // Smooth sine envelope
            
            // Add some harmonics for richness
            let fundamental = sin(2.0 * Float.pi * frequency * t)
            let harmonic = sin(2.0 * Float.pi * frequency * 2.0 * t) * 0.2
            
            let sample = (fundamental + harmonic) * envelope * 0.6
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    // MARK: - Background Music Generation
    
    private func generateBackgroundMusic() -> Data? {
        let sampleRate: Float = 44100
        let duration: TimeInterval = 16.0 // 16-second loop
        let _ = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        // Define a simple, catchy chord progression in C major
        // C - Am - F - G (vi-IV-I-V progression, very pleasant and familiar)
        let chordProgression: [(frequencies: [Float], duration: Float)] = [
            // C major chord (C-E-G)
            ([261.63, 329.63, 392.00], 4.0),
            // A minor chord (A-C-E)
            ([220.00, 261.63, 329.63], 4.0),
            // F major chord (F-A-C)
            ([174.61, 220.00, 261.63], 4.0),
            // G major chord (G-B-D)
            ([196.00, 246.94, 293.66], 4.0)
        ]
        
        var currentTime: Float = 0.0
        
        for (chordInfo) in chordProgression {
            let chordDuration = chordInfo.duration
            let chordSamples = Int(sampleRate * chordDuration)
            
            for i in 0..<chordSamples {
                let t = currentTime + Float(i) / sampleRate
                let _ = Float(i) / Float(chordSamples)
                
                // Gentle envelope for smooth transitions
                let envelope = 0.5 + 0.3 * sin(2.0 * Float.pi * t * 0.25) // Slow breathing effect
                
                var combinedSample: Float = 0.0
                
                // Add each note in the chord with some variation
                for (index, frequency) in chordInfo.frequencies.enumerated() {
                    let noteVolume = 1.0 / Float(chordInfo.frequencies.count)
                    let phaseShift = Float(index) * 0.1 // Slight phase shifts for richness
                    let note = sin(2.0 * Float.pi * frequency * (t + phaseShift)) * noteVolume
                    
                    // Add a subtle arpeggio effect
                    let arpeggioOffset = sin(2.0 * Float.pi * t * 0.5 + Float(index) * 2.0) * 0.1
                    combinedSample += note * (1.0 + arpeggioOffset)
                }
                
                // Add a gentle melody line on top
                let melodyNote = getMelodyNote(at: t)
                let melodyVolume: Float = 0.3
                combinedSample += sin(2.0 * Float.pi * melodyNote * t) * melodyVolume
                
                // Apply envelope and normalize
                combinedSample *= envelope * 0.2 // Keep it quiet for background
                let scaledSample = Int16(combinedSample * 32767)
                
                withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                    audioData.append(contentsOf: bytes)
                }
            }
            
            currentTime += chordDuration
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func getMelodyNote(at time: Float) -> Float {
        // Simple pentatonic melody that works over any chord
        let melodyNotes: [Float] = [523.25, 587.33, 659.25, 783.99, 880.00] // C, D, E, G, A
        let noteIndex = Int(time * 0.5) % melodyNotes.count
        return melodyNotes[noteIndex]
    }
    
    // MARK: - Advanced Sound Generation
    
    private func generateHarmonicSeries(baseFreq: Float, harmonics: Int, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let envelope = 1.0 - (t / Float(duration)) * 0.7 // Gentle fade
            
            var combinedSample: Float = 0.0
            for harmonic in 1...harmonics {
                let frequency = baseFreq * Float(harmonic)
                let amplitude = 1.0 / Float(harmonic) // Decreasing amplitude for higher harmonics
                combinedSample += sin(2.0 * Float.pi * frequency * t) * amplitude
            }
            
            combinedSample *= envelope * 0.3
            let scaledSample = Int16(combinedSample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateTransformationSound(duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let progress = t / Float(duration)
            
            // Morphing frequency sweep
            let startFreq: Float = 220
            let endFreq: Float = 880
            let currentFreq = startFreq * pow(endFreq / startFreq, progress)
            
            // Add shimmer effect
            let shimmer = sin(2.0 * Float.pi * currentFreq * 3.0 * t) * 0.3 * sin(Float.pi * progress)
            let fundamental = sin(2.0 * Float.pi * currentFreq * t)
            
            let envelope = sin(Float.pi * progress) // Bell curve envelope
            let sample = (fundamental + shimmer) * envelope * 0.4
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateFanfareSound(duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        // Fanfare chord progression: C - F - G - C
        let chords: [[Float]] = [
            [261.63, 329.63, 392.00], // C major
            [174.61, 220.00, 261.63], // F major
            [196.00, 246.94, 293.66], // G major
            [261.63, 329.63, 392.00, 523.25] // C major octave
        ]
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let progress = t / Float(duration)
            let chordIndex = min(Int(progress * Float(chords.count)), chords.count - 1)
            let chord = chords[chordIndex]
            
            var combinedSample: Float = 0.0
            for frequency in chord {
                combinedSample += sin(2.0 * Float.pi * frequency * t) / Float(chord.count)
            }
            
            // Triumphant envelope
            let envelope = sin(Float.pi * progress) * (1.0 + progress * 0.5)
            let sample = combinedSample * envelope * 0.5
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateMagneticSound(duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            let progress = t / Float(duration)
            
            // Quick snap with metallic overtones
            let frequency: Float = 800 + 400 * (1.0 - progress)
            let metallic = sin(2.0 * Float.pi * frequency * 2.5 * t) * 0.3
            let fundamental = sin(2.0 * Float.pi * frequency * t)
            
            let envelope = exp(-progress * 8.0) // Sharp decay
            let sample = (fundamental + metallic) * envelope * 0.6
            let scaledSample = Int16(sample * 32767)
            
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func generateAmbientBase(type: SoundEffect, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            var sample: Float = 0.0
            
            switch type {
            case .ambientWind:
                // Wind-like noise with filtering
                sample = Float.random(in: -1...1) * 0.1
                sample *= sin(2.0 * Float.pi * t * 0.1) // Slow modulation
            case .ambientWater:
                // Water-like bubbling
                sample = sin(2.0 * Float.pi * 80 * t + sin(2.0 * Float.pi * 3 * t)) * 0.05
                sample += Float.random(in: -0.02...0.02) // Gentle noise
            case .ambientForest:
                // Forest-like rustling
                sample = Float.random(in: -1...1) * 0.03
                sample *= sin(2.0 * Float.pi * t * 0.05) // Very slow modulation
            default:
                sample = 0.0
            }
            
            let scaledSample = Int16(sample * 32767)
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    // MARK: - Adaptive Music System
    
    private func setupAdaptiveMusicSystem() {
        // Create multiple music layers that can be mixed dynamically
        for i in 0..<4 {
            if let layerData = generateMusicLayer(layer: i) {
                do {
                    let player = try AVAudioPlayer(data: layerData)
                    player.numberOfLoops = -1
                    player.volume = 0.0 // Start silent
                    player.prepareToPlay()
                    adaptiveMusicLayers.append(player)
                } catch {
                    print("Failed to create adaptive music layer \(i): \(error)")
                }
            }
        }
    }
    
    private func generateMusicLayer(layer: Int) -> Data? {
        // Generate different musical layers (bass, harmony, melody, percussion)
        let sampleRate: Float = 44100
        let duration: TimeInterval = 16.0
        let samples = Int(sampleRate * Float(duration))
        var audioData = Data()
        
        for i in 0..<samples {
            let t = Float(i) / sampleRate
            var sample: Float = 0.0
            
            switch layer {
            case 0: // Bass layer
                sample = sin(2.0 * Float.pi * 65.41 * t) * 0.3 // Low C
            case 1: // Harmony layer
                sample = sin(2.0 * Float.pi * 261.63 * t) * 0.2 // Middle C
            case 2: // Melody layer
                let melodyFreq = getMelodyNote(at: t)
                sample = sin(2.0 * Float.pi * melodyFreq * t) * 0.15
            case 3: // Ambient layer
                sample = Float.random(in: -0.05...0.05) * sin(2.0 * Float.pi * t * 0.1)
            default:
                sample = 0.0
            }
            
            let scaledSample = Int16(sample * 32767)
            withUnsafeBytes(of: scaledSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        let wavHeader = createWAVHeader(dataSize: audioData.count, sampleRate: Int(sampleRate))
        return wavHeader + audioData
    }
    
    private func setupAmbientSounds() {
        // Setup ambient sound based on current theme
        // This will be called when theme changes
    }
    
    private func createWAVHeader(dataSize: Int, sampleRate: Int) -> Data {
        var header = Data()
        
        // RIFF header
        header.append("RIFF".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(36 + dataSize).littleEndian) { Data($0) })
        header.append("WAVE".data(using: .ascii)!)
        
        // Format chunk
        header.append("fmt ".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // PCM
        header.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // Mono
        header.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt32(sampleRate * 2).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })
        
        // Data chunk
        header.append("data".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        return header
    }
    
    // MARK: - Public Methods
    
    func playSound(_ soundEffect: SoundEffect) {
        guard isSoundEnabled else { return }
        
        // Use system sound if available (higher quality)
        if let systemSoundID = systemSounds[soundEffect.rawValue] {
            AudioServicesPlaySystemSound(systemSoundID)
        } else {
            // Use custom high-quality synthesized sound
            audioPlayers[soundEffect.rawValue]?.stop()
            audioPlayers[soundEffect.rawValue]?.currentTime = 0
            audioPlayers[soundEffect.rawValue]?.play()
        }
    }
    
    func playHaptic(_ type: HapticType) {
        guard isHapticEnabled else { return }
        
        switch type {
        case .light:
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        case .medium:
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        case .heavy:
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        case .success:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        case .warning:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.warning)
        case .error:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        }
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "SoundEnabled")
    }
    
    func setHapticEnabled(_ enabled: Bool) {
        isHapticEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "HapticEnabled")
    }
    
    func loadSettings() {
        isSoundEnabled = UserDefaults.standard.object(forKey: "SoundEnabled") as? Bool ?? true
        isHapticEnabled = UserDefaults.standard.object(forKey: "HapticEnabled") as? Bool ?? true
        isMusicEnabled = UserDefaults.standard.object(forKey: "MusicEnabled") as? Bool ?? true
        musicVolume = UserDefaults.standard.object(forKey: "MusicVolume") as? Float ?? 0.3
        
        // Apply music settings
        backgroundMusicPlayer?.volume = musicVolume
        if isMusicEnabled {
            startBackgroundMusic()
        }
    }
    
    var soundEnabled: Bool {
        return isSoundEnabled
    }
    
    var hapticEnabled: Bool {
        return isHapticEnabled
    }
    
    var musicEnabled: Bool {
        return isMusicEnabled
    }
    
    var currentMusicVolume: Float {
        return musicVolume
    }
    
    // MARK: - Background Music Control
    
    func startBackgroundMusic() {
        guard isMusicEnabled, let player = backgroundMusicPlayer else { return }
        if !player.isPlaying {
            player.play()
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "MusicEnabled")
        
        if enabled {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0.0, min(1.0, volume)) // Clamp between 0 and 1
        UserDefaults.standard.set(musicVolume, forKey: "MusicVolume")
        backgroundMusicPlayer?.volume = musicVolume
    }
    
    // MARK: - Toggle Methods
    
    func toggleSound() {
        setSoundEnabled(!isSoundEnabled)
    }
    
    func toggleMusic() {
        setMusicEnabled(!isMusicEnabled)
    }
    
    func toggleHaptic() {
        setHapticEnabled(!isHapticEnabled)
    }
    
    // MARK: - Advanced Audio Features
    
    func playLayeredAudio(layer: AudioLayer, sound: SoundEffect, volume: Float = 1.0) {
        guard isSoundEnabled else { return }
        
        if layeredAudioPlayers[layer] == nil {
            layeredAudioPlayers[layer] = [:]
        }
        
        let key = sound.rawValue
        layeredAudioPlayers[layer]?[key]?.stop()
        layeredAudioPlayers[layer]?[key]?.currentTime = 0
        layeredAudioPlayers[layer]?[key]?.volume = volume
        layeredAudioPlayers[layer]?[key]?.play()
    }
    
    func setAdaptiveMusicIntensity(completionPercentage: Float) {
        guard isMusicEnabled else { return }
        
        // Gradually introduce music layers based on completion
        for (index, player) in adaptiveMusicLayers.enumerated() {
            let threshold = Float(index) / Float(adaptiveMusicLayers.count)
            let targetVolume = completionPercentage > threshold ? musicVolume * 0.7 : 0.0
            
            // Smooth volume transition
            player.setVolume(targetVolume, fadeDuration: 2.0)
            
            if targetVolume > 0 && !player.isPlaying {
                player.play()
            }
        }
    }
    
    func playComboSound(multiplier: Int) {
        currentComboMultiplier = multiplier
        
        if multiplier > 1 {
            playSound(.comboMultiplier)
            
            // Enhanced haptic for combos
            if multiplier >= 5 {
                playHaptic(.heavy)
            } else if multiplier >= 3 {
                playHaptic(.medium)
            } else {
                playHaptic(.light)
            }
        }
    }
    
    func playCustomHapticPattern(pattern: [Float], intensities: [Float]) {
        guard isHapticEnabled else { return }
        
        for (index, duration) in pattern.enumerated() {
            let intensity = intensities.count > index ? intensities[index] : 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(duration)) {
                if intensity > 0.7 {
                    self.playHaptic(.heavy)
                } else if intensity > 0.4 {
                    self.playHaptic(.medium)
                } else {
                    self.playHaptic(.light)
                }
            }
        }
    }
    
    func createHapticMelody(notes: [Float]) {
        guard isHapticEnabled else { return }
        
        for (index, note) in notes.enumerated() {
            let delay = TimeInterval(index) * 0.2
            let intensity = note / 880.0 // Normalize to 0-1 range
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if intensity > 0.7 {
                    self.playHaptic(.heavy)
                } else if intensity > 0.4 {
                    self.playHaptic(.medium)
                } else {
                    self.playHaptic(.light)
                }
            }
        }
    }
    
    func startThemeAmbientSound(theme: String) {
        // Stop current ambient sound
        ambientPlayer?.stop()
        
        var ambientType: SoundEffect
        switch theme.lowercased() {
        case "ocean":
            ambientType = .ambientWater
        case "forest", "nature":
            ambientType = .ambientForest
        default:
            ambientType = .ambientWind
        }
        
        if let ambientData = generateAmbientBase(type: ambientType, duration: 30.0) {
            do {
                ambientPlayer = try AVAudioPlayer(data: ambientData)
                ambientPlayer?.numberOfLoops = -1
                ambientPlayer?.volume = ambientVolume
                ambientPlayer?.play()
            } catch {
                print("Failed to start ambient sound: \(error)")
            }
        }
    }
} 