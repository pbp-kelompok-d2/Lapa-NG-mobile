import 'package:flutter/material.dart';
import 'package:lapang/screens/auth/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapang/models/custom_user.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _profilePictureController = TextEditingController();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // default role
  String _selectedRole = 'owner';

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _profilePictureController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    'Register',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Profile picture URL (optional)
                  TextFormField(
                    controller: _profilePictureController,
                    decoration: const InputDecoration(
                      labelText: 'Profile picture URL (optional)',
                      hintText: 'https://example.com/avatar.jpg',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final v = value.trim();
                      if (!v.startsWith('http://') && !v.startsWith('https://')) {
                        return 'Please enter a valid URL starting with http(s)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Role dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value ?? 'owner';
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone number
                  TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '81234567890 (digits only, no leading 0/+62)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(v)) {
                        return 'Phone number must contain only digits';
                      }
                      if (v.length > 11) {
                        return 'Phone number must be at most 11 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Confirm password
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      hintText: 'Re-enter your password',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Register button
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final username = _usernameController.text.trim();
                      final name = _nameController.text.trim();
                      final profilePicture = _profilePictureController.text.trim();
                      final number = _numberController.text.trim();
                      final password1 = _passwordController.text;
                      final password2 = _confirmPasswordController.text;

                      final Map<String, dynamic> payload = {
                        "username": username,
                        "password1": password1,
                        "password2": password2,
                        "name": name,
                        "role": _selectedRole,
                        "number": number,
                      };

                      if (profilePicture.isNotEmpty) {
                        payload["profile_picture"] = profilePicture;
                      }

                      try {
                        final response = await request.post(
                          "https://abdurrahman-ammar-lapang.pbp.cs.ui.ac.id/api/auth/register/",
                          payload,  
                        );

                        if (!context.mounted) return;

                        if (response != null && response['status'] == true) {
                          // parse into CustomUser model
                          final user = CustomUser.fromJson(Map<String, dynamic>.from(response));
                          _showMessage('Successfully registered ${user.username ?? username}', bg: Colors.green);
                          // navigate to login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                          return;
                        }

                        // show validation errors if present
                        if (response != null && response['errors'] != null) {
                          final Map<String, dynamic> errors = Map<String, dynamic>.from(response['errors']);
                          final List<String> messages = [];
                          errors.forEach((field, list) {
                            if (list is List) {
                              for (var item in list) {
                                if (item is String) {
                                  messages.add('$field: $item');
                                } else if (item is Map && item['message'] != null) {
                                  messages.add('$field: ${item['message']}');
                                }
                              }
                            }
                          });
                          _showMessage(messages.join('\n'));
                          return;
                        }

                        final msg = response != null && response['message'] != null ? response['message'].toString() : 'Failed to register';
                        _showMessage(msg);
                      } catch (e) {
                        _showMessage('Network or server error: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Register'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
