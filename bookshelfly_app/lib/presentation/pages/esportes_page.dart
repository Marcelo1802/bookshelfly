import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EsportesPage extends StatelessWidget {
  const EsportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        foregroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: const Center(
        child: Text(
          'Esportes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}
