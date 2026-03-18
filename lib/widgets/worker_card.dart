import 'package:flutter/material.dart';
import '../models/worker_model.dart';

class WorkerCard extends StatelessWidget {
  final WorkerModel worker;
  final double distance;
  final double rating;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.distance,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = rating; // already passed from parent

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: worker.profileImage.isNotEmpty
                  ? NetworkImage(worker.profileImage)
                  : null,
              child: worker.profileImage.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),

            // 🟢 GREEN DOT (available today)
            if (worker.availableToday)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),

        title: Text(
          worker.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(worker.jobTypes.join(", ")),

            const SizedBox(height: 6),

            Row(
              children: [
                // ⭐ STAR DISPLAY (5 stars)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < displayRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.orange,
                    );
                  }),
                ),

                const SizedBox(width: 6),

                // ⭐ RATING NUMBER
                Text(
                  displayRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),

                const SizedBox(width: 12),

                const Icon(Icons.location_on, size: 16),

                const SizedBox(width: 4),

                Text("${distance.toStringAsFixed(1)} km"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}