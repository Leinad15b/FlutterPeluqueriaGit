import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class HairAiService {
  static const String _apiToken = ;

  static const String _apiUrl =
      "https://api-inference.huggingface.co/models/runwayml/stable-diffusion-inpainting";

  Future<Uint8List?> generateNewHair({
    required List<int> imageBytes,
    required List<int> maskBytes,
    required String promptText,
  }) async {
    try {
      String base64Image = base64Encode(imageBytes);
      String base64Mask = base64Encode(maskBytes);

      var body = jsonEncode({
        "inputs": {
          "image": base64Image,
          "mask_image": base64Mask,
          "prompt":
              "hairstyle, $promptText, realistic photo, 8k, professional lighting",
          "negative_prompt":
              "ugly, blurry, low quality, distorted face, bad anatomy, extra fingers",
          "guidance_scale": 7.5,
          "num_inference_steps": 25,
        }
      });

      var response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_apiToken",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print("Error API (${response.statusCode}): ${response.body}");
        throw "Error del servidor: ${response.statusCode}";
      }
    } catch (e) {
      print("Excepción en el servicio AI: $e");
      rethrow;
    }
  }
}
