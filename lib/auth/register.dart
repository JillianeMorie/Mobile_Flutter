import 'package:flutter/material.dart';
import 'package:ticketing_flutter/widgets/disable_route_pop.dart';
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
  bool _isSubmitting = false;
  String? _firstNameError;
  String? _middleNameError;
  String? _lastNameError;
  String? _emailError;
  String? _birthdateError;
  String? _contactNumberError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? _validateNameWhileTyping(String value, {bool isOptional = false}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return isOptional ? null : null;
    }

    // Allow letters, spaces, apostrophes, dots and hyphens only.
    final namePattern = RegExp(r"^[A-Za-z][A-Za-z\s'.-]*$");
    if (!namePattern.hasMatch(trimmed)) {
      return 'Alphabet letters only';
    }

    return null;
  }

  String? _validateEmailWhileTyping(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Enter valid address';
    }

    return null;
  }

  String? _validateContactNumberWhileTyping(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return null;
    if (digitsOnly.length < 11) {
      return 'Contact number must be at least 11 digits';
    }
    return null;
  }

  String? _validatePasswordWhileTyping(String value) {
    if (value.isEmpty) return null;
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPasswordWhileTyping(
    String confirmPassword,
    String password,
  ) {
    if (confirmPassword.isEmpty) return null;
    if (confirmPassword != password) return 'Passwords do not match';
    return null;
  }

  bool _isAtLeast18(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    final birthdayThisYearPassed =
        (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);

    if (!birthdayThisYearPassed) {
      age--;
    }

    return age >= 18;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    birthdateController.dispose();
    genderController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DisableRoutePop(child: Scaffold(
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
                  errorText: _firstNameError,
                  onChanged: (value) {
                    setState(() {
                      _firstNameError = _validateNameWhileTyping(value);
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Middle Name input
                _buildTextField(
                  controller: middleNameController,
                  label: "Middle Name",
                  icon: Icons.person,
                  errorText: _middleNameError,
                  onChanged: (value) {
                    setState(() {
                      _middleNameError = _validateNameWhileTyping(
                        value,
                        isOptional: true,
                      );
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Last Name input
                _buildTextField(
                  controller: lastNameController,
                  label: "Last Name",
                  icon: Icons.person,
                  errorText: _lastNameError,
                  onChanged: (value) {
                    setState(() {
                      _lastNameError = _validateNameWhileTyping(value);
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Email input
                _buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (value) {
                    setState(() {
                      _emailError = _validateEmailWhileTyping(value);
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Contact Number input
                _buildTextField(
                  controller: contactNumberController,
                  label: "Contact Number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  errorText: _contactNumberError,
                  onChanged: (value) {
                    setState(() {
                      _contactNumberError = _validateContactNumberWhileTyping(
                        value,
                      );
                    });
                  },
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
                        _birthdateError = _isAtLeast18(pickedDate)
                            ? null
                            : "You must be 18 years old and above.";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: birthdateController,
                      label: "Birthdate",
                      icon: Icons.calendar_today,
                      errorText: _birthdateError,
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
                    initialValue: genderController.text.isEmpty
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
                  errorText: _passwordError,
                  onChanged: (value) {
                    setState(() {
                      _passwordError = _validatePasswordWhileTyping(value);
                      _confirmPasswordError =
                          _validateConfirmPasswordWhileTyping(
                            confirmPasswordController.text,
                            value,
                          );
                    });
                  },
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 10),

                // Confirm Password input
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  isVisible: _isConfirmPasswordVisible,
                  errorText: _confirmPasswordError,
                  onChanged: (value) {
                    setState(() {
                      _confirmPasswordError =
                          _validateConfirmPasswordWhileTyping(
                            value,
                            passwordController.text,
                          );
                    });
                  },
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
                    onPressed: _isSubmitting ? null : _registerUser,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
    ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.amberAccent),
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
    String? errorText,
    ValueChanged<String>? onChanged,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.amberAccent),
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
    final firstName = firstNameController.text.trim();
    final middleName = middleNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final contactNumber = contactNumberController.text.trim();
    final birthdate = birthdateController.text.trim();
    final gender = genderController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty ||
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

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      _showErrorDialog("Please enter a valid email address.");
      return;
    }

    // Keep only digits so formatted inputs like +63/space/dash are handled.
    final contactDigitsOnly = contactNumber.replaceAll(RegExp(r'\D'), '');
    if (contactDigitsOnly.length < 11) {
      _showErrorDialog("Contact number must be at least 11 digits.");
      return;
    }

    DateTime? parsedBirthdate;
    try {
      parsedBirthdate = DateTime.parse(birthdate);
    } catch (_) {
      _showErrorDialog("Please enter a valid birthdate.");
      return;
    }

    if (!_isAtLeast18(parsedBirthdate)) {
      setState(() {
        _birthdateError = "You must be 18 years old and above.";
      });
      _showErrorDialog("You must be 18 years old and above.");
      return;
    } else {
      setState(() {
        _birthdateError = null;
      });
    }

    // Names should only contain letters and common separators (no digits).
    final namePattern = RegExp(r"^[A-Za-z][A-Za-z\s'.-]*$");
    if (!namePattern.hasMatch(firstName)) {
      _showErrorDialog("First name must not contain numbers.");
      return;
    }
    if (middleName.isNotEmpty && !namePattern.hasMatch(middleName)) {
      _showErrorDialog("Middle name must not contain numbers.");
      return;
    }
    if (!namePattern.hasMatch(lastName)) {
      _showErrorDialog("Last name must not contain numbers.");
      return;
    }

    final passwordError = _validatePasswordWhileTyping(password);
    final confirmPasswordError = _validateConfirmPasswordWhileTyping(
      confirmPassword,
      password,
    );
    if (passwordError != null || confirmPasswordError != null) {
      setState(() {
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
      return;
    }

    setState(() => _isSubmitting = true);

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

    final result = await UserService().registerUser(userData);
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result.success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(result.message);
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
