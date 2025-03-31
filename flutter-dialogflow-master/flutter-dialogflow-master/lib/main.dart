import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfile()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class UserProfile with ChangeNotifier {
  File? _profileImage;
  String? _name = "User";
  String? _email = "user@medbot.com";
  String? _bio = "Health enthusiast";

  File? get profileImage => _profileImage;
  String? get name => _name;
  String? get email => _email;
  String? get bio => _bio;

  void updateProfile({
    File? image,
    String? name,
    String? email,
    String? bio,
  }) {
    _profileImage = image ?? _profileImage;
    _name = name ?? _name;
    _email = email ?? _email;
    _bio = bio ?? _bio;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Medbot',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.deepPurple,
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              secondary: Colors.purpleAccent,
            ),
            scaffoldBackgroundColor: Colors.grey[900],
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignupPage(),
            '/home': (context) => HomePage(),
          },
        );
      },
    );
  }
}
class HealthTip {
  final String title;
  final String content;
  final String type; // 'tip' or 'news'
  final String imageUrl;

  HealthTip({
    required this.title,
    required this.content,
    required this.type,
    required this.imageUrl,
  });
}
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medbot'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          )
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),
              SizedBox(height: 30),
              _buildHealthGrid(context),
              SizedBox(height: 20),
              // _buildQuickAccessRow(context),
              // SizedBox(height: 20),
              _buildHealthTipsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, 
            MaterialPageRoute(builder: (context) => ChatBotPage())),
        child: Icon(Icons.chat, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome ${user.name}!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 5),
                Text("Your health companion for better living",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, 
                MaterialPageRoute(builder: (context) => ProfilePage())),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: user.profileImage != null 
                  ? FileImage(user.profileImage!) 
                  : null,
              child: user.profileImage == null 
                  ? Icon(Icons.person, size: 30, color: Colors.white)
                  : null,
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildHealthGrid(BuildContext context) {
  List<Map<String, dynamic>> features = [
    {
      "title": "Symptom Checker",
      "icon": Icons.health_and_safety,
      "color": Colors.orange,
      "page": DiseaseDiagnosisPage()
    },
    {
      "title": "Cycle Tracker",
      "icon": Icons.female,
      "color": Colors.pink,
      "page": WomenHealthPage()
    },
    {
      "title": "Mood Journal",
      "icon": Icons.emoji_emotions,
      "color": Colors.blue,
      "page": MoodDetectionPage()
    },
    {
      "title": "Medication",
      "icon": Icons.medical_services,
      "color": Colors.green,
      "page": ChatBotPage()
    },
    {
      "title": "Emergency\nContacts",
      "icon": Icons.emergency,
      "color": Colors.red,
      "page": EmergencyContactsPage()
    },
    {
      "title": "Medical\nRecords",
      "icon": Icons.assignment,
      "color": Colors.teal,
      "page": MedicalRecordsPage()
    },
  ];

  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, // 3 items per row
      crossAxisSpacing: 8, // Spacing between columns
      mainAxisSpacing: 8, // Spacing between rows
      childAspectRatio: 2.0, // Adjusted to make the cards square
    ),
    itemCount: features.length,
    itemBuilder: (context, index) => _buildFeatureCard(features[index], context),
  );
}

Widget _buildFeatureCard(Map<String, dynamic> feature, BuildContext context) {
  return Card(
    elevation: 2, // Reduced elevation for a flatter look
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => feature["page"])),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [feature["color"].withOpacity(0.1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8), // Adjusted padding to match the screenshot
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centered content
            children: [
              Icon(
                feature["icon"],
                size: 30, // Keep the icon size the same
                color: feature["color"],
              ),
              SizedBox(height: 8), // Adjusted spacing between icon and text
              Text(
                feature["title"],
                style: TextStyle(
                  fontSize: 13, // Keep the font size the same
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center, // Centered text
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  // Widget _buildQuickActionCard(
  //     BuildContext context, {required String title, required IconData icon, required Color color,required Widget page,}) {
  //   return Card(
  //     elevation: 4,
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(10),
  //      onTap: () => Navigator.push( // Add navigation
  //       context,
  //       MaterialPageRoute(builder: (context) => page),
  //     ),
  //       child: Container(
  //         height: 100,
  //         decoration: BoxDecoration(
  //           color: color.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         padding: EdgeInsets.all(12),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(icon, size: 30, color: color),
  //             SizedBox(height: 6),
  //             Text(title,
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                     fontWeight: FontWeight.bold,
  //                     color: color)),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

Widget _buildHealthTipsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Health Tips & News',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.deepPurple),
              onPressed: () {
                // Add navigation to full tips list if needed
              },
            ),
          ],
        ),
      ),
      HealthTipsCarousel(),
    ],
  );
}

// Add new LoginPage class
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    context.read<AuthProvider>().login();
    Navigator.pushReplacementNamed(context, '/home');

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade300,
              Colors.purple.shade200
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.health_and_safety, 
                            size: 50, 
                            color: Colors.deepPurple),
                        SizedBox(height: 15),
                        Text('Medbot Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                        SizedBox(height: 25),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter email';
                            if (!value.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter password';
                            if (value.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: _isLoading 
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('LOGIN', 
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text('Create new account',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add new SignupPage class
class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    context.read<AuthProvider>().login();
    Navigator.pushReplacementNamed(context, '/home');

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade300,
              Colors.purple.shade200
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.health_and_safety, 
                            size: 50, 
                            color: Colors.deepPurple),
                        SizedBox(height: 15),
                        Text('Create Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                        SizedBox(height: 25),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter your name';
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter email';
                            if (!value.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter password';
                            if (value.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_outline, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: _isLoading 
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('SIGN UP', 
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Already have an account? Login',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Sidebar Drawer
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name!),
            accountEmail: Text(user.email!),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user.profileImage != null 
                  ? FileImage(user.profileImage!) 
                  : null,
              child: user.profileImage == null 
                  ? Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          FeatureItem("🩺 Disease Diagnosis", Icons.local_hospital,
              DiseaseDiagnosisPage(), context),
          FeatureItem("🌸 Women's Health Tracking", Icons.female, WomenHealthPage(),
              context),
          FeatureItem("😊 Mood Detection", Icons.mood, MoodDetectionPage(), context),
          FeatureItem("🤖 AI Medical Chatbot", Icons.smart_toy, ChatBotPage(), context),
          Divider(),
           ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsPage())),),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

Widget FeatureItem(String title, IconData icon, Widget page, BuildContext context) {
  return ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
    title: Text(title),
    onTap: () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    },
  );
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile Settings'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage())),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => AboutPage())),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medbot', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 20),
            Text(
              'A comprehensive health companion app providing various medical '
              'features including symptom checking, women health tracking, '
              'mood detection, and AI-powered medical assistance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 30),
            Text('Developers:', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            Text('• Benson B Varghese'),
            Text('• Bhavana S Nair'),
            Text('• Aswin Baburaj'),
            Text('• Adithyakrishnan K H'),
            SizedBox(height: 30),
            Text('Version: 1.0.0', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProfile>(context, listen: false);
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _bioController = TextEditingController(text: user.bio);
    _selectedImage = user.profileImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _saveProfile() {
    Provider.of<UserProfile>(context, listen: false).updateProfile(
      image: _selectedImage,
      name: _nameController.text,
      email: _emailController.text,
      bio: _bioController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : null,
                child: _selectedImage == null
                    ? Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}


class WomenHealthPage extends StatefulWidget {
  @override
  _WomenHealthPageState createState() => _WomenHealthPageState();
}

class _WomenHealthPageState extends State<WomenHealthPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _lastPeriodStart;
  int _cycleLength = 28;
  Map<DateTime, Map<String, dynamic>> _dailyData = {};
  // Maps each date to its predicted phase (e.g. "🔴 Period Day")
  Map<DateTime, String> _cyclePredictions = {};
  // List of predicted period start dates (first day of each cycle)
  List<DateTime> _predictedPeriodStarts = [];

  // Phase data: color and description.
  final Map<String, Map<String, dynamic>> _phaseData = {
    "🔴 Period Day": {
      "color": Colors.red,
      "description": "Menstrual phase: Shedding of the uterine lining"
    },
    "🟢 Follicular": {
      "color": Colors.green,
      "description": "Preparation for ovulation, estrogen levels rise"
    },
    "💛 Ovulation": {
      "color": Colors.amber,
      "description": "Egg is released; highest chance of pregnancy"
    },
    "🟣 Luteal": {
      "color": Colors.purple,
      "description": "Body prepares for pregnancy or next cycle"
    },
  };

  // Helper function to compare dates (ignoring time)
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Calculate predictions for 6 cycles (roughly 5-6 months) based on the given start date.
  void _calculatePredictions(DateTime start) {
    _cyclePredictions.clear();
    _predictedPeriodStarts.clear();
    final int menstrualDays = 5;
    final int follicularDays = _cycleLength - 14 - menstrualDays;

    for (int i = 0; i < 6; i++) {
      final DateTime cycleStart = start.add(Duration(days: i * _cycleLength));
      _predictedPeriodStarts.add(cycleStart);

      // Menstrual phase
      for (int j = 0; j < menstrualDays; j++) {
        _cyclePredictions[cycleStart.add(Duration(days: j))] = "🔴 Period Day";
      }
      // Follicular phase
      for (int j = menstrualDays; j < menstrualDays + follicularDays; j++) {
        _cyclePredictions[cycleStart.add(Duration(days: j))] = "🟢 Follicular";
      }
      // Ovulation day
      _cyclePredictions[cycleStart.add(Duration(days: menstrualDays + follicularDays))] =
          "💛 Ovulation";
      // Luteal phase
      for (int j = menstrualDays + follicularDays + 1; j < _cycleLength; j++) {
        _cyclePredictions[cycleStart.add(Duration(days: j))] = "🟣 Luteal";
      }
    }
    setState(() {});
  }

  // Let the user update cycle length.
  void _showCycleSettings() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cycle Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Average cycle length (days):"),
            SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '$_cycleLength',
              ),
              onChanged: (value) => _cycleLength = int.tryParse(value) ?? 28,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _cycleLength),
            child: Text("Save"),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _cycleLength = result);
      if (_lastPeriodStart != null) _calculatePredictions(_lastPeriodStart!);
    }
  }

  // Log daily data (symptoms, flow, and notes).
  void _logDailyData(DateTime day) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DailyLogDialog(initialData: _dailyData[day]),
    );
    if (result != null) {
      setState(() => _dailyData[day] = result);
    }
  }

  // When a day is tapped, show a dialog with two actions:
  // 1. Log Daily Data, 2. Set as Period Start.
  void _onDayTapped(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Action"),
        content: Text(
            "What would you like to do on ${selectedDay.toLocal().toString().substring(0, 10)}?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logDailyData(selectedDay);
            },
            child: Text("Log Daily Data"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _lastPeriodStart = selectedDay;
                _calculatePredictions(selectedDay);
              });
              Navigator.pop(context);
            },
            child: Text("Set as Period Start"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Build a card showing cycle info: cycle length and next predicted period date.
  Widget _buildCycleInfoCard() {
    String predictedNextPeriod = "-";
    if (_predictedPeriodStarts.isNotEmpty) {
      DateTime next = _predictedPeriodStarts.firstWhere(
          (date) => date.isAfter(DateTime.now()),
          orElse: () => _predictedPeriodStarts.last);
      predictedNextPeriod = next.toString().substring(0, 10);
    }
    return Card(
      elevation: 4,
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Cycle Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                )),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem("Cycle Length", "$_cycleLength days"),
                _buildInfoItem("Next Period", predictedNextPeriod),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            )),
      ],
    );
  }

  // Build the calendar with the custom on-tap action.
  Widget _buildCalendar() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(Duration(days: 365)),
          lastDay: DateTime.now().add(Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            headerPadding: EdgeInsets.symmetric(vertical: 8),
            titleTextStyle: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.deepPurple),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.deepPurple),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(color: Colors.black87),
            weekendTextStyle: TextStyle(color: Colors.black87),
            outsideTextStyle: TextStyle(color: Colors.grey),
            selectedDecoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
          ),
          selectedDayPredicate: (day) => isSameDate(_selectedDay ?? DateTime.now(), day),
          onDaySelected: _onDayTapped,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final String? phase = _cyclePredictions[day];
              final data = _dailyData[day];
              return Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: phase != null
                      ? _phaseData[phase]!["color"].withOpacity(0.2)
                      : null,
                  shape: BoxShape.circle,
                  border: data != null ? Border.all(color: Colors.deepPurple) : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${day.day}",
                        style: TextStyle(
                          color: phase != null
                              ? _phaseData[phase]!["color"]
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (phase != null)
                        Text(
                          phase,
                          style: TextStyle(
                              fontSize: 8, color: _phaseData[phase]!["color"]),
                          textAlign: TextAlign.center,
                        ),
                      if (data?['flow'] != null)
                        Icon(Icons.water_drop,
                            color: _getFlowColor(data!['flow']), size: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Build the legend for cycle phases.
  Widget _buildPhaseLegend() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _phaseData.entries
          .map((entry) => Chip(
                backgroundColor: entry.value["color"].withOpacity(0.2),
                label: Text(entry.key, style: TextStyle(color: Colors.black87)),
                avatar: Icon(Icons.circle, color: entry.value["color"], size: 18),
              ))
          .toList(),
    );
  }

  // Build the daily log section if log data exists for the selected day.
  Widget _buildDailyLogSection() {
    if (_selectedDay == null || !_dailyData.containsKey(_selectedDay))
      return SizedBox();

    final data = _dailyData[_selectedDay]!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Log - ${_selectedDay!.toString().substring(0, 10)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (data['symptoms'] != null)
              _buildLogItem("Symptoms", data['symptoms'].join(', ')),
            if (data['flow'] != null) _buildLogItem("Flow", data['flow']),
            if (data['notes'] != null) _buildLogItem("Notes", data['notes']),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Build a card listing upcoming period start dates within the next 5 months.
  Widget _buildUpcomingPeriods() {
    final upcoming = _predictedPeriodStarts
        .where((d) =>
            d.isAfter(DateTime.now()) &&
            d.isBefore(DateTime.now().add(Duration(days: 150))))
        .toList();
    if (upcoming.isEmpty) return SizedBox();
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("upcoming Period Dates (Next 5 months)",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: upcoming
                  .map((date) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(date.toString().substring(0, 10),
                            style: TextStyle(fontSize: 14)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the small confirmation box that appears on the predicted period start date.
  Widget _buildPeriodConfirmationBox() {
    // Check if there is an upcoming predicted period date that is today.
    if (_predictedPeriodStarts.isNotEmpty) {
      DateTime today = DateTime.now();
      DateTime nextPredicted = _predictedPeriodStarts.firstWhere(
          (d) => !d.isBefore(today),
          orElse: () => _predictedPeriodStarts.last);
      if (isSameDate(nextPredicted, today)) {
        return Card(
          color: Colors.orange.shade50,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Did your period start today (${today.toString().substring(0, 10)})?",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // If yes, update the last period start to today.
                        setState(() {
                          _lastPeriodStart = today;
                          _calculatePredictions(today);
                        });
                      },
                      child: Text("Yes"),
                      style: ElevatedButton.styleFrom(iconColor:  Colors.green),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // If no, ask the user to pick a new period start date.
                        DateTime? newStart = await showDatePicker(
                          context: context,
                          initialDate: today,
                          firstDate: today.subtract(Duration(days: 30)),
                          lastDate: today.add(Duration(days: 30)),
                        );
                        if (newStart != null) {
                          setState(() {
                            _lastPeriodStart = newStart;
                            _calculatePredictions(newStart);
                          });
                        }
                      },
                      child: Text("No"),
                      style: ElevatedButton.styleFrom(iconColor:  Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }
    return SizedBox();
  }

  // Get color based on the logged flow level.
  Color _getFlowColor(String flow) {
    switch (flow) {
      case 'Light':
        return Colors.blue.shade200;
      case 'Medium':
        return Colors.blue.shade400;
      case 'Heavy':
        return Colors.blue.shade800;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Women’s Health Tracking'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showCycleSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCycleInfoCard(),
              SizedBox(height: 20),
              _buildCalendar(),
              SizedBox(height: 20),
              _buildPhaseLegend(),
              SizedBox(height: 20),
              _buildDailyLogSection(),
              _buildUpcomingPeriods(),
              _buildPeriodConfirmationBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyLogDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  DailyLogDialog({this.initialData});

  @override
  _DailyLogDialogState createState() => _DailyLogDialogState();
}

class _DailyLogDialogState extends State<DailyLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedSymptoms = [];
  String? _flowLevel;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _symptomsList = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Mood swings'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedSymptoms.addAll(widget.initialData!['symptoms'] ?? []);
      _flowLevel = widget.initialData!['flow'];
      _notesController.text = widget.initialData!['notes'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Daily Log"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Symptoms:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                children: _symptomsList
                    .map((symptom) => FilterChip(
                          selected: _selectedSymptoms.contains(symptom),
                          label: Text(symptom),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _selectedSymptoms.add(symptom);
                            } else {
                              _selectedSymptoms.remove(symptom);
                            }
                          }),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _flowLevel,
                decoration: InputDecoration(
                  labelText: 'Flow Level',
                  border: OutlineInputBorder(),
                ),
                items: ['Light', 'Medium', 'Heavy']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) => _flowLevel = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'symptoms': _selectedSymptoms,
              'flow': _flowLevel,
              'notes': _notesController.text,
            });
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}

// Disease Diagnosis Page (unchanged)
class DiseaseDiagnosisPage extends StatefulWidget {
  @override
  _DiseaseDiagnosisPageState createState() => _DiseaseDiagnosisPageState();
}

class _DiseaseDiagnosisPageState extends State<DiseaseDiagnosisPage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _symptomController = TextEditingController();
  List<Map<String, dynamic>> _diagnosisHistory = [];
  List<String> _currentSymptoms = [];
  Map<String, dynamic>? _currentDiagnosis;
  bool _isLoading = false;
  bool _showWebView = false;
  late InAppWebViewController _webViewController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    dialogFlowtter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showWebView ? "Symptom Checker" : "Symptom Checker"),
        actions: _showWebView
            ? [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => setState(() => _showWebView = false),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.history),
                  onPressed: _showHistoryDialog,
                ),
              ],
      ),
      body: _showWebView ? _buildWebMDView() : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // WebMD Button Card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Check Your Symptoms",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => _showWebView = true),
                    child: Text("Use WebMD Symptom Checker"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // DialogFlow Symptom Input
          _buildSymptomInput(),
          SizedBox(height: 20),
          
          // Current Diagnosis Results
          if (_currentDiagnosis != null) _buildDiagnosisResult(),
          SizedBox(height: 20),
          
          // History Preview
          _buildHistoryPreview(),
        ],
      ),
    );
  }

  Widget _buildWebMDView() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[200],
        ),
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri("https://symptoms.webmd.com/")),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                transparentBackground: true,
                javaScriptEnabled: true,
              ),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              setState(() => _progress = progress / 100);
            },
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(source: """
                // Remove all headers, footers, and navigation
                document.querySelector('header')?.remove();
                document.querySelector('nav')?.remove();
                document.querySelector('.global-header')?.remove();
                document.querySelector('footer')?.remove();
                document.querySelector('.footer')?.remove();
                document.querySelector('.disclaimer')?.remove();
                
                // Remove ads and other unwanted elements
                document.querySelectorAll('.ad-container, .ad-banner, .ad-unit').forEach(el => el.remove());
                document.querySelectorAll('[data-qa="global_nav"], .GlobalNavigation, .SiteHeader').forEach(el => el.remove());
                
                // Make body non-scrollable and full height
                document.body.style.overflow = 'hidden';
                document.body.style.height = '100%';
                document.body.style.margin = '0';
                document.body.style.padding = '0';
                
                // Find the symptom checker container
                const symptomChecker = document.querySelector('.symptom-checker-container') || 
                                      document.querySelector('#symptom-checker') || 
                                      document.querySelector('.symptom-checker');
                
                if (symptomChecker) {
                  // Remove all siblings
                  while (symptomChecker.parentNode.childNodes.length > 1) {
                    if (symptomChecker.previousSibling) {
                      symptomChecker.parentNode.removeChild(symptomChecker.previousSibling);
                    } else if (symptomChecker.nextSibling) {
                      symptomChecker.parentNode.removeChild(symptomChecker.nextSibling);
                    }
                  }
                  
                  // Apply zoom and center the content
                  symptomChecker.style.transform = 'scale(1.2)';
                  symptomChecker.style.transformOrigin = 'top center';
                  symptomChecker.style.width = '100%';
                  symptomChecker.style.margin = '0 auto';
                  symptomChecker.style.padding = '0';
                }
                
                // Remove any remaining scrollable containers
                document.querySelectorAll('*[style*="overflow:scroll"], *[style*="overflow:auto"]')
                  .forEach(el => el.style.overflow = 'hidden');
              """);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _analyzeSymptoms() async {
    if (_symptomController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _currentSymptoms.add(_symptomController.text);
    });

    try {
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(
          text: TextInput(text: _symptomController.text),
        ),
      );

      if (response.message != null) {
        final result = _parseDialogflowResponse(response);
        setState(() {
          _currentDiagnosis = result;
          _diagnosisHistory.insert(0, {
            'symptoms': List.from(_currentSymptoms),
            'diagnosis': result,
            'date': DateTime.now().toIso8601String()
          });
          _currentSymptoms.clear();
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
        _symptomController.clear();
      });
    }
  }

  Map<String, dynamic> _parseDialogflowResponse(DetectIntentResponse response) {
    final parameters = response.queryResult?.parameters ?? {};
    return {
      'conditions': (parameters['conditions'] ?? []).map((c) => c['name']).toList(),
      'confidence': parameters['confidence']?.toString() ?? 'N/A',
      'triage': parameters['triage'] ?? 'Consult doctor',
      'recommendations': (parameters['recommendations'] ?? []).join('\n'),
      'follow_up_questions': (parameters['follow-up'] ?? []),
    };
  }

  Widget _buildSymptomInput() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Describe your symptoms:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _symptomController,
              decoration: InputDecoration(
                hintText: 'e.g. headache, fever, nausea...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _analyzeSymptoms,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _analyzeSymptoms(),
            ),
            if (_isLoading) LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisResult() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assessment Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            _buildResultItem('Possible Conditions',
                _currentDiagnosis!['conditions'].join(', ')),
            _buildResultItem('Confidence Level', _currentDiagnosis!['confidence']),
            _buildResultItem('Recommended Action', _currentDiagnosis!['triage']),
            SizedBox(height: 10),
            Text('Recommendations:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(_currentDiagnosis!['recommendations']),
            if (_currentDiagnosis!['follow_up_questions'].isNotEmpty) ...[
              SizedBox(height: 15),
              Text('Follow-up Questions:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ..._currentDiagnosis!['follow_up_questions'].map<Widget>((q) => ListTile(
                leading: Icon(Icons.question_answer),
                title: Text(q),
                onTap: () {
                  _symptomController.text = q;
                  _analyzeSymptoms();
                },
              )).toList(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildHistoryPreview() {
    if (_diagnosisHistory.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Checks",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ..._diagnosisHistory.take(2).map((entry) => Card(
          child: ListTile(
            title: Text(entry['diagnosis']['conditions'].join(', ')),
            subtitle: Text(entry['date'].substring(0, 10)),
            onTap: () => _showDiagnosisDetails(context, entry),
          ),
        )),
      ],
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Diagnosis History"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _diagnosisHistory.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_diagnosisHistory[index]['diagnosis']['conditions'].join(', ')),
              subtitle: Text(_diagnosisHistory[index]['date'].substring(0, 10)),
              onTap: () => _showDiagnosisDetails(context, _diagnosisHistory[index]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showDiagnosisDetails(BuildContext context, Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Diagnosis Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Symptoms: ${entry['symptoms'].join(', ')}"),
            SizedBox(height: 10),
            Text("Conditions: ${entry['diagnosis']['conditions'].join(', ')}"),
            SizedBox(height: 10),
            Text("Confidence: ${entry['diagnosis']['confidence']}"),
            SizedBox(height: 10),
            Text("Recommendations: ${entry['diagnosis']['recommendations']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }
}

// Mood Detection Page (unchanged)
class MoodDetectionPage extends StatefulWidget {
  @override
  _MoodDetectionPageState createState() => _MoodDetectionPageState();
}

class _MoodDetectionPageState extends State<MoodDetectionPage> {
  final List<String> _moodOptions = [
    '😊 Happy',
    '😢 Sad',
    '😡 Angry',
    '😴 Tired',
    '😌 Calm',
    '😨 Anxious',
    '🤔 Thoughtful',
    '😍 Excited',
  ];

  final List<String> _activities = [
    'Work',
    'Exercise',
    'Socializing',
    'Relaxing',
    'Studying',
    'Traveling',
    'Eating',
    'Sleeping',
  ];

  String? _selectedMood;
  final List<String> _selectedActivities = [];
  final TextEditingController _notesController = TextEditingController();
  final Map<DateTime, Map<String, dynamic>> _moodEntries = {};

  void _logMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a mood before saving.")),
      );
      return;
    }

    final DateTime now = DateTime.now();
    setState(() {
      _moodEntries[now] = {
        'mood': _selectedMood,
        'activities': List.from(_selectedActivities),
        'notes': _notesController.text,
      };
    });

    // Clear the form after logging
    _selectedMood = null;
    _selectedActivities.clear();
    _notesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Mood logged successfully!")),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("How are you feeling today?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _moodOptions
              .map((mood) => ChoiceChip(
                    label: Text(mood),
                    selected: _selectedMood == mood,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMood = selected ? mood : null;
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActivitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What activities did you do today?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _activities
              .map((activity) => FilterChip(
                    label: Text(activity),
                    selected: _selectedActivities.contains(activity),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedActivities.add(activity);
                        } else {
                          _selectedActivities.remove(activity);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Notes (optional):",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: "Write about your day...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildMoodLogs() {
    if (_moodEntries.isEmpty) {
      return Center(
        child: Text("No mood entries yet. Start logging your mood!",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _moodEntries.length,
      itemBuilder: (context, index) {
        final entry = _moodEntries.entries.toList()[index];
        final date = entry.key;
        final data = entry.value;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(data['mood'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['activities'] != null && data['activities'].isNotEmpty)
                  Text("Activities: ${data['activities'].join(', ')}"),
                if (data['notes'] != null && data['notes'].isNotEmpty)
                  Text("Notes: ${data['notes']}"),
              ],
            ),
            trailing: Text(
              "${date.day}/${date.month}/${date.year}",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Journal")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMoodSelector(),
            SizedBox(height: 20),
            _buildActivitySelector(),
            SizedBox(height: 20),
            _buildNotesField(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logMood,
              child: Text("Log Mood"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text("Mood History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildMoodLogs(),
          ],
        ),
      ),
    );
  }
}

// Chatbot Page with Dialogflow (unchanged)
class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      messages.add({"message": text, "isUser": true});
    });

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    if (response.message != null) {
      setState(() {
        messages.add({
          "message": response.message?.text?.text?[0],
          "isUser": false
        });
      });
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Medical Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(messages[index]["message"],
                    textAlign: messages[index]["isUser"]
                        ? TextAlign.right
                        : TextAlign.left),
              ),
            ),
          ),
          ChatInputWidget(sendMessage: sendMessage, controller: _controller),
        ],
      ),
    );
  }
}

// Chat Input Widget (unchanged)
class ChatInputWidget extends StatelessWidget {
  final Function(String) sendMessage;
  final TextEditingController controller;

  ChatInputWidget({required this.sendMessage, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Type a message..."),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  sendMessage(text);
                  controller.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                sendMessage(controller.text);
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
// ========== Emergency Contacts Page ==========
class EmergencyContactsPage extends StatelessWidget {
  final List<Map<String, dynamic>> doctors = [
    {'name': 'Dr. Benson B Varghese', 'specialty': 'Neurosurgeon', 'phone': '+2255113322'},
    {'name': 'Dr. Bhavana S Nair', 'specialty': 'Psychiatrist', 'phone': '+1234567890'},
    {'name': 'Dr. Aswin Baburaj', 'specialty': 'Oncologist', 'phone': '+0987654321'},
    {'name': 'Dr. Aadithyakrishnan K H', 'specialty': 'Pediatrician', 'phone': '+1122334455'},
  ];

  final List<Map<String, dynamic>> hospitals = [
    {'name': 'City General Hospital', 'address': '123 Main St', 'phone': '+1555666777'},
    {'name': 'Metro Health Center', 'address': '456 Oak Ave', 'phone': '+1888999000'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency Contacts')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Emergency Ambulance'),
          _buildAmbulanceCard(),
          SizedBox(height: 20),
          _buildSectionHeader('Doctors'),
          ...doctors.map((doctor) => _buildContactCard(
            icon: Icons.medical_services,
            title: doctor['name'],
            subtitle: doctor['specialty'],
            phone: doctor['phone'],
          )),
          SizedBox(height: 20),
          _buildSectionHeader('Nearby Hospitals'),
          ...hospitals.map((hospital) => _buildContactCard(
            icon: Icons.local_hospital,
            title: hospital['name'],
            subtitle: hospital['address'],
            phone: hospital['phone'],
          )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildAmbulanceCard() {
    return Card(
      elevation: 4,
      color: Colors.red.shade50,
      child: ListTile(
        leading: Icon(Icons.emergency, color: Colors.red),
        title: Text('Call Ambulance'),
        subtitle: Text('Emergency Medical Services'),
        trailing: IconButton(
          icon: Icon(Icons.call, color: Colors.red),
          onPressed: () => _makePhoneCall('911'),
        ),
      ),
    );
  }

  Widget _buildContactCard({IconData? icon, String? title, String? subtitle, String? phone}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title!),
        subtitle: Text(subtitle!),
        trailing: IconButton(
          icon: Icon(Icons.call, color: Colors.green),
          onPressed: () => _makePhoneCall(phone!),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    }
  }
}

// ========== Medical Records Page ==========
class MedicalRecordsPage extends StatefulWidget {
  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  List<Map<String, dynamic>> _medicalRecords = [
    {'title': 'Blood Test Report', 'date': '2023-03-15', 'description': 'Complete blood count results'},
    {'title': 'X-Ray Report', 'date': '2023-04-20', 'description': 'Chest X-Ray findings'},
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical Records')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddRecordDialog(),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _medicalRecords.length,
        itemBuilder: (context, index) {
          return _buildRecordCard(_medicalRecords[index]);
        },
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.assignment, color: Colors.deepPurple),
        title: Text(record['title'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record['date']),
            SizedBox(height: 8),
            Text(record['description']),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteRecord(record),
        ),
      ),
    );
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Medical Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                setState(() {
                  _medicalRecords.add({
                    'title': _titleController.text,
                    'date': DateTime.now().toString().substring(0, 10),
                    'description': _descriptionController.text
                  });
                });
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record?'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _medicalRecords.remove(record));
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
class HealthTipsCarousel extends StatefulWidget {
  @override
  _HealthTipsCarouselState createState() => _HealthTipsCarouselState();
}

class _HealthTipsCarouselState extends State<HealthTipsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<HealthTip> _healthTips = [
    HealthTip(
      title: 'Stay Hydrated!',
      content: 'Drink at least 8 glasses of water daily for optimal body function.',
      type: 'tip',
      imageUrl: 'https://imgs.search.brave.com/bHHIVqPho48hEBSa-Hpwk-q1rL9hKTOCh-qes7YfsIQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pMC53/cC5jb20vcG9zdC5o/ZWFsdGhsaW5lLmNv/bS93cC1jb250ZW50/L3VwbG9hZHMvMjAy/MC8xMS9wb2MtYXRo/bGV0ZS1kcmlua2lu/Zy13YXRlci0xMjk2/eDcyOC1oZWFkZXIu/anBnP3c9MTE1NSZo/PTE1Mjg',
    ),
    HealthTip(
      title: 'COVID-19 Update',
      content: 'New booster vaccines now available for adults over 50.',
      type: 'news',
      imageUrl: 'https://imgs.search.brave.com/T3zEffTa0_u6HVb3txNLEjsBaRGHLhyWDgDccCHu7Ts/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/cHJlbWl1bS1waG90/by9jb3ZpZDE5LXZp/cnVzZXNfOTY3NDMt/NjAxLmpwZz9zZW10/PWFpc19oeWJyaWQ',
    ),
    HealthTip(
      title: 'Daily Exercise',
      content: '30 minutes of moderate exercise can improve heart health.',
      type: 'tip',
      imageUrl: 'https://imgs.search.brave.com/A8-Egitcd5oiUYlFhAFFvdLEfiqBa4Bt_yHtVYpx-v8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzA4LzA0LzQ4LzY5/LzM2MF9GXzgwNDQ4/Njk5Ml9GNGxIUVB6/VGdjTGxBTzFIbnhk/VTZXcVFuTFBzS1ZS/WS5qcGc',
    ),
    HealthTip(
      title: 'Mental Health',
      content: 'Meditation shown to reduce stress by 40% in new study.',
      type: 'news',
      imageUrl: 'https://imgs.search.brave.com/e9fBKah-VPiXe-jeAMZyXcuihDHenLqjdfiIQQbya_8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvaGVh/bHRoLXBpY3R1cmVz/LXV4NnF4YW94dXl0/eXU4MnUuanBn',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll every 5 seconds
    Timer.periodic(Duration(seconds: 7), (Timer timer) {
      if (_currentPage < _healthTips.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _healthTips.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildTipCard(_healthTips[index]);
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            _healthTips.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index 
                    ? Colors.deepPurple 
                    : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(tip.imageUrl), // Use your images
                    fit: BoxFit.cover,
                  ),
                ),
                child: tip.imageUrl.isEmpty
                    ? Icon(Icons.health_and_safety, size: 50)
                    : null,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.type.toUpperCase(),
                    style: TextStyle(
                      color: tip.type == 'news' 
                          ? Colors.red 
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    tip.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tip.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}