import 'package:flutter/material.dart';

Widget buildMenuItem(
  BuildContext context,
  IconData icon,
  String text, {
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Icon(
            icon,
            color: icon == Icons.favorite
                ? Colors.red
                : Theme.of(context).textTheme.bodyLarge!.color,
            size: 30,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
          ),
        ],
      ),
    ),
  );
}