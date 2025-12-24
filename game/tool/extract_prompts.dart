import 'dart:io';

void main() async {
  final file = File('../../docs/resource_generation_prompts.md');
  if (!await file.exists()) {
    print('Error: Docs file not found at ${file.path}');
    return;
  }

  final content = await file.readAsString();
  final lines = content.split('\n');

  String? currentSection;
  String? currentName;
  List<String> currentPromptLines = [];
  bool inPromptBlock = false;

  final prompts = <Map<String, String>>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    // Simple parser for ### headers as Names
    if (line.startsWith('#### ')) {
      currentName = line.substring(5).trim();
      // Translate Korean names to approximate English file keys if possible logic
      // For now, we just keep the name. The agent will map it.
      continue;
    }

    if (line.startsWith('```')) {
      if (inPromptBlock) {
        // End of block
        inPromptBlock = false;
        if (currentName != null && currentPromptLines.isNotEmpty) {
          final promptText = currentPromptLines.join(' ');
          // Check if it's a VFX Prompt
          if (promptText.contains('VFX Prompt:') ||
              promptText.contains('Prompt:')) {
            prompts.add({
              'name': currentName,
              'prompt': promptText
                  .replaceAll('Prompt:', '')
                  .replaceAll('VFX Prompt:', '')
                  .trim(),
              'type': promptText.contains('VFX Prompt:') ? 'VFX' : 'Image',
            });
          }
          currentPromptLines = [];
        }
      } else {
        // Start of block
        inPromptBlock = true;
      }
      continue;
    }

    if (inPromptBlock) {
      if (line.isNotEmpty &&
          !line.startsWith('Prompt:') &&
          !line.startsWith('VFX Prompt:')) {
        currentPromptLines.add(line);
      } else if (line.startsWith('Prompt:') || line.startsWith('VFX Prompt:')) {
        // Should include this line too minus the key, but loop handles 'contains' check above
        currentPromptLines.add(line);
      }
    }
  }

  // Filter for VFX only for this task
  final vfxPrompts = prompts.where((p) => p['type'] == 'VFX').toList();

  print('Found ${vfxPrompts.length} VFX Prompts:');
  for (final p in vfxPrompts) {
    print('Name: ${p['name']}');
    print('Prompt: ${p['prompt']}');
    print('---');
  }
}
