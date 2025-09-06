import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ReadingSettingsDialog extends StatefulWidget {
  final double fontSize;
  final double lineHeight;
  final bool isDarkMode;
  final Function(double fontSize, double lineHeight, bool isDarkMode) onSettingsChanged;

  const ReadingSettingsDialog({
    super.key,
    required this.fontSize,
    required this.lineHeight,
    required this.isDarkMode,
    required this.onSettingsChanged,
  });

  @override
  State<ReadingSettingsDialog> createState() => _ReadingSettingsDialogState();
}

class _ReadingSettingsDialogState extends State<ReadingSettingsDialog> {
  late double _fontSize;
  late double _lineHeight;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.fontSize;
    _lineHeight = widget.lineHeight;
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurações de Leitura'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tamanho da fonte
            const Text(
              'Tamanho da Fonte',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('A'),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
                const Text('A'),
              ],
            ),
            Text(
              '${_fontSize.round()}px',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Espaçamento entre linhas
            const Text(
              'Espaçamento entre Linhas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('1.0'),
                Expanded(
                  child: Slider(
                    value: _lineHeight,
                    min: 1.0,
                    max: 2.5,
                    divisions: 15,
                    label: _lineHeight.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _lineHeight = value;
                      });
                    },
                  ),
                ),
                const Text('2.5'),
              ],
            ),
            Text(
              '${_lineHeight.toStringAsFixed(1)}x',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tema
            const Text(
              'Tema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Claro'),
                    value: false,
                    groupValue: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Escuro'),
                    value: true,
                    groupValue: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDarkMode ? AppColors.greyDark : AppColors.white,
                border: Border.all(color: AppColors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Preview do texto com as configurações atuais.',
                style: TextStyle(
                  fontSize: _fontSize,
                  height: _lineHeight,
                  color: _isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ElevatedButton(
            onPressed: () {
              widget.onSettingsChanged(_fontSize, _lineHeight, _isDarkMode);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Aplicar',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}
