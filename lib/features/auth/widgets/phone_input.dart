import 'package:flutter/material.dart';
import 'package:phone_input/phone_input_package.dart';

class ShowPhoneInput extends StatefulWidget {
  const ShowPhoneInput({super.key});

  @override
  State<ShowPhoneInput> createState() => _ShowPhoneInputState();
}

class _ShowPhoneInputState extends State<ShowPhoneInput> {
  final LayerLink layerLink = LayerLink();

  final _controller = PhoneController(
    PhoneNumber(isoCode: IsoCode.BD, nsn: ''),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneInput(
      isCountrySelectionEnabled: false,
      controller: _controller,
      showArrow: false,
      shouldFormat: true,
      validator: PhoneValidator.compose([
        PhoneValidator.required(),
        PhoneValidator.valid(),
      ]),
      flagShape: BoxShape.circle,
      showFlagInInput: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      countrySelectorNavigator: CountrySelectorNavigator.dropdown(
        layerLink: layerLink,
      ),
    );
  }
}
