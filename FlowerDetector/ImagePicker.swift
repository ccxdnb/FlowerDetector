//
//  ImagePicker.swift
//  FlowerDetector
//
//  Created by Joaquin Wilson on 19-07-24.
//

import SwiftUI
import CoreML
import Vision

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: ImagePicker

    init(parent: ImagePicker) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[.originalImage] as? UIImage {
            parent.selectedImage = uiImage
            guard let ciimage = CIImage(image: uiImage) else {
                fatalError("could not convert to CIImage")
            }

            detect(image: ciimage)
        }

        parent.presentationMode.wrappedValue.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.presentationMode.wrappedValue.dismiss()
    }

    private func detect(image: CIImage) {
        let configuration = MLModelConfiguration()

        guard let model = try? VNCoreMLModel(for: Oxford102(configuration: configuration).model) else {
            fatalError("Can't load Model")
        }

        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("cant classify image")
            }

            Task {
                let description = try? await self?.getDescription(flowerName: results.first?.identifier ?? "")

                self?.parent.output = .init(
                    name: results.first?.identifier ?? "Can't detect flower",
                    description: description ?? "")
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    private func getDescription(flowerName: String) async throws -> String {
        guard let wikipediaURL = URL(string: "https://en.wikipedia.org/w/api.php") else {
            fatalError("bad request URL")
        }

        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
        ]

        let queryItems = parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }

        var request = URLRequest(url: wikipediaURL)
        request.url?.append(queryItems: queryItems)

        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            let wikiResponse = try JSONDecoder().decode(WikiResponse.self, from: data)
            return wikiResponse.query.pages.first?.value.extract ?? "No description available"
        } catch {
            print("Failed to decode JSON: \(error)")
            return "No description available"
        }
    }
}

struct WikiResponse: Codable {
    struct Query: Codable {
        struct Page: Codable {
            var pageid: Int
            var ns: Int
            var title: String
            var extract: String
        }

        var normalized: [[String:String]]
        var pageids: [String]
        var pages: [String: Page]
    }

    var query: Query
    var batchcomplete: String
}

struct ImagePicker: UIViewControllerRepresentable {
    struct Output {
        var name: String
        var description: String
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    @Binding var output: Output?

    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
