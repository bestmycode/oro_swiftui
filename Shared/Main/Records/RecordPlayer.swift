//
//  RecordPlayer.swift
//  ORO (iOS)
//
//  Created by MAC on 2022/11/18.
//

import SwiftUI
import Speech

struct RecordPlayer: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selection: Int? = 0
    @State private var isShowingTranscribeProgress: Bool = false
    @State private var transcribeProgress: Bool = false
    @State private var audioText: String = ""
    var audioURL: URL
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack {
                    Button(action: {
                           self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color(red: 0.576, green: 0.62, blue: 0.678))
                                .padding()
                        }
                    Spacer()
                    NavigationLink(destination: RecordEdit().navigationBarHidden(true), tag: 1, selection: $selection) {
                        Button(action: {
                                self.selection = 1
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(Color(red: 0.576, green: 0.62, blue: 0.678))
                                    .padding()
                            }
                    }
                }
                .padding()
                if(!transcribeProgress) {
                    VStack {
                        Image("audio_player")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 310, height: 310)
                            .foregroundColor(.white)
                            .cornerRadius(20)
        //                GifImage("audio_player")
                        VStack {
                            Text("\(audioURL.lastPathComponent)")
                                .font(.system(size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                            Text("Folder: Work Records")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.576, green: 0.62, blue: 0.678))
                        }.padding()
                        Spacer()
                    }
                } else {
                    VStack {
                        ScrollView {
                            Text("\(audioText)")
                                .lineLimit(nil)
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                .lineSpacing(16)
                                .padding()
                        }
                        Spacer()
                    }
                }
                AudioPlayerView(audioURL: audioURL).padding()
                HStack {
                    Button(action: {
                        if(!isShowingTranscribeProgress && !transcribeProgress) {
                            isShowingTranscribeProgress.toggle()
                        }
                    }) {
                        HStack {
                            Image("audio_text_inactive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .padding()
                            Text("Transcribe\nAudio")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color(red: 0.576, green: 0.62, blue: 0.678))
                        }
                    }
                    .fullScreenCover(isPresented: $isShowingTranscribeProgress) {
                        TranscriptionProcess(isProgress: $transcribeProgress, isShowing: $isShowingTranscribeProgress)
                    }
                    Spacer()
                    Button(action: {
                           
                    }) {
                        HStack {
                            Text("Create\nAudiogram")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color(red: 0.337, green: 0.718, blue: 0.902))
                            Image("audio_active")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .padding()
                        }
                    }
                }.padding()
            }
        }
        .background(Color(red: 0.949, green: 0.957, blue: 0.98))
        .onAppear(perform: requestTranscribePermissions)
    }

    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                    transcribeAudio(url: audioURL)
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }

    func transcribeAudio(url: URL) {
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        recognizer?.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }
            if result.isFinal {
                print(result.bestTranscription.formattedString)
                self.audioText = result.bestTranscription.formattedString
            }
        }
    }
}

struct RecordPlayer_Previews: PreviewProvider {
    static var previews: some View {
        RecordPlayer(audioURL: URL(string: "")!)
    }
}
