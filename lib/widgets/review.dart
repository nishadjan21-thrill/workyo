import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workyo/l10n/app_localizations.dart';
import '../services/review_service.dart';

class ReviewSection extends StatefulWidget {
  final String workerId;

  const ReviewSection({super.key, required this.workerId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final ReviewService reviewService = ReviewService();

  double selectedRating = 5;
  final TextEditingController reviewController = TextEditingController();

  bool isLoading = false;

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.logInrequired)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await reviewService.submitReview(
        workerId: widget.workerId,
        userId: user.uid,
        rating: selectedRating,
      );

      reviewController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reviewSubmitted)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  Widget buildStar(double index) {
    return IconButton(
      onPressed: () {
        setState(() {
          selectedRating = index;
        });
      },
      icon: Icon(
        index <= selectedRating ? Icons.star : Icons.star_border,
        color: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.rateWorker,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),

        Row(children: List.generate(5, (i) => buildStar(i + 1))),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: isLoading ? null : submit,
          child: isLoading
              ? const CircularProgressIndicator()
              : Text(AppLocalizations.of(context)!.submit),
        ),
      ],
    );
  }
}
