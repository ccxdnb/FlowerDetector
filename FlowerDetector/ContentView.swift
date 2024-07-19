//
//  ContentView.swift
//  FlowerDetector
//
//  Created by Joaquin Wilson on 19-07-24.
//

import SwiftUI
import UIKit
import CoreML
import Vision

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var output: ImagePicker.Output?
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.gray)
            }
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Name:")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(output?.name ?? "Nothig yet...")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)


                    Text("Description:")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(output?.description ?? "")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }.padding()
            }
            Spacer()
            HStack {
                Button("Camera") {
                    sourceType = .camera
                    isImagePickerPresented = true
                }
                .padding()
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                Button("Photo Library") {
                    sourceType = .photoLibrary
                    isImagePickerPresented = true
                }
                .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, output: $output, sourceType: sourceType)
        }
    }
}

#Preview {
    ContentView()
}
