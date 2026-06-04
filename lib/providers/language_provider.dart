import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'English';

  String get currentLanguage => _currentLanguage;

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String translate(String key) {
    if (_currentLanguage == 'ខ្មែរ') {
      return _khmer[key] ?? key;
    } else if (_currentLanguage == '中文') {
      return _chinese[key] ?? key;
    }
    return _english[key] ?? key;
  }

  static const Map<String, String> _english = {
    'home': 'Home',
    'menu': 'Menu',
    'me': 'Me',
    'my_bag': 'My Bag',
    'my_orders': 'MY ORDERS',
    'my_qr': 'My QR',
    'gift_card': 'GIFT CARD',
    'find_a_store': 'FIND A STORE',
    'languages': 'Languages',
    'support': 'Support',
    'settings': 'Settings',
    'dark_mode': 'Dark Mode',
    'clear_cache': 'Clear cache',
    'log_out': 'LOG OUT',
    'delete_account': 'Delete account',
    'privacy_policy': 'Privacy policy',
    'faqs': 'FAQs & guides',
    'rate_app': 'Rate this app',
    'recommend_app': 'Recommend this app',
    'contact_us': 'Contact us',
    'search_hint': 'What are you searching for?',
    'free_delivery': 'Free delivery with up to 40+ USD Spent',
  };

  static const Map<String, String> _khmer = {
    'home': 'ទំព័រដើម',
    'menu': 'ម៉ឺនុយ',
    'me': 'គណនី',
    'my_bag': 'កាបូបរបស់ខ្ញុំ',
    'my_orders': 'ការបញ្ជាទិញ',
    'my_qr': 'QR របស់ខ្ញុំ',
    'gift_card': 'កាតកាដូ',
    'find_a_store': 'ស្វែងរកហាង',
    'languages': 'ភាសា',
    'support': 'ជំនួយ',
    'settings': 'ការកំណត់',
    'dark_mode': 'របៀបងងឹត',
    'clear_cache': 'សម្អាតទិន្នន័យបណ្តោះអាសន្ន',
    'log_out': 'ចាកចេញ',
    'delete_account': 'លុបគណនី',
    'privacy_policy': 'គោលការណ៍ឯកជនភាព',
    'faqs': 'សំណួរដែលសួរញឹកញាប់',
    'rate_app': 'វាយតម្លៃកម្មវិធី',
    'recommend_app': 'ណែនាំកម្មវិធីនេះ',
    'contact_us': 'ទាក់ទងមកយើង',
    'search_hint': 'តើអ្នកកំពុងស្វែងរកអ្វី?',
    'free_delivery': 'ដឹកជញ្ជូនឥតគិតថ្លៃរាល់ការចំណាយចាប់ពី ៤០ ដុល្លារឡើងទៅ',
  };

  static const Map<String, String> _chinese = {
    'home': '首页',
    'menu': '菜单',
    'me': '我的',
    'my_bag': '我的购物袋',
    'my_orders': '我的订单',
    'my_qr': '我的二维码',
    'gift_card': '礼品卡',
    'find_a_store': '查找门店',
    'languages': '语言',
    'support': '支持',
    'settings': '设置',
    'dark_mode': '深色模式',
    'clear_cache': '清除缓存',
    'log_out': '退出登录',
    'delete_account': '注销账号',
    'privacy_policy': '隐私政策',
    'faqs': '常见问题',
    'rate_app': '评价应用',
    'recommend_app': '推荐此应用',
    'contact_us': '联系我们',
    'search_hint': '您想搜索什么？',
    'free_delivery': '消费满 40 美元即可享受免运费',
  };
}
