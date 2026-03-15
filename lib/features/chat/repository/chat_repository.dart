import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/chat/model/chat_models.dart';

/// Repository for chat thread API: messages, send message, mark read.
final class ChatRepository extends BaseRepository {
  ChatRepository(this._pigeon);

  final AuthorizedPigeon _pigeon;

  /// POST create or get the user's thread with admin (e.g. coach). Returns thread id and counterpart name.
  FutureRequest<ChatThreadInfo> createOrGetThread() async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.post(ApiEndpoints.chatThreads, data: {});
        final data = response.data;
        if (data is! Map || data['data'] is! Map) {
          throw Exception('Invalid create thread response');
        }
        final threadData = data['data'] as Map<String, dynamic>;
        final id = threadData['id']?.toString().trim() ?? '';
        if (id.isEmpty) throw Exception('Invalid thread id');
        final counterpart = threadData['counterpart'];
        String name = 'Admin';
        if (counterpart is Map<String, dynamic>) {
          final first = counterpart['firstName']?.toString().trim();
          if (first != null && first.isNotEmpty) name = first;
        }
        return ChatThreadInfo(threadId: id, counterpartName: name);
      },
    );
  }

  /// GET thread messages (paginated). Returns messages in chronological order.
  FutureRequest<ChatMessagesResponse> getThreadMessages({
    required String threadId,
    int page = 1,
    int limit = 30,
  }) async {
    return asyncTryCatch(
      tryFunc: () async {
        final uri =
            '${ApiEndpoints.chatThreadMessages(threadId)}?page=$page&limit=$limit';
        final response = await _pigeon.get(uri);
        final data = response.data;
        final list = data is Map && data['data'] is List
            ? (data['data'] as List)
                .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
            : <ChatMessage>[];
        final meta = data is Map && data['meta'] is Map
            ? data['meta'] as Map<String, dynamic>
            : <String, dynamic>{};
        return ChatMessagesResponse(
          messages: list,
          page: (meta['page'] is int) ? meta['page'] as int : page,
          limit: (meta['limit'] is int) ? meta['limit'] as int : limit,
          total: (meta['total'] is int) ? meta['total'] as int : list.length,
        );
      },
    );
  }

  /// POST send a message in the thread.
  FutureRequest<ChatMessage> sendMessage({
    required String threadId,
    required String text,
  }) async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.post(
          ApiEndpoints.chatThreadSendMessage(threadId),
          data: {'message': text},
        );
        final data = response.data;
        final msg = data is Map && data['data'] is Map
            ? ChatMessage.fromJson(Map<String, dynamic>.from(data['data'] as Map))
            : null;
        if (msg == null) throw Exception('Invalid send message response');
        return msg;
      },
    );
  }

  /// PATCH mark thread messages as read.
  FutureRequest<void> markThreadAsRead(String threadId) async {
    return asyncTryCatch(
      tryFunc: () async {
        await _pigeon.patch(ApiEndpoints.chatThreadMarkRead(threadId));
      },
    );
  }
}

class ChatMessagesResponse {
  final List<ChatMessage> messages;
  final int page;
  final int limit;
  final int total;

  const ChatMessagesResponse({
    required this.messages,
    required this.page,
    required this.limit,
    required this.total,
  });
}

class ChatThreadInfo {
  final String threadId;
  final String counterpartName;

  const ChatThreadInfo({
    required this.threadId,
    required this.counterpartName,
  });
}
