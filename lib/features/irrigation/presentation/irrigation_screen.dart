import 'package:flutter/material.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  // Selected method for the calculator
  String _selectedCrop = 'Vegetables';
  double _landSize = 1.0; // In Bigha/Acre unit

  // Data for irrigation methods
  final List<Map<String, dynamic>> _methods = [
    {
      'name': 'Drip Irrigation',
      'icon': Icons.water_drop,
      'efficiency': '90-95%',
      'desc': 'Best for water conservation. Delivers water directly to roots.',
      'color': Colors.blue,
    },
    {
      'name': 'Sprinkler System',
      // CHANGED: Icons.spray_rounded (not available in older Flutter)
      'icon': Icons.grain,
      'efficiency': '75-85%',
      'desc': 'Good for large fields and uneven terrain. Simulates rain.',
      'color': Colors.lightBlue,
    },
    {
      'name': 'Flood/Furrow',
      'icon': Icons.grass,
      'efficiency': '50-60%',
      'desc': 'Traditional method. High water loss due to evaporation/runoff.',
      'color': Colors.orange,
    },
    {
      'name': 'Manual Watering',
      // CHANGED: Icons.watering_can_outlined (not available in older Flutter)
      'icon': Icons.opacity,
      'efficiency': 'Variable',
      'desc': 'Labor intensive. Good for small gardens but inconsistent.',
      'color': Colors.teal,
    },
  ];

  // Crop water requirement factors (Liters per unit area approx)
  final Map<String, int> _cropFactors = {
    'Rice': 1200,
    'Wheat': 600,
    'Vegetables': 800,
    'Fruits': 700,
    'Jute': 900,
  };

  @override
  Widget build(BuildContext context) {
    // Calculate estimated water
    final baseRequirement = _cropFactors[_selectedCrop] ?? 800;
    final estimatedWater = (baseRequirement * _landSize).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Irrigation",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Best Time to Water Card
          _buildTimeCard(),

          const SizedBox(height: 24),

          // 2. Irrigation Methods
          const Text(
            "Irrigation Methods",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._methods.map((method) => _buildMethodCard(method)),

          const SizedBox(height: 24),

          // 3. Water Calculator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0288D1), Color(0xFF29B6F6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 8),
                    const Text(
                      "Water Calculator",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Crop Selector
                DropdownButtonFormField<String>(
                  value: _selectedCrop,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Crop Type',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: _cropFactors.keys.map((crop) {
                    return DropdownMenuItem(value: crop, child: Text(crop));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCrop = val);
                  },
                ),

                const SizedBox(height: 16),

                // Land Size Slider
                const Text(
                  "Land Size (Units)",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _landSize,
                        min: 0.1,
                        max: 10.0,
                        divisions: 20,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white24,
                        onChanged: (val) {
                          setState(() => _landSize = val);
                        },
                      ),
                    ),
                    Text(
                      _landSize.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const Divider(color: Colors.white24, height: 30),

                // Result
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Estimated Water Needed",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "$estimatedWater Liters",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Per irrigation cycle",
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Conservation Tips
          const Text(
            "💧 Conservation Tips",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTipTile(
            Icons.schedule,
            "Water Early Morning",
            "Water between 5 AM - 8 AM to reduce evaporation loss.",
          ),
          _buildTipTile(
            // CHANGED: Icons.soil_outlined (not available in older Flutter)
            Icons.terrain,
            "Mulching",
            "Cover soil with straw or leaves to retain moisture longer.",
          ),
          _buildTipTile(
            Icons.check_circle_outline,
            "Check Soil Moisture",
            "Don't water if the soil is already wet 2 inches deep.",
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    final hour = DateTime.now().hour;
    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (hour >= 5 && hour < 9) {
      statusText = "Ideal Time! (Morning)";
      statusIcon = Icons.wb_sunny;
      statusColor = Colors.green;
    } else if (hour >= 16 && hour < 18) {
      statusText = "Good Time (Late Afternoon)";
      statusIcon = Icons.cloud_queue;
      statusColor = Colors.orange;
    } else {
      statusText = "Avoid Now (High Evaporation)";
      statusIcon = Icons.hot_tub;
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Status",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Best: 5:00 AM - 8:00 AM",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (method['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                method['icon'] as IconData,
                color: method['color'] as Color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Efficiency: ${method['efficiency']}",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method['desc'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
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

  Widget _buildTipTile(IconData icon, String title, String desc) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        desc,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Why Smart Irrigation?"),
        content: const Text(
          "Proper irrigation saves up to 50% of water and increases crop yield by ensuring plants get the right amount of moisture at the right time.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Got it"),
          )
        ],
      ),
    );
  }
}
