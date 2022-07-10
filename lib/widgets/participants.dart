import 'package:amse/api.dart';
import 'package:amse/data_sources/participant_datasource.dart';
import 'package:amse/providers/competitions.dart';
import 'package:amse/providers/participants.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:amse_api_client/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ParticipantsWidget extends ConsumerStatefulWidget {
  const ParticipantsWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ParticipantsWidget> createState() => ParticipantsWidgetState();
}

class ParticipantsWidgetState extends ConsumerState<ParticipantsWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PaginatedDataTable(
        source: ref.read(participantDataProvider),
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.number)),
          DataColumn(label: Text(AppLocalizations.of(context)!.name)),
          DataColumn(label: Text(AppLocalizations.of(context)!.birthday)),
          DataColumn(label: Text(AppLocalizations.of(context)!.competitions)),
          DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
        ],
        actions: [
          IconButton(
              onPressed: () {
                ref.read(participantDataProvider).refresh();
              },
              icon: const Icon(Icons.refresh))
        ],
        header: Text(AppLocalizations.of(context)!.participants),
        //TODO: specify other options
      ),
    );
  }
}

class ParticipantCreateForm extends ConsumerStatefulWidget {
  const ParticipantCreateForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ParticipantCreateFormState();
}

class _ParticipantCreateFormState extends ConsumerState<ParticipantCreateForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  DateTime? _birth;
  List<String> _comps = [];

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var comps = ref.watch(competitionProvider);
    String ageString = _birth != null
        ? "${AppLocalizations.of(context)!.age}: ${_calculateAge(_birth!)}"
        : "";
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.create_participant),
              const Padding(padding: EdgeInsets.all(30)),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.generic_val;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.name),
                ),
              ),
              const Padding(padding: EdgeInsets.all(15)),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.birthday),
                  TextButton(
                      onPressed: () async {
                        DateTime? dt = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2004, 1, 1),
                          lastDate: DateTime.now(),
                          initialDatePickerMode: DatePickerMode.year,
                          initialEntryMode: DatePickerEntryMode.input,
                        );

                        if (dt != null) {
                          var age = _calculateAge(dt);
                          for (var comp in comps) {
                            if (comp.config.assign.criteria?.ge == 0 &&
                                comp.config.assign.criteria?.le == 100) {
                              continue;
                            }
                            if ((comp.config.assign.criteria?.ge ?? 99) <=
                                    age &&
                                age <=
                                    (comp.config.assign.criteria?.le ?? 99)) {
                              setState(() {
                                _comps.add(comp.id!);
                              });
                            }
                          }

                          setState(() {
                            _birth = dt;
                          });
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.select)),
                  Text(_birth?.toLocal().toString() ?? ""),
                  Text(ageString),
                ],
              ),
              const Padding(padding: EdgeInsets.all(15)),
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.number),
                ),
              ),
              const Padding(padding: EdgeInsets.all(15)),
              Text(AppLocalizations.of(context)!.competitions),
              ListView.builder(
                shrinkWrap: true,
                itemCount: comps.length,
                itemBuilder: (context, index) {
                  Comp comp = comps[index];
                  void Function(bool?)? onChanged = (value) {
                    if (value ?? false) {
                      setState(() {
                        _comps.add(comp.id!);
                      });
                    } else {
                      setState(() {
                        _comps.removeWhere((element) => element == comp.id);
                      });
                    }
                  };

                  if (_birth != null) {
                    if ((comp.config.assign.criteria?.le ?? 99) <
                        _calculateAge(_birth!)) {
                      onChanged = null;
                    }
                  }

                  return CheckboxListTile(
                    onChanged: onChanged,
                    value: _comps.contains(comp.id),
                    title: Text("${comp.short} - ${comp.name}"),
                    subtitle: Text("${comp.description}"),
                  );
                },
              ),
              const Padding(padding: EdgeInsets.all(30)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async {
                        final success = await _saveParticipant();
                        if (mounted) {
                          if (success) {
                            GoRouter.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .generic_error)),
                            );
                          }
                        }
                      },
                      child:
                          Text(AppLocalizations.of(context)!.ok.toUpperCase())),
                  const Padding(padding: EdgeInsets.all(15)),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await _saveParticipant();
                      if (mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.participant_saved,
                            ),
                          ));
                          setState(() {
                            _nameController.text = "";
                            _numberController.text = "";
                            _comps = [];
                            _birth = null;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .generic_error)),
                          );
                        }
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save.toUpperCase(),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(30)),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _saveParticipant() async {
    AmseApi api = ref.read(apiProvider);
    if ((!_formKey.currentState!.validate()) || _birth == null) {
      return false;
    }
    await api.participants.create(MinParticipant(
        name: _nameController.text,
        birth: _birth,
        number: _numberController.text,
        comps: _comps));
    ref.read(participantDataProvider).refresh();
    ref.read(participantProvider.notifier).refresh();
    return true;
  }

  static int _calculateAge(DateTime birth) {
    var now = DateTime.now();

    var tbirth = DateTime(now.year, birth.month, birth.day);
    var tnow = DateTime(now.year, now.month, now.day);

    bool hadBirthday = tnow.compareTo(tbirth) != -1;

    if (hadBirthday) {
      return now.year - birth.year;
    } else {
      return now.year - birth.year - 1;
    }
  }
}
