
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(HydroponicsApp());
}

class HydroponicsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydroponics System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ApiService apiService = ApiService();
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var response = await apiService.fetchData();
    setState(() {
      data = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hydroponics Dashboard'),
      ),
      body: data == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Stats Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InfoCard(title: 'Water Level', value: '${data!['water_level']}%'),
                      InfoCard(title: 'Flow Rate', value: '${data!['water_flow_rate']} L/min'),
                      InfoCard(title: 'pH', value: '${data!['pH']}'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InfoCard(title: 'Soil Moisture', value: '${data!['soil_moisture']}%'),
                      InfoCard(title: 'EC', value: '${data!['EC']}'),
                      InfoCard(title: 'TDS', value: '${data!['TDS']}'),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Alerts Section
                  Text('Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  AlertCard(
                      title: 'Low Water Level', alertStatus: data!['alerts']['low_water'] ? 'Yes' : 'No'),
                  AlertCard(
                      title: 'Overflow', alertStatus: data!['alerts']['overflow'] ? 'Yes' : 'No'),
                  AlertCard(
                      title: 'pH Imbalance', alertStatus: data!['alerts']['pH_imbalance'] ? 'Yes' : 'No'),
                  AlertCard(
                      title: 'EC Imbalance', alertStatus: data!['alerts']['EC_imbalance'] ? 'Yes' : 'No'),
                  SizedBox(height: 30),

                  // Graphs Section
                  Text('Water Level and Flow Rate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Expanded(child: WaterLevelFlowRateGraph(waterLevel: data!['water_level'], flowRate: data!['water_flow_rate'])),
                ],
              ),
            ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String alertStatus;

  const AlertCard({required this.title, required this.alertStatus});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: alertStatus == 'Yes' ? Colors.red : Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Alert: $alertStatus', style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class WaterLevelFlowRateGraph extends StatelessWidget {
  final double waterLevel;
  final double flowRate;

  const WaterLevelFlowRateGraph({required this.waterLevel, required this.flowRate});

  @override
  Widget build(BuildContext context) {
    final data = [
      charts.Series<int, String>(
        id: 'WaterLevelFlowRate',
        domainFn: (int value, _) => value == 0 ? 'Water Level' : 'Flow Rate',
        measureFn: (int value, _) => value.toDouble(),
        data: [waterLevel.toInt(), flowRate.toInt()],
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];

    return charts.BarChart(
      data,
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      vertical: false,
    );
  }
}
