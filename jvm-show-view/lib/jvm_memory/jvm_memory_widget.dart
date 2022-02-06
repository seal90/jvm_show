


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvm_show_view/client/jvm_client.dart';

class JVMMemoryWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _JVMMemoryState();
  }

}

class _JVMMemoryState extends State<JVMMemoryWidget> {

  JVMClient? _JVMClient;

  String _connectStatusStr = 'not connected';

  Timer? _heapApplyTimer;

  int _heapApplyNum = 0;

  Timer? _heapByteBufferTimer;

  int _heapByteBufferNum = 0;

  Timer? _directTimer;

  int _directNum = 0;

  Timer? _metaspaceTimer;

  int _metaspaceNum = 0;

  void closeHandler() {
    if(_JVMClient != null) {
      _JVMClient?.close();
      _JVMClient = null;
      _connectStatusChange("not connected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SelectableText("java start param:  -Xmx512m -XX:MaxDirectMemorySize=256m -XX:MaxMetaspaceSize=200m"),
        Text(_connectStatusStr),

        Row(
          children: [
            MaterialButton(
              child: const Text('Connect'),
              color: Colors.lightBlue,
              onPressed: () {
                if(_JVMClient == null) {
                  _connectStatusChange("connecting。。。");
                  var jVMClient = JVMClient();
                  jVMClient.connect(closeHandler: closeHandler).then((value) {_JVMClient = value; _connectStatusChange("Connect Success");})
                      .onError((error, stackTrace) { _connectStatusChange('Connect Failed：'+error.toString());});
                }
              },
            ),
            MaterialButton(
              child: const Text('Close'),
              color: Colors.lightBlue,
              onPressed: () {
                if(_JVMClient != null) {
                  _JVMClient?.close();
                  _JVMClient = null;
                  _connectStatusChange("not connected");
                }
              },
            ),
          ],
        ),
        Row(
          children: [
            MaterialButton(
              child: const Text('GC'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryVMGc();
              },
            ),
          ],
        ),
        Row(
          children: const [
            Text("allocate heap memory"),
          ],
        ),
        Row(
          children: [
            Text("byte[] numbers: "+_heapApplyNum.toString()),
            MaterialButton(
              child: const Text('Increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null == _heapApplyTimer) {
                  var duration = const Duration(seconds: 1);
                  _heapApplyTimer = Timer.periodic(duration, (t){
                    _JVMClient?.memoryHeapApply(204800).then((value) => _heapApplyNumChange(value));
                  });
                }
              },
            ),
            MaterialButton(
              child: const Text('Cancel increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null != _heapApplyTimer) {
                  _heapApplyTimer?.cancel();
                  _heapApplyTimer = null;
                  _heapApplyNumChange(0);
                }
              },
            ),

            MaterialButton(
              child: const Text('Free'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryHeapFree();
              },
            ),
            MaterialButton(
              child: const Text('Clear'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryHeapClear();
              },
            ),
          ],
        ),
        Row(
          children: const [
            Text("Nio allocate heap memory "),
          ],
        ),
        Row(
          children: [
            Text("byte[] numbers: "+_heapByteBufferNum.toString()),
            MaterialButton(
              child: const Text('Increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null == _heapByteBufferTimer) {
                  var duration = const Duration(seconds: 1);
                  _heapByteBufferTimer = Timer.periodic(duration, (t){
                    _JVMClient?.memoryHeapByteBufferApply(20480000).then((value) => _heapByteBufferChange(value));
                  });
                }
              },
            ),
            MaterialButton(
              child: const Text('Cancel increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null != _heapByteBufferTimer) {
                  _heapByteBufferTimer?.cancel();
                  _heapByteBufferTimer = null;
                  _heapByteBufferChange(0);
                }
              },
            ),

            MaterialButton(
              child: const Text('Free'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryHeapByteBufferFree();
              },
            ),
            MaterialButton(
              child: const Text('Clear'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryHeapByteBufferClear();
              },
            ),
          ],
        ),
        Row(
          children: const [
            Text("Nio allocate direct memory "),
          ],
        ),
        Row(
          children: [
            Text("byte[] number: "+_directNum.toString()),
            MaterialButton(
              child: const Text('Increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null == _directTimer) {
                  var duration = const Duration(seconds: 1);
                  _directTimer = Timer.periodic(duration, (t){
                    _JVMClient?.memoryDirectApply(204800).then((value) => _directChange(value));
                  });
                }
              },
            ),
            MaterialButton(
              child: const Text('Cancel increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null != _directTimer) {
                  _directTimer?.cancel();
                  _directTimer = null;
                  _directChange(0);
                }
              },
            ),

            MaterialButton(
              child: const Text('Free'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryDirectFree();
              },
            ),
            MaterialButton(
              child: const Text('Clear'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryDirectClear();
              },
            ),
          ],
        ),
        Row(
          children: const [
            Text("allocate metaspace memory "),
          ],
        ),
        Row(
          children: [
            Text("class generate number: " + _metaspaceNum.toString()),
            MaterialButton(
              child: const Text('Increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null == _metaspaceTimer) {
                  var duration = const Duration(seconds: 1);
                  _metaspaceTimer = Timer.periodic(duration, (t){
                    _JVMClient?.memoryMetaspaceApply(2048).then((value) => _metaspaceChange(value));
                  });
                }
              },
            ),
            MaterialButton(
              child: const Text('Cancel increase'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null != _metaspaceTimer) {
                  _metaspaceTimer?.cancel();
                  _metaspaceTimer = null;
                  _metaspaceChange(0);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  void _connectStatusChange(String connectStatusStr) {
    setState(() {
      _connectStatusStr = connectStatusStr;
    });
  }

  void _heapApplyNumChange(int num) {
    setState(() {
      _heapApplyNum = num;
    });
  }

  void _heapByteBufferChange(int num) {
    setState(() {
      _heapByteBufferNum = num;
    });
  }

  void _directChange(int num) {
    setState(() {
      _directNum = num;
    });
  }

  void _metaspaceChange(int num) {
    setState(() {
      _metaspaceNum = num;
    });
  }
}