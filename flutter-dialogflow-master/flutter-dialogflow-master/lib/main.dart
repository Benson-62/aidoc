import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medbot',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

// Home Page with Sidebar Navigation
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
              _buildWelcomeHeader(),
              SizedBox(height: 30),
              _buildHealthGrid(context),
              SizedBox(height: 20),
              _buildQuickAccessRow(context),
              SizedBox(height: 20),
              _buildHealthTipsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, 
            MaterialPageRoute(builder: (context) => ChatBotPage())),
        child: Icon(Icons.chat, color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade300, Colors.purple.shade200],
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
                Text("Welcome Back!",
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
          // Placeholder for profile/avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 30, color: Colors.white),
          )
        ],
      ),
    );
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
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => _buildFeatureCard(features[index], context),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => feature["page"])),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [feature["color"].withOpacity(0.2), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(feature["icon"], size: 35, color: feature["color"]),
                Text(feature["title"],
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple)),
                // Image placeholder
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: feature["color"].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.image, color: feature["color"].withOpacity(0.4)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            title: "Emergency\nContacts",
            icon: Icons.emergency,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildQuickActionCard(
            context,
            title: "Medical\nRecords",
            icon: Icons.assignment,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, {required String title, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: color),
              SizedBox(height: 8),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("Daily Health Tips",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
        ),
        // Image placeholder for health tips
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Icon(Icons.image_search, 
                size: 50, 
                color: Colors.deepPurple.withOpacity(0.3)),
          ),
        ),
        SizedBox(height: 10),
        Text("Stay hydrated and maintain regular exercise routine",
            style: TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }
}

// Sidebar Drawer
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.deepPurple.shade300,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple.shade700),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.health_and_safety, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text("Medbot Features",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          FeatureItem("🩺 Disease Diagnosis", Icons.local_hospital,
              DiseaseDiagnosisPage(), context),
          FeatureItem("🌸 Women's Health Tracking", Icons.female, WomenHealthPage(),
              context),
          FeatureItem("😊 Mood Detection", Icons.mood, MoodDetectionPage(), context),
          FeatureItem("🤖 AI Medical Chatbot", Icons.smart_toy, ChatBotPage(), context),
        ],
      ),
    );
  }

  Widget FeatureItem(String title, IconData icon, Widget page, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
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
            Text("Upcoming Period Dates (Next 5 months)",
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
class DiseaseDiagnosisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Disease Diagnosis")),
      body: Center(
        child: Text("Disease Diagnosis Feature Coming Soon...",
            style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
      ),
    );
  }
}

// Mood Detection Page (unchanged)
class MoodDetectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Detection")),
      body: Center(
        child: Text("Mood Detection Feature Coming Soon...",
            style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
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
