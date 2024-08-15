import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Widget plotGraph(String title, int xIndex, int yIndex, Color color,
    String yLabel, String xLabel, List<List<double>> data) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 20.0, bottom: 10.0, top: 10),
        child: SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    yLabel,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    xLabel,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false), // Hide labels on the top axis
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false), // Hide labels on the right axis
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data.map((e) => FlSpot(e[xIndex], e[yIndex])).toList(),
                  isCurved: false,
                  color: color,
                  barWidth: 0,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      )
    ],
  );
}

Widget plotPowerGraph(String title, Color color, String yLabel, String xLabel,
    List<List<double>> data) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 20.0, bottom: 10.0, top: 10),
        child: SizedBox(
          height: 325,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    yLabel,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    xLabel,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false), // Hide labels on the top axis
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false), // Hide labels on the right axis
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data.map((e) => FlSpot(e[2], e[2] * e[3])).toList(),
                  isCurved: false,
                  color: color,
                  barWidth: 0,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      )
    ],
  );
}
