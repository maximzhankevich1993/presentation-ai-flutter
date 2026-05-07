import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CorporateScreen extends StatefulWidget {
  final String countryCode;
  const CorporateScreen({super.key, required this.countryCode});

  @override
  State<CorporateScreen> createState() => _CorporateScreenState();
}

class _CorporateScreenState extends State<CorporateScreen> {
  final _company = TextEditingController();

  @override
  void dispose() {
    _company.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Бизнесу', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('💼', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Россия', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Валюта: RUB | Налоги: НДС', style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3))),
                Text('Интеграции: 1С, Битрикс24', style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3))),
              ])),
            ]),
          ),
          SizedBox(height: 20.h),
          Text('Создать документ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 10.h),
          TextField(
            controller: _company,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Название компании',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true, fillColor: card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: green, padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Сгенерировать КП', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
          SizedBox(height: 20.h),
          Text('Тарифы', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 10.h),
          _plan('Business', '\$9.99', '/мес', false),
          _plan('Corporate', '\$49.99', '/10 чел.', true),
          _plan('Enterprise', '\$199', '/50 чел.', false),
        ]),
      ),
    );
  }

  Widget _plan(String name, String price, String period, bool featured) {
    const green = Color(0xFF1DB954);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: featured ? green.withOpacity(0.1) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: featured ? green.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
      ),
      child: Row(children: [
        if (featured) Container(
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(6)),
          child: const Text('POP', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w700)),
        ),
        Expanded(child: Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: green)),
          Text(period, style: TextStyle(fontSize: 10, color: const Color(0xFFB3B3B3))),
        ]),
      ]),
    );
  }
}