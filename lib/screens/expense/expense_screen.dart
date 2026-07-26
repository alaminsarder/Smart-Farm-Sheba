import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() =>
      _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final titleController = TextEditingController();
  final costController = TextEditingController();
  final profitController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> records = [];

  double get totalCost =>
      records.fold(0, (sum, item) => sum + item['cost']);

  double get totalProfit =>
      records.fold(0, (sum, item) => sum + item['profit']);

  double get net =>
      totalProfit - totalCost;

  void addRecord() {
    if (titleController.text.isEmpty ||
        costController.text.isEmpty ||
        profitController.text.isEmpty) return;

    setState(() {
      records.add({
        "title": titleController.text,
        "cost": double.parse(costController.text),
        "profit": double.parse(profitController.text),
        "date": selectedDate,
      });
    });

    titleController.clear();
    costController.clear();
    profitController.clear();
    Navigator.pop(context);
  }

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Record"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: "Title"),
                ),
                TextField(
                  controller: costController,
                  keyboardType:
                      TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Cost"),
                ),
                TextField(
                  controller: profitController,
                  keyboardType:
                      TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Profit"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked =
                        await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          DateTime(2020),
                      lastDate:
                          DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                      DateFormat('dd MMM yyyy')
                          .format(selectedDate)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: addRecord,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farm Finance"),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: showDialogBox,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [

          // ✅ Summary
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text("Total Cost: ৳ $totalCost"),
                Text("Total Profit: ৳ $totalProfit"),
                Text("Net: ৳ $net",
                    style: TextStyle(
                        color: net >= 0
                            ? Colors.green
                            : Colors.red)),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (_, index) {
                final item = records[index];
                return ListTile(
                  title: Text(item['title']),
                  subtitle: Text(
                      "${DateFormat('dd MMM yyyy').format(item['date'])}"),
                  trailing: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text("Cost: ৳ ${item['cost']}"),
                      Text(
                          "Profit: ৳ ${item['profit']}"),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}