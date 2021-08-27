import 'package:get/get.dart';

class TestModel extends GetxController {
  late final RxInt _rndNum;

  TestModel({required int rndNum}) : _rndNum = rndNum.obs;

  RxInt get rndNum => _rndNum;
}
