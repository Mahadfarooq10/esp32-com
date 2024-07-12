import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Widget plotGraph(String title, int xIndex, int yIndex, Color color, String yLabel, String xLabel, List<List<double>> data) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text(yLabel),
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(xLabel),
                sideTitles: SideTitles(showTitles: true),
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
    ],
  );
}

Widget plotPowerGraph(String title, Color color, String yLabel, String xLabel, List<List<double>> data) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text(yLabel),
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(xLabel),
                sideTitles: SideTitles(showTitles: true),
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
    ],
  );
}