import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iothub/models/ObyvakAqaraTemperatureSensor.dart';

class FbRepository {

  final CollectionReference collection = Firestore.instance.collection('obyvakAqaraTemperatureSensor');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> addObyvakAqaraTemperatureSensor(ObyvakAqaraTemperatureSensor sensor) {
    return collection.add(sensor.toJson());
  }

  updateObyvakAqaraTemperatureSensor(ObyvakAqaraTemperatureSensor sensor) async {
    await collection.document(sensor.reference.documentID).updateData(sensor.toJson());
  }

}