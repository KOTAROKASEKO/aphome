
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final String? userId;

  ReportScreen(this.userId);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _reportController = TextEditingController();
  bool _loading = false;

  Future<void> _sendReport() async {
    if (_reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a report')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    await FirebaseFirestore.instance.collection('reports').add({
      'report': _reportController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'ReporteduserId': widget.userId, // Include userId in the report
    });

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report sent successfully')),
    );

    _reportController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _reportController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter your report here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _sendReport,
              child: _loading
                  ? CircularProgressIndicator()
                  : Text('Send Report'),
            ),
          ],
        ),
      ),
    );
  }
}
