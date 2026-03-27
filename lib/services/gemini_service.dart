import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // Load API keys from .env file
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static Future<Map<String, dynamic>> _generateContent({
    required String prompt,
    String? imageBase64,
    String? imageMimeType,
    Map<String, dynamic>? responseSchema,
  }) async {
    // Check if API keys are configured
    if (_geminiApiKey.isEmpty || _geminiApiKey == 'your_gemini_api_key_here') {
      if (_groqApiKey.isEmpty || _groqApiKey == 'your_groq_api_key_here') {
        throw Exception(
          'No AI API key configured. Please:\n'
          '1. Visit https://aistudio.google.com/app/apikey (Gemini)\n'
          '   OR https://console.groq.com/keys (Groq)\n'
          '2. Create a free API key\n'
          '3. Add it to your .env file'
        );
      }
      // Only Groq available
      return _generateWithGroq(prompt: prompt, responseSchema: responseSchema);
    }

    // Try Gemini first
    try {
      return await _generateWithGemini(
        prompt: prompt,
        imageBase64: imageBase64,
        imageMimeType: imageMimeType,
        responseSchema: responseSchema,
      );
    } catch (e) {
      final errorStr = e.toString();
      
      // If Gemini quota exceeded and Groq is available, fallback to Groq
      if ((errorStr.contains('QUOTA_EXCEEDED') ||
           errorStr.contains('RESOURCE_EXHAUSTED') || 
           errorStr.contains('Quota exceeded') ||
           errorStr.contains('quota exceeded') ||
           errorStr.contains('429')) && 
          _groqApiKey.isNotEmpty && 
          _groqApiKey != 'your_groq_api_key_here') {
        
        print('🔄 Gemini quota exceeded, switching to Groq API...');
        
        // Groq doesn't support images, so skip if image is provided
        if (imageBase64 != null) {
          throw Exception(
            'Gemini API quota exceeded and Groq doesn\'t support image analysis.\n'
            'Please wait a few minutes and try again.'
          );
        }
        
        return _generateWithGroq(prompt: prompt, responseSchema: responseSchema);
      }
      
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _generateWithGemini({
    required String prompt,
    String? imageBase64,
    String? imageMimeType,
    Map<String, dynamic>? responseSchema,
  }) async {
    final parts = <Map<String, dynamic>>[];

    if (imageBase64 != null) {
      parts.add({
        'inline_data': {
          'mime_type': imageMimeType ?? 'image/jpeg',
          'data': imageBase64,
        }
      });
    }

    parts.add({'text': prompt});

    final body = <String, dynamic>{
      'contents': [
        {'parts': parts}
      ],
    };

    if (responseSchema != null) {
      body['generationConfig'] = {
        'response_mime_type': 'application/json',
        'response_schema': responseSchema,
      };
    }

    final response = await http.post(
      Uri.parse('$_geminiBaseUrl?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final errorBody = response.body;
      
      // Check for quota exceeded error
      if (errorBody.contains('RESOURCE_EXHAUSTED') || 
          errorBody.contains('Quota exceeded') ||
          response.statusCode == 429) {
        throw Exception(
          'QUOTA_EXCEEDED: Gemini API quota exceeded. The free tier has limits:\n'
          '• 15 requests per minute\n'
          '• 1,500 requests per day'
        );
      }
      
      throw Exception('Gemini API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final text =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

    if (responseSchema != null) {
      return jsonDecode(text);
    }
    return {'text': text};
  }

  static Future<Map<String, dynamic>> _generateWithGroq({
    required String prompt,
    Map<String, dynamic>? responseSchema,
  }) async {
    final body = {
      'model': 'llama-3.3-70b-versatile',
      'messages': [
        {
          'role': 'user',
          'content': responseSchema != null
              ? '$prompt\n\nIMPORTANT: Return ONLY valid JSON matching this schema, no other text:\n${jsonEncode(responseSchema)}'
              : prompt,
        }
      ],
      'temperature': 0.7,
      'max_tokens': 2048,
    };

    if (responseSchema != null) {
      body['response_format'] = {'type': 'json_object'};
    }

    final response = await http.post(
      Uri.parse(_groqBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_groqApiKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final text = data['choices']?[0]?['message']?['content'] ?? '';

    if (responseSchema != null) {
      try {
        return jsonDecode(text);
      } catch (e) {
        // If JSON parsing fails, try to extract JSON from the text
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
        throw Exception('Failed to parse JSON response from Groq');
      }
    }
    return {'text': text};
  }

  /// Analyze symptoms and return SymptomAnalysis
  static Future<SymptomAnalysis> analyzeSymptoms(String symptoms) async {
    final result = await _generateContent(
      prompt:
          'Analyze these symptoms and provide a medical prediction (disclaimer: this is not a professional diagnosis). '
          'Symptoms: $symptoms. '
          'Return JSON with fields: prediction (string), severity (one of: low, medium, high, critical), '
          'recommendations (string), nextSteps (array of strings).',
      responseSchema: {
        'type': 'OBJECT',
        'properties': {
          'prediction': {'type': 'STRING'},
          'severity': {
            'type': 'STRING',
            'enum': ['low', 'medium', 'high', 'critical']
          },
          'recommendations': {'type': 'STRING'},
          'nextSteps': {
            'type': 'ARRAY',
            'items': {'type': 'STRING'}
          },
        },
        'required': ['prediction', 'severity', 'recommendations', 'nextSteps'],
      },
    );
    return SymptomAnalysis.fromJson(result);
  }

  /// Scan prescription image
  static Future<PrescriptionData> scanPrescription(
      String base64Image, String mimeType) async {
    final result = await _generateContent(
      prompt:
          'Extract medicine details from this prescription image. Return JSON with fields: '
          'medicines (array of {name, dosage, timing, frequency}), doctorName (string), hospitalName (string), date (string).',
      imageBase64: base64Image,
      imageMimeType: mimeType,
      responseSchema: {
        'type': 'OBJECT',
        'properties': {
          'medicines': {
            'type': 'ARRAY',
            'items': {
              'type': 'OBJECT',
              'properties': {
                'name': {'type': 'STRING'},
                'dosage': {'type': 'STRING'},
                'timing': {'type': 'STRING'},
                'frequency': {'type': 'STRING'},
              },
              'required': ['name', 'dosage', 'timing', 'frequency'],
            },
          },
          'doctorName': {'type': 'STRING'},
          'hospitalName': {'type': 'STRING'},
          'date': {'type': 'STRING'},
        },
        'required': ['medicines'],
      },
    );
    return PrescriptionData.fromJson(result);
  }

  /// Analyze medical report image
  static Future<ReportAnalysis> analyzeMedicalReport(
      String base64Image, String mimeType) async {
    final result = await _generateContent(
      prompt:
          'Analyze this medical lab report. Extract report type, key findings, risk score (0-100), and health insights. Return JSON.',
      imageBase64: base64Image,
      imageMimeType: mimeType,
      responseSchema: {
        'type': 'OBJECT',
        'properties': {
          'reportType': {'type': 'STRING'},
          'findings': {'type': 'STRING'},
          'riskScore': {'type': 'NUMBER'},
          'insights': {'type': 'STRING'},
        },
        'required': ['reportType', 'findings', 'riskScore', 'insights'],
      },
    );
    return ReportAnalysis.fromJson(result);
  }

  /// Check drug interactions
  static Future<String> checkDrugInteractions(List<String> medicines) async {
    final result = await _generateContent(
      prompt:
          'Check for potential drug interactions between these medicines: ${medicines.join(", ")}. '
          'Provide safety alerts and recommendations.',
    );
    return result['text'] ?? 'No interaction data found.';
  }

  /// Analyze body composition
  static Future<BodyCompositionAnalysis> analyzeBodyComposition({
    required double height,
    required double weight,
    required int age,
    required String gender,
  }) async {
    final result = await _generateContent(
      prompt: '''Analyze body composition based on:
Height: ${height}cm
Weight: ${weight}kg
Age: $age
Gender: $gender

Calculate estimated BMI, fat percentage, bone mass, water content, muscle mass, and visceral fat. 
Provide health insights. Return JSON.''',
      responseSchema: {
        'type': 'OBJECT',
        'properties': {
          'bmi': {'type': 'NUMBER'},
          'fatPercentage': {'type': 'NUMBER'},
          'boneMass': {'type': 'NUMBER'},
          'waterContent': {'type': 'NUMBER'},
          'muscleMass': {'type': 'NUMBER'},
          'visceralFat': {'type': 'NUMBER'},
          'insights': {'type': 'STRING'},
        },
        'required': [
          'bmi',
          'fatPercentage',
          'boneMass',
          'waterContent',
          'muscleMass',
          'visceralFat',
          'insights'
        ],
      },
    );
    return BodyCompositionAnalysis.fromJson(result);
  }

  /// Get doctor recommendations
  static Future<List<DoctorRecommendation>> getDoctorRecommendations({
    required String specialty,
    required String location,
  }) async {
    final result = await _generateContent(
      prompt:
          'Recommend 5 fictional example doctors specializing in $specialty near $location. '
          'Return JSON array with fields: name, specialty, hospital, rating (1-5), experience (years), phone.',
      responseSchema: {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'name': {'type': 'STRING'},
            'specialty': {'type': 'STRING'},
            'hospital': {'type': 'STRING'},
            'rating': {'type': 'NUMBER'},
            'experience': {'type': 'NUMBER'},
            'phone': {'type': 'STRING'},
          },
          'required': [
            'name',
            'specialty',
            'hospital',
            'rating',
            'experience',
            'phone'
          ],
        },
      },
    );

    if (result is List) {
      return (result as List)
          .map((d) => DoctorRecommendation.fromJson(d))
          .toList();
    }
    return [];
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────

class SymptomAnalysis {
  final String prediction;
  final String severity; // low | medium | high | critical
  final String recommendations;
  final List<String> nextSteps;

  SymptomAnalysis({
    required this.prediction,
    required this.severity,
    required this.recommendations,
    required this.nextSteps,
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysis(
      prediction: json['prediction'] ?? '',
      severity: json['severity'] ?? 'low',
      recommendations: json['recommendations'] ?? '',
      nextSteps: List<String>.from(json['nextSteps'] ?? []),
    );
  }
}

class Medicine {
  final String name;
  final String dosage;
  final String timing;
  final String frequency;

  Medicine({
    required this.name,
    required this.dosage,
    required this.timing,
    required this.frequency,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      timing: json['timing'] ?? '',
      frequency: json['frequency'] ?? '',
    );
  }
}

class PrescriptionData {
  final List<Medicine> medicines;
  final String? doctorName;
  final String? hospitalName;
  final String? date;

  PrescriptionData({
    required this.medicines,
    this.doctorName,
    this.hospitalName,
    this.date,
  });

  factory PrescriptionData.fromJson(Map<String, dynamic> json) {
    return PrescriptionData(
      medicines: (json['medicines'] as List? ?? [])
          .map((m) => Medicine.fromJson(m))
          .toList(),
      doctorName: json['doctorName'],
      hospitalName: json['hospitalName'],
      date: json['date'],
    );
  }
}

class ReportAnalysis {
  final String reportType;
  final String findings;
  final double riskScore;
  final String insights;

  ReportAnalysis({
    required this.reportType,
    required this.findings,
    required this.riskScore,
    required this.insights,
  });

  factory ReportAnalysis.fromJson(Map<String, dynamic> json) {
    return ReportAnalysis(
      reportType: json['reportType'] ?? '',
      findings: json['findings'] ?? '',
      riskScore: (json['riskScore'] ?? 0).toDouble(),
      insights: json['insights'] ?? '',
    );
  }
}

class BodyCompositionAnalysis {
  final double bmi;
  final double fatPercentage;
  final double boneMass;
  final double waterContent;
  final double muscleMass;
  final double visceralFat;
  final String insights;

  BodyCompositionAnalysis({
    required this.bmi,
    required this.fatPercentage,
    required this.boneMass,
    required this.waterContent,
    required this.muscleMass,
    required this.visceralFat,
    required this.insights,
  });

  factory BodyCompositionAnalysis.fromJson(Map<String, dynamic> json) {
    return BodyCompositionAnalysis(
      bmi: (json['bmi'] ?? 0).toDouble(),
      fatPercentage: (json['fatPercentage'] ?? 0).toDouble(),
      boneMass: (json['boneMass'] ?? 0).toDouble(),
      waterContent: (json['waterContent'] ?? 0).toDouble(),
      muscleMass: (json['muscleMass'] ?? 0).toDouble(),
      visceralFat: (json['visceralFat'] ?? 0).toDouble(),
      insights: json['insights'] ?? '',
    );
  }
}

class DoctorRecommendation {
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int experience;
  final String phone;

  DoctorRecommendation({
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.experience,
    required this.phone,
  });

  factory DoctorRecommendation.fromJson(Map<String, dynamic> json) {
    return DoctorRecommendation(
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      hospital: json['hospital'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      experience: (json['experience'] ?? 0).toInt(),
      phone: json['phone'] ?? '',
    );
  }
}
