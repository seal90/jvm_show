


import 'dart:async';
import 'dart:io';

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

  Timer? _metaspaceHoldTimer;

  int _metaspaceHoldNum = 0;

  final String _defaultJVisualVMStartArgument = "/usr/bin/jvisualvm ";

  final TextEditingController _jVisualVMTextEditingController = TextEditingController();

  final String _defaultJavaStartArgument = "/Library/Java/JavaVirtualMachines/jdk1.8.0_291.jdk/Contents/Home/bin/java -jar -Xmx512m -XX:MaxDirectMemorySize=256m -XX:MaxMetaspaceSize=200m /Applications/jvm_show_view.app/Contents/Resources/jvm_show_backend/jvm-show-backend-0.0.1.jar";

  final TextEditingController _javaTextEditingController = TextEditingController();

  String _javaProcessOut = "";
  int _javaProcessPid = 0;
  bool _needsScroll = false;

  final ScrollController _javaProcessOutController = ScrollController();

  void closeHandler() {
    if(_JVMClient != null) {
      _JVMClient?.close();
      _JVMClient = null;
      _connectStatusChange("not connected");
    }
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance!.addPostFrameCallback((_){
      if(_needsScroll) {
        _javaProcessOutController.animateTo(
          _javaProcessOutController.position.maxScrollExtent + 100,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 500),
        );
        _needsScroll = false;
      }
    });

    return SingleChildScrollView(
      child: _innerContent(),
    );
  }

  Widget _innerContent() {
    return Column(
      children: [
        _jVisualVMWidget(),
        _javaProcessWidget(),
        _connectWidget(),
        _operationWidget(),
      ],

    );
  }

  Widget _jVisualVMWidget() {

    String startArgument = _jVisualVMTextEditingController.value.text;
    if("" == startArgument) {
      startArgument = _defaultJVisualVMStartArgument;
    }

    List<String> startArgumentList = startArgument.split(" ");
    startArgumentList.removeWhere((element) => ""==element);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Default start jvisualvm command line : "),
            SelectableText(_defaultJVisualVMStartArgument,),
          ],
        ),
        TextField(
          controller: _jVisualVMTextEditingController,
          decoration: InputDecoration(
              hintText: _defaultJVisualVMStartArgument
          ),
        ),
        MaterialButton(
          child: const Text('start jvisualvm'),
          color: Colors.lightBlue,
          onPressed: () {
            Process.start(startArgumentList.first, startArgumentList.sublist(1)).then((value) {

            });
          },
        ),
      ],
    );
  }

  Widget _javaProcessWidget() {

    String javaStartArgument = _javaTextEditingController.value.text;
    if("" == javaStartArgument) {
      javaStartArgument = _defaultJavaStartArgument;
    }

    List<String> javaStartArgumentList = javaStartArgument.split(" ");
    javaStartArgumentList.removeWhere((element) => ""==element);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [Text("Default start java backend command line : ")],
        ),

        SelectableText(_defaultJavaStartArgument,),
        TextField(
          controller: _javaTextEditingController,
          decoration: InputDecoration(
              hintText: _defaultJavaStartArgument
          ),
        ),
        SelectableText(_javaProcessPid.toString()),
        Row(
          children: [
            MaterialButton(
              child: const Text('start java process'),
              color: Colors.lightBlue,
              onPressed: () {
                Process.start(javaStartArgumentList.first, javaStartArgumentList.sublist(1)).then((value) {
                  _javaProcessOut = "";
                  setState(() {
                    _javaProcessPid = value.pid;
                  });

                  value.stdout.listen((event) {
                    setState(() {
                      _javaProcessOut += String.fromCharCodes(event);

                    });
                    _needsScroll = true;

                  });

                  value.stderr.listen((event) {
                    setState(() {
                      _javaProcessOut += String.fromCharCodes(event);
                    });
                    _needsScroll = true;
                  });

                  value.exitCode.then((value) {
                    setState(() {
                      _javaProcessPid = 0;
                    });
                  });
                });
              },
            ),

            MaterialButton(
              child: const Text('stop java process'),
              color: Colors.lightBlue,
              onPressed: (){
                if(0 == _javaProcessPid) {
                  return;
                }
                Process.start("kill", ['-9', _javaProcessPid.toString()]).then((value) {

                });
              },
            ),

          ],
        ),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            controller: _javaProcessOutController,
            scrollDirection: Axis.vertical,
            child: SelectableText(_javaProcessOut, scrollPhysics: BouncingScrollPhysics(),),
          ),
        ),
      ],
    );
  }

  Widget _connectWidget() {
    return Column(
      children: [
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
      ],
    );


  }

  Widget _operationWidget() {
    return Column(
      children: [
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
            ]
        ),
        Row(
          children:[
            Text("class generate hold number: " + _metaspaceHoldNum.toString()),
            MaterialButton(
              child: const Text('Increase hold'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null == _metaspaceHoldTimer) {
                  var duration = const Duration(seconds: 1);
                  _metaspaceHoldTimer = Timer.periodic(duration, (t){
                    _JVMClient?.memoryMetaspaceHoldApply(2048).then((value) => _metaspaceHoldChange(value));
                  });
                }
              },
            ),
            MaterialButton(
              child: const Text('Cancel increase hold'),
              color: Colors.lightBlue,
              onPressed: () {
                if(null != _metaspaceHoldTimer) {
                  _metaspaceHoldTimer?.cancel();
                  _metaspaceHoldTimer = null;
                  _metaspaceHoldChange(0);
                }
              },
            ),
            MaterialButton(
              child: const Text('Clear increase hold'),
              color: Colors.lightBlue,
              onPressed: () {
                _JVMClient?.memoryMetaspaceHoldClear();
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

  void _metaspaceHoldChange(int num) {
    setState(() {
      _metaspaceHoldNum = num;
    });
  }
}