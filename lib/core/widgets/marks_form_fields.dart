import 'package:flutter/material.dart';
import 'package:t7kem_al7an/core/widgets/custom_form_field.dart';
import 'package:t7kem_al7an/core/widgets/pdf_viewer.dart';

import '../constants/al7an.dart';

class MarksFormFields {
  static Widget total(TextEditingController controller) {
    return Column(
      children: [
        const Divider(indent: 20, endIndent: 20),
        const SizedBox(height: 10),
        CustomTextFormField(
          inputType: TextInputType.number,
          controller: controller,
          text: Al7an.total,
        ),
      ],
    );
  }

  static Widget slok(TextEditingController controller) {
    return Column(
      children: [
        const Divider(indent: 20, endIndent: 20),
        const SizedBox(height: 10),
        CustomTextFormField(
          inputType: TextInputType.number,
          controller: controller,
          text: "${Al7an.slok} 10 درجات",
        ),
      ],
    );
  }

  static Widget copticReading(TextEditingController controller) {
    return Column(
      children: [
        const Divider(indent: 20, endIndent: 20),
        const SizedBox(height: 10),
        CustomTextFormField(
          inputType: TextInputType.number,
          controller: controller,
          text: "${Al7an.copticReading} 5 درجات",
        ),
      ],
    );
  }

  static Widget taks(TextEditingController controller, int maxMark) {
    return Column(
      children: [
        const Divider(indent: 20, endIndent: 20),
        const SizedBox(height: 10),
        CustomTextFormField(
          inputType: TextInputType.number,
          controller: controller,
          text: "${Al7an.taks} $maxMark درجات",
        ),
      ],
    );
  }

  static Column kgForm(L7n l7n, List<TextEditingController> controllers) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        nameRow(l7n),
        const SizedBox(height: 20),
        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: "${Al7an.tslem} 20 درجة",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: "${Al7an.tempo} 10 درجات",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: "${Al7an.ro7ania} 10 درجات",
        ),
      ],
    );
  }

  static Column taltaForm(
    L7n l7n,
    List<TextEditingController> controllers,
    List<bool> isChecked,
    void Function(int index, bool? value) onChanged,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        nameRow(l7n),
        const SizedBox(height: 20),
        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: "${Al7an.tslem} 20 درجة",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: "${Al7an.tempo} 10 درجات",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: "${Al7an.ro7ania} 10 درجات",
        ),
        CustomTextFormField(
          controller: controllers[3],
          inputType: TextInputType.number,
          text: "${Al7an.copticSpelling} 10 درجات",
        ),
        if (l7n.hasTools)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                Al7an.df,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Checkbox(
                value: isChecked[0],
                onChanged: (val) => onChanged(0, val),
              ),
              const SizedBox(width: 30),
              const Text(
                Al7an.treanto,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Checkbox(
                value: isChecked[1],
                onChanged: (val) => onChanged(1, val),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Al7an.hzat,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Checkbox(
              value: isChecked[2],
              onChanged: (val) => onChanged(2, val),
            ),
          ],
        ),
      ],
    );
  }

  static Column mohobenIndividualForm(
      L7n l7n,
      List<TextEditingController> controllers,
      List<bool> isChecked,
      void Function(int index, bool? value) onChanged,
      int level) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        nameRow(l7n),
        const SizedBox(height: 20),
        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: "${Al7an.tslem}15 درجة",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: "${Al7an.copticReading} 10 درجات",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: "${Al7an.ro7ania} 10 درجات",
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Al7an.taks,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Checkbox(
                value: isChecked[0], onChanged: (val) => onChanged(0, val)),
            if (l7n.hasTools) ...[
              const SizedBox(width: 30),
              const Text(
                Al7an.df,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Checkbox(
                value: isChecked[1],
                onChanged: (val) => onChanged(1, val),
              ),
            ]
          ],
        ),
      ],
    );
  }

  static Column mohobenGroupForm(
      L7n l7n,
      List<TextEditingController> controllers,
      List<bool> isChecked,
      void Function(int index, bool? value) onChanged,
      int level) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        nameRow(l7n),
        const SizedBox(height: 20),
        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: "${Al7an.tslem} 20 درجة",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: "${Al7an.tempo} 10 درجات",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: "${Al7an.tnas2} 10 درجات",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[3],
          inputType: TextInputType.number,
          text: "${Al7an.copticReading} 10 درجات",
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[4],
          inputType: TextInputType.number,
          text: "${Al7an.ro7ania} 10 درجات",
        ),
        if (l7n.hasTools) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                Al7an.df,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Checkbox(
                value: isChecked[1],
                onChanged: (val) => onChanged(1, val),
              ),
              const SizedBox(width: 20),
              const Text(
                Al7an.treanto,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Checkbox(
                value: isChecked[2],
                onChanged: (val) => onChanged(2, val),
              ),
            ],
          )
        ],
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Al7an.taks,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Checkbox(
                value: isChecked[0], onChanged: (val) => onChanged(0, val)),
          ],
        ),
      ],
    );
  }

  static Widget submitButton(
      {required void Function() onPressed, String? text}) {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text ?? "تسليم",
            style: const TextStyle(
              color: Colors.amberAccent,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      onTap: () => onPressed(),
    );
  }

  static Widget nameRow(L7n l7n) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Text(
              l7n.name,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          if (l7n.pdfUrl != null) ...[
            const SizedBox(width: 8),
            InkWell(
                onTap: () {
                  PdfViewerScreen(
                    title: l7n.name,
                    url: l7n.pdfUrl!,
                  );
                },
                child: const Icon(Icons.insert_drive_file_rounded)),
            const SizedBox(width: 15)
          ]
        ],
      ),
    );
  }

  static Future<bool> showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text('هل تريد الخروج؟ سيتم فقد البيانات غير المحفوظة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
