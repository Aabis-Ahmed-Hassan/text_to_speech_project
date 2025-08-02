import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project_1/utility/constants/sizes.dart';
import 'package:project_1/utility/popups/loaders.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // text to speed instance
  final FlutterTts tts = FlutterTts();
  // text controller
  final TextEditingController _controller = TextEditingController();

  // supported language
  final Map<String, String> languageMap = {
    'English': 'en-US',
    'French': 'fr-FR',
    'Spanish': 'es-ES',
    'German': 'de-DE',
  };

  // shown to user
  String? _selectedLanguage;
  // this will be given to the tts package
  String? _selectedLocale;
  // stores different voices in different languages given by the tts package
  List<dynamic>? _availableVoices;
  // stores voices of only selected language
  List<Map<String, String>> _voicesForLanguage = [];
  int voiceCycleIndex = 0;
  // voice is playing or not
  bool isPlaying = false;
  // any error?
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = languageMap.keys.first;
    _selectedLocale = languageMap[_selectedLanguage];
    _setupTts();
  }

  Future<void> _setupTts() async {
    // this registers a call back when voice started
    tts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });
    // this registers a call back when voice ended

    tts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
    // this registers a call back when error occur

    tts.setErrorHandler((msg) {
      setState(() {
        isPlaying = false;
        _error = "TTS Error: $msg";
        Loaders.errorSnackBar(title: 'Something went wrong. ', message: msg);
      });
    });
    // refresh available voices
    await _refreshVoicesForLocale();
  }

  Future<void> _refreshVoicesForLocale() async {
    // set error to null
    _error = null;
    if (_selectedLocale != null) {
      // set language
      await tts.setLanguage(_selectedLocale!);
    }

    try {
      // audios of different 'quality, latency, network_required, features' will be added in this list

      _availableVoices = await tts.getVoices;
    } catch (_) {
      _availableVoices = null;
    }

    _voicesForLanguage = [];
    if (_availableVoices != null) {
      for (var voice in _availableVoices!) {
        if (voice is Map) {
          String? locale;
          if (voice.containsKey('locale')) {
            locale = voice['locale']?.toString();
          } else if (voice.containsKey('language')) {
            locale = voice['language']?.toString();
          }
          if (locale != null && _selectedLocale != null) {
            final prefixDevice = locale.toLowerCase().split('-').first;
            final prefixTarget = _selectedLocale!
                .toLowerCase()
                .split('-')
                .first;
            if (prefixDevice == prefixTarget) {
              // Normalize to Map<String, String>
              final Map<String, String> normalized = {};
              if (voice.containsKey('name')) {
                normalized['name'] = voice['name']?.toString() ?? '';
              }
              if (voice.containsKey('locale')) {
                normalized['locale'] = voice['locale']?.toString() ?? '';
              }
              _voicesForLanguage.add(normalized);
            }
          }
        }
      }
    }

    voiceCycleIndex = 0;
    setState(() {});
  }

  Future<void> _speak() async {
    // to show the stop button in the appbar
    setState(() {});

    final text = _controller.text.trim();
    if (text.isEmpty) {
      Loaders.errorSnackBar(
        title: 'Oh Snap',
        message: 'Please add some text to play the audio. ',
      );
      setState(() {
        _error = "Please enter a sentence to speak.";
      });
      return;
    }
    if (_selectedLocale == null) {
      Loaders.errorSnackBar(
        title: 'Oh Snap',
        message: 'Please select a language first. ',
      );
      setState(() {
        _error = "No language selected.";
      });
      return;
    }

    setState(() {
      _error = null;
    });

    await tts.setLanguage(_selectedLocale!);

    if (_voicesForLanguage.isNotEmpty) {
      final Map<String, String> voice =
          _voicesForLanguage[voiceCycleIndex % _voicesForLanguage.length];
      // Ensure proper typing for setVoice
      final Map<String, String> voiceToSet = {
        if (voice.containsKey('name')) 'name': voice['name']!,
        if (voice.containsKey('locale')) 'locale': voice['locale']!,
      };
      await tts.setVoice(voiceToSet);
      voiceCycleIndex++;
    }

    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);

    final speakResult = await tts.speak(text);
    if (speakResult == 1 || speakResult == "success") {
      // to hide the stop button in the appbar
      setState(() {});

      // ok
    } else {
      setState(() {
        _error =
            "Failed to speak. Language may not be supported on this device.";
      });
    }
  }

  Widget _buildVoiceInfo() {
    if (_voicesForLanguage.isEmpty) {
      return const Text(
        "No specific voices discovered for this language. Device default will be used.",
      );
    }
    final index = (voiceCycleIndex) % _voicesForLanguage.length;
    // current audio
    final current = _voicesForLanguage.isNotEmpty
        ? _voicesForLanguage[index]
        : null;
    final name = current != null && current.containsKey('name')
        ? current['name']!
        : "unknown";
    return Text("Voice is change when you press play button again.");
  }

  @override
  void dispose() {
    tts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownItems = languageMap.keys
        .map((lang) => DropdownMenuItem<String>(value: lang, child: Text(lang)))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Multilingual TTS Demo"),
        centerTitle: true,
        actions: [
          // stop the audio option
          Visibility(
            visible: isPlaying,
            child: TextButton(
              child: Text('Stop'),
              onPressed: () async {
                if (isPlaying) {
                  await tts.stop();
                  isPlaying = false;
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(MySizes.defaultSpace),
        child: Column(
          children: [
            // select language
            Row(
              children: [
                const Text("Language:"),
                const SizedBox(width: MySizes.spaceBtwItems),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: dropdownItems,
                    isExpanded: true,
                    onChanged: (newLanguage) async {
                      if (newLanguage == null) return;
                      setState(() {
                        _selectedLanguage = newLanguage;
                        _selectedLocale = languageMap[newLanguage];
                        _error = null;
                      });
                      await _refreshVoicesForLocale();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: MySizes.spaceBtwSections / 2),
            // input text
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter sentence",
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: MySizes.spaceBtwSections / 2),

            // if case of error
            if (_error != null)
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            // in case of no error
            if (_error == null) _buildVoiceInfo(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isPlaying
                    ? const SizedBox(
                        width: MySizes.defaultSpace,
                        height: MySizes.defaultSpace,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(isPlaying ? "Speaking..." : "Play"),
                onPressed: isPlaying
                    ? null
                    : () async {
                        await _speak();
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: MySizes.defaultSpace,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
