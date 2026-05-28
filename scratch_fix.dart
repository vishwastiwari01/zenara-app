import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (var file in files) {
    if (file.path.contains('colors.dart') || file.path.contains('main.dart')) continue;
    
    var content = file.readAsStringSync();
    
    // Replace AppColors.textPrimary with Theme.of(context).textTheme.bodyMedium?.color
    // We need to be careful with const contexts.
    // A simple regex replacement:
    content = content.replaceAll(
      'color: AppColors.textPrimary', 
      'color: Theme.of(context).textTheme.bodyMedium?.color'
    );
    // Also fix cases where it might be in a const constructor
    content = content.replaceAll(
      'const Text(', 
      'Text('
    );
    
    file.writeAsStringSync(content);
  }
  print('Done fixing colors.');
}
