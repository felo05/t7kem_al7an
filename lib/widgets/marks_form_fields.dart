import 'package:flutter/material.dart';
import 'package:t7kem_al7an/widgets/custom_form_field.dart';

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

  static Widget copticReading(TextEditingController controller) {
    return Column(
      children: [
        const Divider(indent: 20, endIndent: 20),
        const SizedBox(height: 10),
        CustomTextFormField(
          inputType: TextInputType.number,
          controller: controller,
          text: Al7an.copticReading,
        ),
      ],
    );
  }

  static Widget taks(TextEditingController controller) {
    return Column(
      children: [
        const Divider(indent: 20, endIndent: 20),
        const SizedBox(height: 10),
        CustomTextFormField(
          inputType: TextInputType.number,
          controller: controller,
          text: Al7an.taks,
        ),
      ],
    );
  }

  static Column kgForm(String l7n, List<TextEditingController> controllers) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l7n,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: Al7an.tslem,
        ),
        const SizedBox(height: 10),

        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: Al7an.tempo,
        ),
        const SizedBox(height: 10),

        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: Al7an.ro7ania,
        ),
      ],
    );
  }

  static Column taltaForm(
    String l7n,
    List<TextEditingController> controllers,
    List<bool> isChecked,
    void Function(int index, bool? value) onChanged,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l7n,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: Al7an.tslem,
        ),
        const SizedBox(height: 10),

        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: Al7an.tempo,
        ),
        const SizedBox(height: 10),

        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: Al7an.ro7ania,
        ),

        CustomTextFormField(
          controller: controllers[3],
          inputType: TextInputType.number,
          text: Al7an.copticSpelling,
        ),

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
    String l7n,
    List<TextEditingController> controllers,
    List<bool> isChecked,
    void Function(int index, bool? value) onChanged,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l7n,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: Al7an.tslem,
        ),
        const SizedBox(height: 10),

        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: Al7an.copticReading,
        ),
        const SizedBox(height: 10),

        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: Al7an.ro7ania,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Al7an.taks,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Checkbox(value: isChecked[0], onChanged: (val) => onChanged(2, val)),
            const SizedBox(width: 30),
            const Text(
              Al7an.df,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Checkbox(
              value: isChecked[1],
              onChanged: (val) => onChanged(1, val),
            ),
          ],
        ),
      ],
    );
  }
  static Column mohobenGroupForm(
      String l7n,
      List<TextEditingController> controllers,
      List<bool> isChecked,
      void Function(int index, bool? value) onChanged,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l7n,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        CustomTextFormField(
          controller: controllers[0],
          inputType: TextInputType.number,
          text: Al7an.tslem,
        ),
        const SizedBox(height: 10),

        CustomTextFormField(
          controller: controllers[1],
          inputType: TextInputType.number,
          text: Al7an.tempo,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[2],
          inputType: TextInputType.number,
          text: Al7an.tnas2,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[3],
          inputType: TextInputType.number,
          text: Al7an.copticReading,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controllers[4],
          inputType: TextInputType.number,
          text: Al7an.ro7ania,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Al7an.taks,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Checkbox(value: isChecked[0], onChanged: (val) => onChanged(2, val)),
            const SizedBox(width: 30),
            const Text(
              Al7an.df,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Checkbox(
              value: isChecked[1],
              onChanged: (val) => onChanged(1, val),
            ),
          ],
        ),
      ],
    );
  }

  static Widget submitButton({ required void Function() onPressed, String? text}) {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(15),
        ),
        child:  Center(
          child: Text(
            text??"تسليم",
            style: const TextStyle(
              color: Colors.amberAccent,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      onTap: () =>
        onPressed(),

    );
  }
}
