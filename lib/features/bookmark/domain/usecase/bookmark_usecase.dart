import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/bookmark/domain/repository/bookmark_repository.dart';

class FetchBookMarkUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final BookMarkRepository _bookMarkRepository;
  const FetchBookMarkUseCase(this._bookMarkRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _bookMarkRepository.fetchBookmark(params);
  }
}

class DeleteBookMarkMapelUseCase
    implements BaseUseCase<bool, Map<String, dynamic>> {
  final BookMarkRepository _bookMarkRepository;
  const DeleteBookMarkMapelUseCase(this._bookMarkRepository);

  @override
  Future<bool> call({Map<String, dynamic>? params}) {
    return _bookMarkRepository.deleteBookmarkMapel(params);
  }
}

class DeleteBookMarkUseCase implements BaseUseCase<bool, Map<String, dynamic>> {
  final BookMarkRepository _bookMarkRepository;
  const DeleteBookMarkUseCase(this._bookMarkRepository);

  @override
  Future<bool> call({Map<String, dynamic>? params}) {
    return _bookMarkRepository.deleteBookmark(params);
  }
}

class AddBookMarkUseCase implements BaseUseCase<bool, Map<String, dynamic>> {
  final BookMarkRepository _bookMarkRepository;
  const AddBookMarkUseCase(this._bookMarkRepository);

  @override
  Future<bool> call({Map<String, dynamic>? params}) {
    return _bookMarkRepository.addBookmark(params);
  }
}
