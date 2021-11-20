import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/models/models.dart';

/// Контроллер окна отображения текущей задачи
class TodoViewController extends GetxController {
  TodoViewController({
    FirebaseFirestore? db,
  }) : _service = TodoService(db);

  static final _log = Logger('TodoViewController');

  final TodoService _service;
  final _state = TodoViewCurrentState.unknown.obs;

  /// Слушатель изменений в документе связанном со списком дел
  StreamSubscription? _todoSubscriber;

  /// ID документа списка дел в firestore
  String? docId;

  /// Была проблема с использованием реактивной переменной .obs, модель не обновлялась как следует.
  /// При обновлении в сервисе Firestore обновление происходило как следует,
  /// но при работе из GUI - данные обновлялись на сервере, приходили, парсились, корректно записывались в модель,
  /// но не щелкали перестраивание интерфейса. По-этому я решил использовать подход близкий
  /// к библиотеке Provider и "вручную" оповещать слушателей при помощи метода update().
  /// Мне кажется, что такая проблема сложилась из-за того, что объект модели имеет внутри себя список,
  /// с которым немного некорректно и работал .obs, так как сам список внутри модели не реактивного типа
  TodoModel? _todoModel;

  TodoModel? get todoModel => _todoModel;

  /// Статус загрузки списка дел
  TodoViewCurrentState get state => _state.value;

  bool get isTodoCompleted => todoModel!.completed;

  @override
  void onClose() {
    _todoSubscriber?.cancel();
    super.onClose();
  }

  /// Инициализация контроллера данными из БД
  void loadTodoModel(String docId) {
    this.docId = docId;
    try {
      _log.fine('loading - $docId');
      _state.value = TodoViewCurrentState.loading;
      _todoSubscriber = _service.createSingleTodoStream(docId).listen((event) {
        if (event.data() != null) {
          _todoModel = TodoModel.fromJson(event.data()!);
          // Причина почему здесь вызывается update(); описана в комментариях к переменной [_todoModel]
          update();
          // Установка флага при первой загрузке модели
          if (_state.value != TodoViewCurrentState.loaded) {
            _log.fine('loaded - $docId');
            _state.value = TodoViewCurrentState.loaded;
          }
        } else {
          // Данных может не быть, если документа по этому id не существует
          _log.shout('non data - $docId');
          _state.value = TodoViewCurrentState.error;
        }
      });
    } catch (e) {
      _log.shout('ERROR $e - $docId');
      _state.value = TodoViewCurrentState.error;
    }
  }

  /// Сменить статус элемента [todoElementUid] в писке дел на тот, что представлен в параметре [isCompleted]
  Future<void> changeTodoElementCompleteStatus({required bool isCompleted, required String todoElementUid}) async {
    try {
      _log.fine('Change element $todoElementUid to completed status - $isCompleted');
      if (docId != null && todoModel != null) {
        final todo = todoModel!;
        final item = todo.elements.firstWhere((element) => element.uid == todoElementUid);
        if (item.completed != isCompleted) {
          final changedItem = item.copyWith(completed: isCompleted);
          final index = todo.elements.indexOf(item);
          todo.elements[index] = changedItem;
          await _service.updateTodo(docId!, todo);
          _log.fine('Successful change of element $todoElementUid status to - $isCompleted');
        }
      } else {
        _log.fine('Assert error while change element $todoElementUid to status - $isCompleted');
      }
    } catch (error) {
      _log.shout(error);
    }
  }
}

/// Вспомогательное перечисление для индикации статуса загрузки списка дел в контроллер
enum TodoViewCurrentState {
  unknown,
  loading,
  error,
  loaded,
}
