/// step_indicator.dart
/// Indicador de pasos para el flujo de solicitud (breadcrumb visual).
library;

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  /// Total de pasos en el flujo.
  final int totalSteps;

  /// Paso actual (base 1).
  final int currentStep;

  /// Etiquetas de cada paso (opcional).
  final List<String>? labels;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final step = i + 1;
        final isCompleted = step < currentStep;
        final isCurrent = step == currentStep;
        final color = isCompleted || isCurrent ? AppColors.primary : AppColors.grey300;

        return Expanded(
          child: Row(
            children: [
              // Círculo del paso
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '$step',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? AppColors.primary : AppColors.grey400,
                          ),
                        ),
                ),
              ),
              // Línea conectora (excepto el último)
              if (i < totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.primary : AppColors.grey300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
