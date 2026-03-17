import 'package:flutter/material.dart';
import 'package:ticketing_flutter/services/user_service.dart';
import 'package:ticketing_flutter/auth/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF111827), Color(0xFF1E3A8A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person_add, size: 40, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "User Registration",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0.5),

                const SizedBox(height: 30),

                // First Name input
                _buildTextField(
                  controller: firstNameController,
                  label: "First Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),

                // Middle Name input
                _buildTextField(
                  controller: middleNameController,
                  label: "Middle Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),

                // Last Name input
                _buildTextField(
                  controller: lastNameController,
                  label: "Last Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),

                // Email input
                _buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),

                // Contact Number input
                _buildTextField(
                  controller: contactNumberController,
                  label: "Contact Number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),

                // Birthdate input
                // Birthdate input (with date picker)
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(
                      context,
                    ).requestFocus(FocusNode()); // hide keyboard
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.blueAccent,
                              onPrimary: Color.fromARGB(255, 2, 2, 2),
                              surface: Color.fromARGB(255, 187, 222, 251),
                              onSurface: Color.fromARGB(255, 3, 3, 3),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        birthdateController.text =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: birthdateController,
                      label: "Birthdate",
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Gender input
                // Gender dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white70),
                  ),
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF111827),
                    value: genderController.text.isEmpty
                        ? null
                        : genderController.text,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.transgender, color: Colors.white),
                      labelText: "Gender",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        genderController.text = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Password input
                _buildPasswordField(
                  controller: passwordController,
                  label: "Create Password",
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 10),

                // Confirm Password input
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                ),
                const SizedBox(height: 10),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _registerUser,
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Login option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        final email = emailController.text.trim();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginPage(initialEmail: email),
                          ),
                        );
                      },
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: !isVisible,
    );
  }

  Future<void> _registerUser() async {
    String firstName = firstNameController.text.trim();
    String middleName = middleNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();
    String contactNumber = contactNumberController.text.trim();
    String birthdate = birthdateController.text.trim();
    String gender = genderController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Validation: Check if any field is empty
    if (firstName.isEmpty ||
        middleName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        contactNumber.isEmpty ||
        birthdate.isEmpty ||
        gender.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    // Password match validation
    if (password != confirmPassword) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    // Prepare user data
    final userData = {
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "email": email,
      "contactNumber": contactNumber,
      "birthdate": birthdate,
      "gender": gender,
      "password": password,
    };

    // Call the UserService to register the user
    final success = await UserService().registerUser(userData);

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog("An error occurred while registering the account.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const SizedBox(
          height: 80,
          child: Center(
            child: Text(
              "Account registered successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );

    // Wait 2 seconds, then close dialog and go to login so they can sign in
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop(); // Close the dialog only
      if (mounted) {
        final email = emailController.text.trim();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(initialEmail: email),
          ),
        );
      }
    }
  }
}
