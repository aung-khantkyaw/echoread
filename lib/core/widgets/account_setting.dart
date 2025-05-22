import 'package:flutter/material.dart';

class AccountSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  const AccountSettingsCard({
    super.key,
    required this.onUpdate,
    required this.onDelete,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.update),
                    label: const Text("Update Account"),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45), foregroundColor: Colors.white),
                    onPressed: onUpdate,
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete Account"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      backgroundColor: Colors.red, foregroundColor: Colors.white
                    ),
                    onPressed: onDelete,
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onLogout,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
