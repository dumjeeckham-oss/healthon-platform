import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/models/forest_tile.dart';

class GardenTile extends StatelessWidget {
  final ForestTile tile;

  final VoidCallback? onTap;

  const GardenTile({
    super.key,
    required this.tile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: tile.unlocked ? 1 : 0.95,
      duration: const Duration(milliseconds: 250),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _backgroundColor(),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _borderColor(),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [

              //--------------------------------------------------
              // Tree
              //--------------------------------------------------

              Center(
                child: _buildTree(),
              ),

              //--------------------------------------------------
              // Level
              //--------------------------------------------------

              if (tile.planted)
                Positioned(
                  left: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Lv.${tile.level}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

              //--------------------------------------------------
              // Progress
              //--------------------------------------------------

              if (tile.planted)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: tile.progress,
                      minHeight: 6,
                    ),
                  ),
                ),

              //--------------------------------------------------
              // Locked Overlay
              //--------------------------------------------------

              if (!tile.unlocked)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Tree Widget
  //--------------------------------------------------

  Widget _buildTree() {
    if (!tile.unlocked) {
      return const Icon(
        Icons.lock_outline,
        color: Colors.white70,
        size: 34,
      );
    }

    if (!tile.planted) {
      return const Icon(
        Icons.add_circle_outline,
        color: Colors.green,
        size: 36,
      );
    }

    if (tile.asset != null &&
        tile.asset!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          tile.asset!,
          fit: BoxFit.contain,
        ),
      );
    }

    return const Text(
      "🌳",
      style: TextStyle(fontSize: 40),
    );
  }

  //--------------------------------------------------
  // Colors
  //--------------------------------------------------

  Color _backgroundColor() {
    if (!tile.unlocked) {
      return Colors.grey.shade300;
    }

    if (!tile.planted) {
      return const Color(0xffEDF8ED);
    }

    return Colors.white;
  }

  Color _borderColor() {
    if (!tile.unlocked) {
      return Colors.grey.shade500;
    }

    if (!tile.planted) {
      return Colors.green.shade200;
    }

    return Colors.green;
  }
}
