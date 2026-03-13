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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: worker.profileImage.isNotEmpty
              ? NetworkImage(worker.profileImage)
              : null,
          child: worker.profileImage.isEmpty ? const Icon(Icons.person) : null,
        ),

        title: Text(
          worker.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(worker.jobTypes.join(", ")),

            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.orange),

                const SizedBox(width: 4),

                Text(rating.toString()),

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
