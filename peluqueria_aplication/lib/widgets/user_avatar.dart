import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_manager.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final String? userName;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    this.radius = 25,
    this.userName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: ValueListenableBuilder(
        valueListenable: UserManager.profileNotifier,
        builder: (context, userProfile, child) {
          ImageProvider imageProvider;

          if (userProfile?.fotoBase64 != null &&
              userProfile!.fotoBase64!.isNotEmpty) {
            try {
              imageProvider =
                  MemoryImage(base64Decode(userProfile.fotoBase64!));
            } catch (e) {
              imageProvider = NetworkImage(userProfile?.defaultImage ??
                  "https://i.imgur.com/lB5bLMY.jpg");
            }
          } else {
            var networkImage = NetworkImage(
                userProfile?.defaultImage ?? "https://i.imgur.com/lB5bLMY.jpg");
            imageProvider = networkImage;
          }

          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            backgroundImage: imageProvider,
          );
        },
      ),
    );
  }
}
