// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:untitled/screens/children_list_page.dart';
import 'package:untitled/screens/food_search_page.dart';
import 'package:untitled/widgets/language_selector.dart';
import 'package:untitled/screens/ai_chat_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('menu'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy), // 🤖 AI 아이콘
            tooltip: 'AI Chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiChatPage()),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[200]),
              child: const Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.child_care),
              title: Text('Child Profiles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildrenListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('식품 성분 검색'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodSearchPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const LanguageSelector(),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text('select_menu'.tr())),
    );
  }
}
