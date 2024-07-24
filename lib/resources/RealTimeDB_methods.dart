import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RealTimeDB_Methods {
  // DatabaseReference _realtimedb = FirebaseDatabase.instance.ref("chats");
  DatabaseReference _realtimedb = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
      'https://instagram-clone-3f367-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("chats");

  Map<String, dynamic> json_data(String currUserId, String receiverId, String msg,String receiverName,String senderName) {
    return {
      "isSenderTyping": false,
      "isReceiverTyping": false,
      "timestamp": ServerValue.timestamp,
      "Message": {
        "msg": msg,
        "senderId": currUserId,
        "receiverId": receiverId,
        "receiverName": receiverName,
        "senderName": senderName,
      }
    };
  }

  Future<String> storeDataToRealTimeDb(
      {required String currUserId,
      required String receiverId,
        required String senderName,
      required String msg,
        required String receiverName,
      }) async {
    String res = "some error occurred";

    try {
      List<String> ids = [currUserId, receiverId];
      ids.sort();
      print("-------Sorted ids: ${ids}--------");
      String chatRoomId = ids[0] + "-" + ids[1];
      print("--------Generated Chatroom id is: ${chatRoomId}--------");

      await _realtimedb.child(chatRoomId).push().set(json_data(currUserId, receiverId, msg,receiverName, senderName));
      res = "success";
      print(res);
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> getData() async
  {
    String res="some error occurred";
    try{
      //code
      res="success";
    } catch (err){
      res=err.toString();
    }
    return res;
  }
}
