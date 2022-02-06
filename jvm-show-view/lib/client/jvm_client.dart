

import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:rsocket/core/rsocket_requester.dart';
import 'package:rsocket/duplex_connection.dart';
import 'package:rsocket/io/bytes.dart';
import 'package:rsocket/metadata/composite_metadata.dart';
import 'package:rsocket/metadata/wellknown_mimetype.dart';
import 'package:rsocket/payload.dart';
import 'package:rsocket/rsocket.dart';
import 'package:rsocket/rsocket_connector.dart';

class JVMClient {

  late RSocket rSocket;

  /// build connect
  Future<JVMClient> connect({CloseHandler? closeHandler}) async {
    var routingMetadata = RoutingMetadata("connect", List.empty());

    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    // compositeMetadata.addWellKnownMimeType(0x01, Uint8List.fromList(utf8.encode(MIME_TYPES[0x01])));
    // compositeMetadata.addMetadata(TaggingMetadata(MIME_TYPES[0x01], List.empty()));
    // compositeMetadata.addMetadata(MessageMimeTypeMetadata(MIME_TYPES[0x01]));

    // compositeMetadata.addWellKnownMimeType(0x7e, Uint8List.fromList(utf8.encode("connect")));

    var metadata = compositeMetadata.toUint8Array();
    var data = Uint8List.fromList(utf8.encode("dart"));

    var connectionSetupPayload = ConnectionSetupPayload();
    connectionSetupPayload.metadata = metadata;
    connectionSetupPayload.data = data;

    var rSocketFuture = RSocketConnector.create()
        .setupPayload(connectionSetupPayload)
        .dataMimeType(MIME_TYPES[0x01])
        .connect('tcp://127.0.0.1:7000');


    await rSocketFuture.then((value) {
      var requester = value as RSocketRequester;
      var handler = requester.connection.closeHandler;
      requester.connection.closeHandler = (){
        handler?.call();
        closeHandler?.call();
      };
      rSocket = value;
    });
    return Future.value(this);
  }

  /// close connect
  void close() {
    rSocket.close();
  }

  /// allocate heap memory
  Future<int> memoryHeapApply(int byteSize) async {
    String route = "memory.heap.apply";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);

    var metadata = compositeMetadata.toUint8Array();
    var cborData = cbor.encode(CborSmallInt(byteSize));
    var data = Uint8List.fromList(cborData);
    Payload payload = Payload.from(metadata, data);

    var responsePayload = await rSocket.requestResponse!(payload);
    var responseCborData = responsePayload.data;
    var value = cbor.decode(responseCborData!);

    var responseData = int.parse(value.toObject().toString());
    return Future.value(responseData);
  }

  /// free
  Future memoryHeapFree() async {
    String route = "memory.heap.free";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    var metadata = compositeMetadata.toUint8Array();
    Payload payload = Payload.from(metadata, null);

    await rSocket.requestResponse!(payload);
    return Future.value();
  }

  /// clear
  Future memoryHeapClear() async {
    String route = "memory.heap.clear";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    var metadata = compositeMetadata.toUint8Array();
    Payload payload = Payload.from(metadata, null);

    await rSocket.requestResponse!(payload);
    return Future.value();
  }

  /// gc
  Future memoryVMGc() async {
    String route = "memory.vm.gc";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    var metadata = compositeMetadata.toUint8Array();
    Payload payload = Payload.from(metadata, null);

    await rSocket.requestResponse!(payload);
    return Future.value();
  }

  /// Nio allocate heap memory
  Future<int> memoryHeapByteBufferApply(int byteSize) async {
    String route = "memory.heapByteBuffer.apply";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);

    var metadata = compositeMetadata.toUint8Array();
    var cborData = cbor.encode(CborSmallInt(byteSize));
    var data = Uint8List.fromList(cborData);
    Payload payload = Payload.from(metadata, data);

    var responsePayload = await rSocket.requestResponse!(payload);
    var responseCborData = responsePayload.data;
    var value = cbor.decode(responseCborData!);

    var responseData = int.parse(value.toObject().toString());
    return Future.value(responseData);
  }

  ///  free
  Future memoryHeapByteBufferFree() async {
    String route = "memory.heapByteBuffer.free";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    var metadata = compositeMetadata.toUint8Array();
    Payload payload = Payload.from(metadata, null);

    await rSocket.requestResponse!(payload);
    return Future.value();
  }

  ///  clear
  Future memoryHeapByteBufferClear() async {
    String route = "memory.heapByteBuffer.clear";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    var metadata = compositeMetadata.toUint8Array();
    Payload payload = Payload.from(metadata, null);

    await rSocket.requestResponse!(payload);
    return Future.value();
  }

  /// Nio allocate direct memory
  Future<int> memoryDirectApply(int byteSize) async {
    String route = "memory.direct.apply";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);

    var metadata = compositeMetadata.toUint8Array();
    var cborData = cbor.encode(CborSmallInt(byteSize));
    var data = Uint8List.fromList(cborData);
    Payload payload = Payload.from(metadata, data);

    var responsePayload = await rSocket.requestResponse!(payload);
    var responseCborData = responsePayload.data;
    var value = cbor.decode(responseCborData!);

    var responseData = int.parse(value.toObject().toString());
    return Future.value(responseData);
  }

  ///  free
  Future memoryDirectFree() async {
    String route = "memory.direct.free";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    var metadata = compositeMetadata.toUint8Array();
    Payload payload = Payload.from(metadata, null);

    await rSocket.requestResponse!(payload);
    return Future.value();
  }

  ///  clear
  Future memoryDirectClear() async {
    String route = "memory.direct.clear";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);
    var metadata = compositeMetadata.toUint8Array();
    Payload payload = Payload.from(metadata, null);

    await rSocket.requestResponse!(payload);
    return Future.value();
  }

  ///  allocate metaspace memory
  Future memoryMetaspaceApply(int num) async {
    String route = "memory.metaspace.apply";

    var routingMetadata = RoutingMetadata(route, List.empty());
    var compositeMetadata = CompositeMetadata(RSocketByteBuffer());
    compositeMetadata.addMetadata(routingMetadata);

    var metadata = compositeMetadata.toUint8Array();
    var cborData = cbor.encode(CborSmallInt(num));
    var data = Uint8List.fromList(cborData);
    Payload payload = Payload.from(metadata, data);

    var responsePayload = await rSocket.requestResponse!(payload);
    var responseCborData = responsePayload.data;
    var value = cbor.decode(responseCborData!);

    var responseData = int.parse(value.toObject().toString());
    return Future.value(responseData);
  }
}