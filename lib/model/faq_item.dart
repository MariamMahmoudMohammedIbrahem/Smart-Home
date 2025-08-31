import '../commons.dart';

class FAQItem {
  final String title;
  final String? description;
  final Widget? customSubtitle;

  FAQItem({required this.title, this.description, this.customSubtitle});
}
