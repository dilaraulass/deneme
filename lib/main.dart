import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalTasks = 0;
  int completedTasks = 0;
  int pendingTasks = 0;
  List<Map<String, dynamic>> completedTasksList = [];
  List<Map<String, dynamic>> pendingTasksList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // API'den verileri çekme
    final response = await http.get(Uri.parse('http://api.nstack.in/tasks/all'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalTasks = data['total_tasks'];
        completedTasks = data['completed_tasks'];
        pendingTasks = data['pending_tasks'];
        completedTasksList = List<Map<String, dynamic>>.from(data['completed_tasks_list']);
        pendingTasksList = List<Map<String, dynamic>>.from(data['pending_tasks_list']);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? HomePageContent(totalTasks, completedTasks, pendingTasks, pendingTasksList)
          : _selectedIndex == 1
          ? SecondPage()
          : _selectedIndex == 2
          ? AllTasksPage(completedTasksList, pendingTasksList)
          : ThirdPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Giriş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task),
            label: 'Yeni Görev',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tüm Görevler',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final List<Map<String, dynamic>> pendingTasksList;

  HomePageContent(this.totalTasks, this.completedTasks, this.pendingTasks, this.pendingTasksList);

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Sütun içindeki öğeleri yatayda merkezler
      children: [

        SizedBox(height: 55), // Yükseklik için boşluk ekler

        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Toplam Görev : $totalTasks', style: TextStyle(fontSize: 18),) ,

        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Tamamlanan Görev : $completedTasks', style: TextStyle(fontSize: 18)),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Bekleyen Görev : $pendingTasks', style: TextStyle(fontSize: 18)),
        ),
        Divider(),

        Text(
          'Bekleyen Görevler',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pendingTasksList.length >= 3 ? 3 : pendingTasksList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  // Bekleyen görevin üzerine tıklandığında düzenleme, silme ve okuma işlemleri için yeni bir ekran açılır
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: pendingTasksList[index])),
                  );
                },
                title: Text(pendingTasksList[index]['title']),
                subtitle: Text(pendingTasksList[index]['description'].length > 100
                    ? pendingTasksList[index]['description'].substring(0, 100) + '...'
                    : pendingTasksList[index]['description']),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  TaskDetailsScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Detayları'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Başlık: ${task['title']}'),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Açıklama: ${task['description']}'),
          ),
          // Düzenleme, silme ve okuma işlemlerini gerçekleştirecek butonlar eklenebilir
          // Örneğin:
          // ElevatedButton(
          //   onPressed: () {
          //     // Düzenleme işlemi için gerekli kodlar
          //   },
          //   child: Text('Düzenle'),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     // Silme işlemi için gerekli kodlar
          //   },
          //   child: Text('Sil'),
          // ),
        ],
      ),
    );
  }
}

class AllTasksPage extends StatelessWidget {
  final List<Map<String, dynamic>> completedTasksList;
  final List<Map<String, dynamic>> pendingTasksList;

  AllTasksPage(this.completedTasksList, this.pendingTasksList);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tüm Görevler'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Tamamlanan'),
              Tab(text: 'Bekleyen'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCompletedTasksList(),
            _buildPendingTasksList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTasksList() {
    return ListView.builder(
      itemCount: completedTasksList.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            // Tamamlanan görevin üzerine tıklandığında düzenleme, silme ve okuma işlemleri için yeni bir ekran açılır
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: completedTasksList[index])),
            );
          },
          title: Text(completedTasksList[index]['title']),
          subtitle: Text(completedTasksList[index]['description']),
        );
      },
    );
  }

  Widget _buildPendingTasksList() {
    return ListView.builder(
      itemCount: pendingTasksList.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            // Bekleyen görevin üzerine tıklandığında düzenleme, silme ve okuma işlemleri için yeni bir ekran açılır
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: pendingTasksList[index])),
            );
          },
          title: Text(pendingTasksList[index]['title']),
          subtitle: Text(pendingTasksList[index]['description']),
        );
      },
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(

    );
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Üçüncü Sayfa',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
