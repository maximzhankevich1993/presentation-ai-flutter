import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/corporate_service.dart';

class CorporateScreen extends StatefulWidget {
  final String countryCode;

  const CorporateScreen({super.key, required this.countryCode});

  @override
  State<CorporateScreen> createState() => _CorporateScreenState();
}

class _CorporateScreenState extends State<CorporateScreen> {
  final _companyController = TextEditingController();
  String _selectedDoc = 'Коммерческое предложение';
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  void _generate() {
    final company = _companyController.text.trim();
    if (company.isEmpty) return;

    setState(() {
      _result = CorporateService.generateDocument(
        documentType: _selectedDoc,
        companyName: company,
        countryCode: widget.countryCode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final country = CorporateService.getCountry(widget.countryCode);
    final countryName = country?.countryName ?? widget.countryCode;
    final documents = CorporateService.getDocumentTypes(widget.countryCode);
    final compliance = CorporateService.getCompliance(widget.countryCode);
    final plans = CorporateService.getPlansForCountry(widget.countryCode);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('Бизнес: $countryName'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== INFO BLOCK =====
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '🏢 $countryName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Валюта: ${country?.currency ?? "USD"} | Налоги: ${country?.taxSystem ?? "Standard"}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// ===== FORM =====
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                hintText: 'Название компании',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            DropdownButtonFormField<String>(
              value: documents.contains(_selectedDoc)
                  ? _selectedDoc
                  : null,
              items: documents
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedDoc = v);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Сгенерировать'),
              ),
            ),

            /// ===== RESULT =====
            if (_result != null) ...[
              SizedBox(height: 24.h),

              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📄 ${_result!['document_type']}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    ...((_result!['slides'] as List?) ?? [])
                        .map(
                          (s) => Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366f1)
                                  .withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['title']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  s['content']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 32.h),

            /// ===== PLANS =====
            Text(
              'Тарифы для бизнеса',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            ...plans.values.map(
              (p) => Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: p.onPremise
                        ? const Color(0xFF6366f1)
                        : Colors.grey.withOpacity(0.1),
                    width: p.onPremise ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          p.price,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6366f1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${p.audience} • До ${p.users} чел.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            /// ===== COMPLIANCE =====
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: compliance
                  .map(
                    (c) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10b981)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('✅ $c'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}