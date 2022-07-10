import 'dart:async';

import 'package:amse/api.dart';
import 'package:amse/providers/competitions.dart';
import 'package:amse/providers/participants.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:amse_api_client/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultsCompChooser extends ConsumerWidget {
  const ResultsCompChooser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comps = ref.watch(competitionProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Choose a competition"),
          ListView.separated(
            itemCount: comps.length,
            itemBuilder: (context, index) {
              final comp = comps[index];
              return ListTile(
                title: Text("${comp.short} - ${comp.name ?? ""}"),
                subtitle:
                    comp.description != null ? Text(comp.description!) : null,
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  GoRouter.of(context)
                      .goNamed("result", params: {"cid": comp.id!});
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}

class GlobalResultAdd extends ConsumerStatefulWidget {
  final bool quali;
  const GlobalResultAdd({this.quali = false, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GlobalResultAddState();
}

class _GlobalResultAddState extends ConsumerState<GlobalResultAdd> {
  final Stopwatch _stopwatch = Stopwatch();
  final _numberController = TextEditingController();
  int _offset = 0;

  List<Comp> _availComps = [];
  final List<Comp> _comps = [];

  Timer? _timer;

  String _stopwatchDisplay = "";

  MinParticipant? _participant;

  late bool _quali;

  @override
  void initState() {
    super.initState();
    _stopwatchDisplay = _timeAsString();
    _quali = widget.quali;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 3), (timer) {
        setState(() {
          _stopwatchDisplay = _timeAsString();
        });
      });
    } else {
      _stopwatch.stop();
      _timer?.cancel();
      setState(() {
        _stopwatchDisplay = _timeAsString();
      });
    }
  }

  String _timeAsString() {
    var m = _stopwatch.elapsedMilliseconds + _offset;
    var millis = (m % 1000).toString().padLeft(3, "0");
    var secs = m ~/ 1000;
    var seconds = (secs % 60).toString().padLeft(2, "0");
    var minutes = (secs ~/ 60).toString().padLeft(2, "0");
    return "$minutes:$seconds.$millis";
  }

  @override
  Widget build(BuildContext context) {
    var participants = ref.watch(participantProvider);
    var pnumbers = participants.map((e) => e.number);
    var competitions = ref.watch(competitionProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          QualiSelection(
            onChanged: (q) {
              setState(() {
                _quali = q;
              });
            },
            quali: _quali,
          ),
          TextFormField(
            decoration: InputDecoration(
              label: Text(
                  "${AppLocalizations.of(context)!.participant} ${AppLocalizations.of(context)!.number}"),
            ),
            controller: _numberController,
            onFieldSubmitted: (value) {
              if (value.isEmpty || !pnumbers.contains(value)) {
                return;
              }

              var comps = participants
                  .firstWhere((element) => element.number == value)
                  .comps;
              setState(() {
                _availComps = competitions
                    .where((element) => comps?.contains(element.id) ?? false)
                    .toList();
                _participant = participants
                    .firstWhere((element) => element.number == value);
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Container(
            foregroundDecoration: BoxDecoration(
              color: _availComps.isNotEmpty ? null : Colors.grey,
              backgroundBlendMode:
                  _availComps.isNotEmpty ? null : BlendMode.saturation,
            ),
            child: ListView.separated(
              itemBuilder: (context, index) {
                Comp comp = _availComps[index];
                return CheckboxListTile(
                  value: _comps.contains(comp),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    if (value) {
                      setState(() {
                        _comps.add(comp);
                      });
                    } else {
                      setState(() {
                        _comps.remove(comp);
                      });
                    }
                  },
                  title: Text(comp.short),
                );
              },
              separatorBuilder: (context, i) => const Divider(),
              itemCount: _availComps.length,
              shrinkWrap: true,
            ),
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Container(
            foregroundDecoration: BoxDecoration(
              color: _comps.isNotEmpty ? null : Colors.grey,
              backgroundBlendMode:
                  _comps.isNotEmpty ? null : BlendMode.saturation,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _handleTap,
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 5,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Center(
                        child: Text(
                          _stopwatchDisplay,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_comps.any((c) {
                  if (_quali) {
                    return c.qConfig.scoring.enablePenalties == true;
                  } else {
                    return c.config.scoring.enablePenalties == true;
                  }
                }))
                  const Padding(padding: EdgeInsets.all(10)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _offset = _offset + 2000;
                      _stopwatchDisplay = _timeAsString();
                    });
                  },
                  child: const Text("Add Penalty"),
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Container(
            foregroundDecoration: BoxDecoration(
              color: _stopwatch.elapsedMilliseconds != 0 ? null : Colors.grey,
              backgroundBlendMode: _stopwatch.elapsedMilliseconds != 0
                  ? null
                  : BlendMode.saturation,
            ),
            child: ElevatedButton(
              onPressed: () async {
                _stopwatch.stop();

                //send to server
                AmseApi api = ref.read(apiProvider);
                final p = await api.participants.get(_participant!.id!);

                final pcomps = p.competitions!
                    .where((element) => _comps
                        .map((e) => e.id)
                        .contains(element.competitionId!))
                    .toList();

                for (var pcomp in pcomps) {
                  await api.results.add(
                      q: _quali,
                      value: _stopwatch.elapsedMilliseconds + _offset,
                      id: pcomp.id!);
                }

                //reset
                setState(() {
                  _availComps = [];
                  _comps.clear();
                  _numberController.text = "";
                  _offset = 0;
                  _stopwatch.reset();
                  _stopwatchDisplay = _timeAsString();
                  _timer?.cancel();
                  _timer = null;
                  _participant = null;
                });
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultAdd extends ConsumerStatefulWidget {
  final bool quali;
  final Comp comp;
  const ResultAdd({this.quali = false, Key? key, required this.comp})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResultAddState();
}

class _ResultAddState extends ConsumerState<ResultAdd> {
  final Stopwatch _stopwatch = Stopwatch();

  Timer? _timer;

  String _stopwatchDisplay = "";

  late bool _quali;

  final GlobalKey<AddResultListState> _resultKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _stopwatchDisplay = _timeAsString();
    _quali = widget.quali;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 3), (timer) {
        setState(() {
          _stopwatchDisplay = _timeAsString();
        });
      });
    } else {
      _resultKey.currentState!.addResult(_stopwatch.elapsedMilliseconds);
    }
  }

  String _timeAsString() {
    return _intAsString(_stopwatch.elapsedMilliseconds);
  }

  String _intAsString(int millis) {
    var mil = (millis % 1000).toString().padLeft(3, "0");
    var secs = millis ~/ 1000;
    var seconds = (secs % 60).toString().padLeft(2, "0");
    var minutes = (secs ~/ 60).toString().padLeft(2, "0");
    return "$minutes:$seconds.$mil";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          QualiSelection(
            onChanged: (q) {
              setState(() {
                _quali = q;
              });
            },
            quali: _quali,
          ),
          const Padding(padding: EdgeInsets.all(20)),
          GestureDetector(
            onTap: _handleTap,
            child: SizedBox(
              width: 300,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 5, color: Theme.of(context).colorScheme.primary),
                ),
                child: Center(
                  child: Text(
                    _stopwatchDisplay,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          TextButton(
              onPressed: () {
                _stopwatch.stop();
                _timer?.cancel();
                setState(() {
                  _stopwatchDisplay = _timeAsString();
                });
              },
              child: const Text("stop")),
          const Padding(padding: EdgeInsets.all(20)),
          AddResultList(
            comp: widget.comp,
            quali: _quali,
            key: _resultKey,
          ),
          Container(
            foregroundDecoration: BoxDecoration(
              color: _stopwatch.elapsedMilliseconds != 0 ? null : Colors.grey,
              backgroundBlendMode: _stopwatch.elapsedMilliseconds != 0
                  ? null
                  : BlendMode.saturation,
            ),
            child: ElevatedButton(
              onPressed: () async {
                _stopwatch.stop();

                //send to server
                if (await _resultKey.currentState!.save()) {
                  GoRouter.of(context).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ),
        ],
      ),
    );
  }
}

class AddResultList extends ConsumerStatefulWidget {
  final bool quali;
  final Comp comp;
  const AddResultList({Key? key, required this.comp, required this.quali})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => AddResultListState();
}

class AddResultListState extends ConsumerState<AddResultList> {
  List<TextEditingController> _controllers = [];
  List<int> _times = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void addResult(int time) {
    if (!mounted) {
      throw Exception("Bad State: AddResultList isnt mounted");
    }
    setState(() {
      _times.add(time);
      _controllers.add(TextEditingController());
    });
  }

  Future<bool> save() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    AmseApi api = ref.read(apiProvider);
    var parts = ref.read(participantProvider);
    for (var i = 0; i < _times.length; i++) {
      var pid = parts
          .firstWhere((element) => element.number == _controllers[i].text)
          .id!;
      var cpid = (await api.participants.get(pid))
          .competitions!
          .firstWhere((element) => element.competitionId == widget.comp.id)
          .id!;
      await api.results.add(q: widget.quali, value: _times[i], id: cpid);
    }

    return true;
  }

  String _intAsString(int millis) {
    var mil = (millis % 1000).toString().padLeft(3, "0");
    var secs = millis ~/ 1000;
    var seconds = (secs % 60).toString().padLeft(2, "0");
    var minutes = (secs ~/ 60).toString().padLeft(2, "0");
    return "$minutes:$seconds.$mil";
  }

  @override
  Widget build(BuildContext context) {
    var participants = ref.watch(participantProvider);
    var pnumbers = participants.map((e) => e.number);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Form(
        key: _formKey,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _times.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              title: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(
                        label: Text(
                            "${AppLocalizations.of(context)!.participant} ${AppLocalizations.of(context)!.number}"),
                      ),
                      controller: _controllers[index],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !pnumbers.contains(value)) {
                          return "Not a valid value";
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Text(_intAsString(_times[index])),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class QualiSelection extends StatelessWidget {
  final bool quali;
  final void Function(bool)? onChanged;
  const QualiSelection({Key? key, required this.quali, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void Function(int)? onPressed;
    if (onChanged != null) {
      onPressed = (i) {
        onChanged!(!quali);
      };
    }
    return ToggleButtons(
        isSelected: [!quali, quali],
        onPressed: onPressed,
        children: const [Text("Normal"), Text("Quali")]);
  }
}

class ResultsList extends ConsumerStatefulWidget {
  final Comp comp;
  final bool? quali;
  const ResultsList({Key? key, required this.comp, this.quali})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResultsListState();
}

class _ResultsListState extends ConsumerState<ResultsList> {
  bool _quali = false;
  late Future<List<Participant>> _results;

  @override
  void initState() {
    super.initState();
    if (widget.quali != null) {
      _quali = widget.quali!;
    }
    _results = _getResults();
  }

  Future<List<Participant>> _getResults() async {
    AmseApi api = ref.read(apiProvider);
    final mparts = await api.participants.getAllWithComp(widget.comp.id!);

    List<Participant> r = [];

    for (var mpart in mparts) {
      Participant p = await api.participants.get(mpart.id!);
      r.add(p);
    }

    if (!_quali) {
      r.sort((a, b) {
        return (a.competitions
                    ?.firstWhere(
                        (element) => element.competitionId == widget.comp.id)
                    .result ??
                double.nan)
            .compareTo(b.competitions
                    ?.firstWhere(
                        (element) => element.competitionId == widget.comp.id)
                    .result ??
                double.infinity);
      });
    } else {
      r.sort((a, b) {
        return (a.competitions
                    ?.firstWhere(
                        (element) => element.competitionId == widget.comp.id)
                    .qResult ??
                double.nan)
            .compareTo(b.competitions
                    ?.firstWhere(
                        (element) => element.competitionId == widget.comp.id)
                    .qResult ??
                double.infinity);
      });
    }

    return r;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(15)),
          QualiSelection(
            quali: _quali,
            onChanged: (value) {
              setState(() {
                _quali = value;
                _results = _getResults();
              });
            },
          ),
          const Padding(padding: EdgeInsets.all(15)),
          IconButton(
              onPressed: () {
                setState(() {
                  _results = _getResults();
                });
              },
              icon: const Icon(Icons.refresh)),
          FutureBuilder(
            future: _results,
            builder: (context, AsyncSnapshot<List<Participant>> snapshot) {
              if (snapshot.hasData) {
                final res = snapshot.data!;
                return Column(
                  children: [
                    Text("count: ${res.length}"),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: res.length,
                      separatorBuilder: (c, i) => const Divider(),
                      itemBuilder: (context, index) {
                        final r = res[index];
                        return ListTile(
                          title: Text(!_quali
                              ? "${index + 1}. - ${r.number} - ${r.name} - ${r.competitions?.firstWhere((element) => element.competitionId == widget.comp.id).result ?? 'no result'}"
                              : "${index + 1}. - ${r.number} - ${r.name} - ${r.competitions?.firstWhere((element) => element.competitionId == widget.comp.id).qResult ?? 'no result'}"),
                        );
                      },
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text("error");
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}
