class L7n{
  final String name;
  final bool hasTools;
  final String? pdfUrl;

  L7n({required this.name,  this.hasTools=false, this.pdfUrl});
}

class Al7an {
  static List<L7n> kg1 = [
   L7n(name: "مرد انجيل رفع بخور عشية السنوى (جمفثمارؤوت)"),
    L7n(name: "سوتيس امين دمج"),
    L7n(name: "مرد مزمور عيد القيامة"),
    L7n(name: "ختام الصلوات عيد القيامة"),
  ];
  static List<L7n> kg2 = [
    kg1[0],
    kg1[1],
    L7n(name: "مرد المجمع (ارابواسمو)"),
    L7n(name: "مرد انجيل القداس سنوي (اونياطو)"),
    L7n(name: "هيتينية القيامة للملاك ميخائيل"),
    L7n(name: "مرد التوزيع لعيد القيامة (الطريقة السريعة)"),
  ];
  static List<L7n> kg3 = [
    L7n(name: "لحن البركة"),
    L7n(name: "مقدمة الذكصولوجيات الفرايحي (الطريقة الوسط)"),
    L7n(name: "اجيوس الفرايحي الكبير"),
  ];
  static List<L7n> ola1 = [
    L7n(name: "الليلويا فاي بابي"),
    L7n(name: "ختام التسبحة (افنوتي نان)"),
    L7n(name: "مرد انجيل عيد القيامة (اللليلويا)"),
    L7n(name: "جمفثمارؤوت صيام الرسل"),
  ];
  static List<L7n> ola2 = [
    ola1[0],
    ola1[1],
    L7n(name: "الليلويا جي افمفئي"),
    L7n(name: "ذكصوبوجية مارمرقس"),
    L7n(name: "ارباع الناقوس فرايحي لعيد القيامة (اول 3 اربع فقط)"),
    L7n(name: "مرد انجيل عيد القيامة (ليبون)"),
  ];
  static List<L7n> ola3 = [
    L7n(name: "الاسبزمس الواطس السنوي (ابتوشيس افنوتي)"),
    L7n(name: "كاطانى خوروس التوزيع"),
    L7n(name: "بخرستوس افطونف عيد القيامة"),
  ];
  static List<L7n> talta1 = [
    L7n(name: "ذكصولوجية الرسل"),
    L7n(name: "تي شوري"),
    L7n(name: "طون سينا"),
    L7n(name: "مقدمة بى ابنفما"),
  ];
  static List<L7n> talta2 = [
    talta1[0],
    talta1[1],
    L7n(name: "ذكصولوجية العذراء لرفع بخور عشية"),
    L7n(name: "المزمور ال150 من الهوس الرابع"),
    L7n(name: "باشويس عيد القيامة (المحير)"),
    L7n(name: "مرد التوزيع لعيد القيامة (الطريقة الوسط)"),
  ];
  static List<L7n> talta3 = [
    L7n(name: "مرد الابركسيس السنوي الكبير بالتكملة"),
    L7n(name: "اللى التوزيع الكبير لعيد القيامو"),
    L7n(name: "المزمور السنجاري الكبير لعيد القيامة"),
  ];
  static List<L7n> khamsa1 = [
    L7n(name: "ذكصولوجية العذراء لرفع بخور باكر"),
    L7n(name: "مرد الابركسيس السنوي"),
    L7n(name: "ذكصولوجية عيد القيامة"),
    L7n(name: "مرد قطع الساعة الثالثة"),
  ];
  static List<L7n> khamsa2 = [
    khamsa1[0],
    khamsa1[1],
    L7n(name: "ذكصولوجية السمائيين"),
    L7n(name: "مردات الانافورة باسيلي وغريغوري"),
    L7n(name: "ارباع الناقوس لعيد القيامة (اول 3 ارباع كبار + العذراء والملاك ميخائيل + الختام)"),
    L7n(name: "مردالابركسيس لعيد القيامة"),
  ];
  static List<L7n> khamsa3 = [
    L7n(name: "اسبازستي الكبير"),
    L7n(name: "بي ابنفما + البرلكس + المحير"),
    L7n(name: "البولس الفرايحي"),
  ];
  static const String df = "دف";
  static const String treanto = "تريانتو";
  static const String tslem = "سلامة التسليم واجادة الحفظ";
  static const String tempo = "انتظام السرعة والايقاع";
  static const String ro7ania = "روحانية وجمال الاداء";
  static const String copticSpelling = "سلامة النطق لكلمات اللحن";
  static const String tnas2 = "تناسق الاداء الجماعى";
  static const String total = "عدد الاولاد";
  static const String hzat ="استخدام ورق هزات";
  static const String copticReading="القراءة باللغة القبطية";
  static const String taks="المادة الطقسية";
  static const String slok="نظام وسلوك";
}
