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

    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                } else {

                    VStack {
                        Spacer()
                        Image(systemName: "camera.macro")
                            .resizable()
                            .foregroundStyle(Color.fwLightPink)
                            .padding(60)
                            .frame(width: 300, height: 300)
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(Color.fwLightPink.opacity(0.94))

                    ScrollView {
                        Text(output?.name ?? "")
                            .foregroundStyle(Color.fwPurple)
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(output?.description ?? "Open camera and take a picture of a flower")
                            .font(.subheadline)                       .foregroundStyle(Color.fwGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    .padding(15)
                }
                .padding(30)

                HStack {
                    VStack {
                        Button() {
                            isImagePickerPresented = true
                        } label: {
                            Image(systemName: "camera")
                                .tint(Color.fwLightPink)
                                .font(.largeTitle)
                        }
                        .offset(y: 10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(LinearGradient(colors: [.fwLightPink, .fwPurple, .fwLightPink], startPoint: .leading, endPoint: .trailing).opacity(0.9))

            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, output: $output, sourceType: .camera)
            }
        }
    }
}

#Preview {
    ContentView()
}
