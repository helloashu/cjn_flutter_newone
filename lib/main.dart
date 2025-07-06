import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CJN Personal Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: SplashScreen(onThemeChanged: _toggleTheme),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const SplashScreen({super.key, required this.onThemeChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(onThemeChanged: widget.onThemeChanged),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  String _userType = 'User'; // User Type field
  final _collegeController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _mobileController.text = prefs.getString('mobile') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _ageController.text = prefs.getString('age') ?? '';
      _gender = prefs.getString('gender') ?? 'Male';
      _userType = prefs.getString('userType') ?? 'User'; // Load User Type
      _collegeController.text = prefs.getString('college') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
      _isDark = prefs.getBool('isDark') ?? false;
    });
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setString('mobile', _mobileController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('age', _ageController.text);
      await prefs.setString('gender', _gender);
      await prefs.setString('userType', _userType); // Save User Type
      await prefs.setString('college', _collegeController.text);
      await prefs.setString('address', _addressController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details saved successfully!')),
        );
        // Clear fields after saving
        _nameController.clear();
        _mobileController.clear();
        _emailController.clear();
        _ageController.clear();
        _gender = 'Male'; // Reset gender to default
        _userType = 'User'; // Reset user type to default
        _collegeController.clear();
        _addressController.clear();
        setState(() {}); // Update UI
      }
    }
  }

  void _toggleTheme(bool value) {
    setState(() => _isDark = value);
    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDropdownField('User Type', _userType, ['Admin', 'User', 'Guest'], (val) => _userType = val ?? 'User', color: Colors.grey[800]),
                  _buildTextField(_nameController, 'Name', color: Colors.grey[800]),
                  _buildTextField(_mobileController, 'Mobile No', keyboardType: TextInputType.phone, color: Colors.grey[800]),
                  _buildTextField(_emailController, 'Email ID', keyboardType: TextInputType.emailAddress, color: Colors.grey[800]),
                  _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number, color: Colors.grey[800]),
                  _buildDropdownField('Gender', _gender, ['Male', 'Female'], (val) => _gender = val ?? 'Male', color: Colors.grey[800]),
                  _buildTextField(_collegeController, 'College Name', color: Colors.grey[800]),
                  _buildTextField(_addressController, 'Address', maxLines: 2, color: Colors.grey[800]),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // Professional button color
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      'Save Details',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Personal Details'),
        actions: [
          Switch(value: _isDark, onChanged: _toggleTheme),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white), // Ensure text is visible in dark mode
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70), // Light label for contrast
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: color ?? Colors.grey[800], // Darker fill for visibility
        ),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(color: Colors.white), // Ensure dropdown text is visible
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70), // Light label for contrast
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: color ?? Colors.grey[700], // Darker fill for visibility
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _collegeController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}