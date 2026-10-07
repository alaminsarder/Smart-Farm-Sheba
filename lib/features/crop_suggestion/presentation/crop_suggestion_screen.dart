import 'package:flutter/material.dart';

class Crop {
  final String name;
  final String icon;
  final String reason;

  const Crop({
    required this.name,
    required this.icon,
    required this.reason,
  });
}

class SeasonData {
  final String season;
  final List<Crop> crops;
  final String tip;

  const SeasonData({
    required this.season,
    required this.crops,
    required this.tip,
  });
}

class CropSuggestionScreen extends StatefulWidget {
  const CropSuggestionScreen({super.key});

  @override
  State<CropSuggestionScreen> createState() => _CropSuggestionScreenState();
}

class _CropSuggestionScreenState extends State<CropSuggestionScreen> {
  int selectedMonth = DateTime.now().month;

  static const List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  // Month -> Season data (typed, easy to maintain)
  static const Map<int, SeasonData> _seasonByMonth = {
    1: SeasonData(
      season: "Rabi / Winter Season",
      crops: [
        Crop(
            name: "Potato",
            icon: "🥔",
            reason: "Excellent winter crop with good market demand."),
        Crop(
            name: "Mustard",
            icon: "🌱",
            reason: "Suitable for cool weather and short growing period."),
        Crop(name: "Wheat", icon: "🌾", reason: "A major winter cereal crop."),
        Crop(
            name: "Tomato",
            icon: "🍅",
            reason: "Grows well in cool and relatively dry weather."),
        Crop(
            name: "Cauliflower",
            icon: "🥦",
            reason: "Popular winter vegetable with good demand."),
      ],
      tip:
          "January is suitable for many winter crops. Maintain proper irrigation and monitor pests regularly.",
    ),
    2: SeasonData(
      season: "Late Rabi / Winter Season",
      crops: [
        Crop(
            name: "Potato",
            icon: "🥔",
            reason: "Still suitable in many areas during early February."),
        Crop(
            name: "Tomato",
            icon: "🍅",
            reason: "Suitable for the cool and dry weather."),
        Crop(
            name: "Onion",
            icon: "🧅",
            reason: "Good season for onion cultivation."),
        Crop(
            name: "Cucumber",
            icon: "🥒",
            reason: "Can be started as temperature begins to rise."),
        Crop(
            name: "Bottle Gourd",
            icon: "🥒",
            reason: "Suitable as warmer weather begins."),
      ],
      tip:
          "Monitor soil moisture carefully as temperature starts increasing toward the end of winter.",
    ),
    3: SeasonData(
      season: "Spring / Transition Season",
      crops: [
        Crop(
            name: "Maize",
            icon: "🌽",
            reason: "Suitable for warmer conditions with proper irrigation."),
        Crop(
            name: "Cucumber",
            icon: "🥒",
            reason: "Warm weather supports cucumber growth."),
        Crop(name: "Pumpkin", icon: "🎃", reason: "Suitable for warm weather."),
        Crop(
            name: "Okra",
            icon: "🥬",
            reason: "Performs well as temperature increases."),
        Crop(
            name: "Chili",
            icon: "🌶️",
            reason: "Suitable for warm growing conditions."),
      ],
      tip:
          "March is a transition period. Prepare the land properly and ensure sufficient irrigation as temperatures rise.",
    ),
    4: SeasonData(
      season: "Kharif / Summer Season",
      crops: [
        Crop(
            name: "Aus Rice",
            icon: "🌾",
            reason: "Suitable for the early monsoon period."),
        Crop(
            name: "Maize",
            icon: "🌽",
            reason: "Can perform well with proper irrigation."),
        Crop(
            name: "Cucumber",
            icon: "🥒",
            reason: "Warm weather is suitable for cucumber."),
        Crop(
            name: "Pumpkin",
            icon: "🎃",
            reason: "Suitable for warm conditions."),
        Crop(
            name: "Okra", icon: "🥬", reason: "Performs well in warm weather."),
      ],
      tip:
          "During April, maintain proper irrigation and protect crops from excessive heat.",
    ),
    5: SeasonData(
      season: "Kharif / Summer Season",
      crops: [
        Crop(
            name: "Aus Rice",
            icon: "🌾",
            reason: "Suitable for warm and humid conditions."),
        Crop(
            name: "Maize",
            icon: "🌽",
            reason: "Can grow well with adequate water."),
        Crop(
            name: "Pumpkin",
            icon: "🎃",
            reason: "Warm conditions are suitable for pumpkin."),
        Crop(name: "Okra", icon: "🥬", reason: "Well adapted to warm weather."),
        Crop(
            name: "Chili",
            icon: "🌶️",
            reason: "Can be grown with proper moisture management."),
      ],
      tip:
          "May can be hot and humid. Maintain irrigation and watch for pests and fungal diseases.",
    ),
    6: SeasonData(
      season: "Early Monsoon / Kharif Season",
      crops: [
        Crop(
            name: "Aus Rice",
            icon: "🌾",
            reason: "Important crop during the early monsoon."),
        Crop(
            name: "Jute",
            icon: "🌿",
            reason: "Warm and humid conditions are suitable."),
        Crop(
            name: "Pumpkin",
            icon: "🎃",
            reason: "Can grow well with proper drainage."),
        Crop(
            name: "Okra",
            icon: "🥬",
            reason: "Suitable for warm and humid weather."),
        Crop(
            name: "Chili",
            icon: "🌶️",
            reason: "Can be grown with proper drainage."),
      ],
      tip:
          "During early monsoon, make sure excess water can drain from the field.",
    ),
    7: SeasonData(
      season: "Monsoon / Aman Season",
      crops: [
        Crop(
            name: "Aman Rice",
            icon: "🌾",
            reason: "One of the most important monsoon crops."),
        Crop(
            name: "Jute",
            icon: "🌿",
            reason: "Warm and humid weather is suitable for jute."),
        Crop(
            name: "Pumpkin",
            icon: "🎃",
            reason: "Can grow during rainy conditions with drainage."),
        Crop(
            name: "Chili",
            icon: "🌶️",
            reason: "Suitable with proper drainage and care."),
        Crop(
            name: "Eggplant",
            icon: "🍆",
            reason: "Can be grown with proper pest management."),
      ],
      tip:
          "During July, avoid waterlogging and regularly check crops for fungal diseases.",
    ),
    8: SeasonData(
      season: "Monsoon / Aman Season",
      crops: [
        Crop(
            name: "Aman Rice",
            icon: "🌾",
            reason: "Major crop during the monsoon season."),
        Crop(
            name: "Jute",
            icon: "🌿",
            reason: "Suitable in warm and humid conditions."),
        Crop(
            name: "Pumpkin",
            icon: "🎃",
            reason: "Can tolerate rainy conditions with good drainage."),
        Crop(
            name: "Eggplant",
            icon: "🍆",
            reason: "Suitable with regular pest monitoring."),
        Crop(
            name: "Chili",
            icon: "🌶️",
            reason: "Can grow with proper disease management."),
      ],
      tip:
          "August requires careful water management. Prevent standing water around plant roots.",
    ),
    9: SeasonData(
      season: "Late Monsoon / Aman Season",
      crops: [
        Crop(
            name: "Aman Rice",
            icon: "🌾",
            reason: "Main crop of the monsoon season."),
        Crop(
            name: "Pumpkin",
            icon: "🎃",
            reason: "Suitable with proper drainage."),
        Crop(
            name: "Eggplant",
            icon: "🍆",
            reason: "Can continue growing with pest management."),
        Crop(
            name: "Chili",
            icon: "🌶️",
            reason: "Suitable with proper moisture control."),
        Crop(
            name: "Leafy Vegetables",
            icon: "🥬",
            reason: "Suitable as the weather begins to cool."),
      ],
      tip:
          "September is a good time to prepare land for upcoming Rabi crops while maintaining current crops.",
    ),
    10: SeasonData(
      season: "Rabi / Winter Season",
      crops: [
        Crop(
            name: "Potato",
            icon: "🥔",
            reason: "Excellent winter crop with good market demand."),
        Crop(
            name: "Mustard",
            icon: "🌱",
            reason: "Suitable for cool weather and short growing period."),
        Crop(
            name: "Wheat",
            icon: "🌾",
            reason: "One of the major winter cereal crops."),
        Crop(
            name: "Onion",
            icon: "🧅",
            reason: "Suitable for the dry and cool season."),
        Crop(
            name: "Tomato",
            icon: "🍅",
            reason: "Grows well in cool and relatively dry weather."),
        Crop(
            name: "Cauliflower",
            icon: "🥦",
            reason: "Popular winter vegetable with good demand."),
      ],
      tip:
          "October is a good time to prepare land for Rabi crops. Use healthy seeds and ensure proper drainage.",
    ),
    11: SeasonData(
      season: "Rabi / Winter Season",
      crops: [
        Crop(
            name: "Potato",
            icon: "🥔",
            reason: "Excellent crop for cool weather."),
        Crop(
            name: "Wheat",
            icon: "🌾",
            reason: "Suitable for the winter growing season."),
        Crop(
            name: "Mustard",
            icon: "🌱",
            reason: "Very suitable for cool and dry conditions."),
        Crop(
            name: "Onion",
            icon: "🧅",
            reason: "Good winter crop with market demand."),
        Crop(
            name: "Cauliflower",
            icon: "🥦",
            reason: "Popular winter vegetable."),
        Crop(
            name: "Carrot",
            icon: "🥕",
            reason: "Cool weather supports good root development."),
      ],
      tip:
          "November is one of the important months for Rabi crop cultivation. Prepare soil well and use quality seeds.",
    ),
    12: SeasonData(
      season: "Rabi / Winter Season",
      crops: [
        Crop(name: "Potato", icon: "🥔", reason: "Excellent winter crop."),
        Crop(name: "Wheat", icon: "🌾", reason: "Major winter cereal crop."),
        Crop(
            name: "Mustard",
            icon: "🌱",
            reason: "Suitable for cool and dry weather."),
        Crop(
            name: "Onion",
            icon: "🧅",
            reason: "Good winter crop with market demand."),
        Crop(
            name: "Carrot",
            icon: "🥕",
            reason: "Cool weather supports healthy root development."),
        Crop(
            name: "Radish",
            icon: "🥕",
            reason: "Fast-growing winter vegetable."),
      ],
      tip:
          "December is ideal for many Rabi crops. Maintain proper irrigation and protect crops from cold stress.",
    ),
  };

  SeasonData _getSeasonData(int month) =>
      _seasonByMonth[month] ?? _seasonByMonth[12]!;

  @override
  Widget build(BuildContext context) {
    final seasonData = _getSeasonData(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crop Suggestion",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Smart Farm Sheba",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seasonData.season,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Month Selector
          const Text(
            "📅 Select Month",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedMonth,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: List.generate(12, (index) {
                  final monthNumber = index + 1;
                  final isNow = monthNumber == DateTime.now().month;

                  return DropdownMenuItem<int>(
                    value: monthNumber,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 20,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 10),
                        Text(months[index]),
                        if (isNow) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Now",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) setState(() => selectedMonth = value);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Selected Month
          Text(
            "${months[selectedMonth - 1]} Crop Suggestions",
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Crop List
          ...List.generate(seasonData.crops.length, (index) {
            final crop = seasonData.crops[index];
            return _cropCard(
                context, crop.name, crop.icon, crop.reason, index == 0);
          }),

          const SizedBox(height: 18),

          // Farming Tip
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Farming Tip",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        seasonData.tip,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // আপনার code same রাখতে General Tips রাখলাম
          const Text(
            "💧 General Tips",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _generalTip(
            Icons.water_drop_rounded,
            "Check Soil Moisture",
            "Water crops according to soil moisture and avoid unnecessary watering.",
          ),
          _generalTip(
            Icons.grass_rounded,
            "Remove Weeds",
            "Remove weeds regularly so crops can get enough nutrients and sunlight.",
          ),
          _generalTip(
            Icons.bug_report_rounded,
            "Monitor Pests",
            "Check leaves regularly and take early action against pests and diseases.",
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _cropCard(
    BuildContext context,
    String name,
    String icon,
    String reason,
    bool recommended,
  ) {
    final mutedTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side:
            BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Top Pick",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reason,
                    style: TextStyle(
                        color: mutedTextColor, fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generalTip(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
      ),
    );
  }
}
