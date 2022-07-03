import 'package:amse/api.dart';
import 'package:amse/providers/competitions.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:amse_api_client/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionListView extends ConsumerWidget {
  const CompetitionListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comps = ref.watch(competitionProvider);

    return ListView.separated(
      itemBuilder: (context, index) {
        final c = comps[index];
        String title = c.short;
        if (c.name != null) {
          title = "${c.short} - ${c.name!}";
        }
        Widget? subtitle;
        if (c.description != null) {
          subtitle = Text(c.description!);
        }
        return ListTile(
            title: Text(title),
            subtitle: subtitle,
            onTap: () {
              //TODO: temporary fix for https://github.com/flutter/flutter/issues/106163
              GoRouter.of(context).goNamed("competition_detail",
                  params: {"cid": c.id.toString()});
            },
            trailing: IconButton(
                onPressed: () {
                  ref.read(competitionProvider.notifier).delete(c);
                },
                icon: const Icon(Icons.delete)));
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: comps.length,
    );
  }
}

class CompetitionDetailView extends ConsumerWidget {
  final String _id;

  const CompetitionDetailView(String id, {Key? key})
      : _id = id,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comp = ref.read(competitionProvider).firstWhere((c) => c.id == _id);
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.general,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        Table(
          children: <TableRow>[
            TableRow(children: [
              Text(AppLocalizations.of(context)!.id),
              SelectableText(comp.id.toString())
            ]),
            TableRow(children: [
              Text(AppLocalizations.of(context)!.short),
              SelectableText(comp.short)
            ]),
            TableRow(children: [
              Text(AppLocalizations.of(context)!.name),
              SelectableText(comp.name ?? "-")
            ]),
            TableRow(children: [
              Text(AppLocalizations.of(context)!.description),
              SelectableText(comp.description ?? "-")
            ]),
            if (comp.config.assign.autoAssign ?? false)
              TableRow(children: [
                Text(AppLocalizations.of(context)!.assign_within),
                SelectableText(
                    "${comp.config.assign.criteria?.ge} - ${comp.config.assign.criteria?.le}")
              ]),
            TableRow(children: [
              Text(AppLocalizations.of(context)!.created_at),
              SelectableText(comp.createdAt.toString())
            ]),
            TableRow(children: [
              Text(AppLocalizations.of(context)!.updated_at),
              SelectableText(comp.updatedAt.toString())
            ]),
          ],
        ),
        const Padding(padding: EdgeInsets.all(30)),
        Text(
          AppLocalizations.of(context)!.config,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        CompConfigDisplay(comp.config),
        const Padding(padding: EdgeInsets.all(15)),
        Text(
          AppLocalizations.of(context)!.qualifying_config,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        CompConfigDisplay(comp.qConfig),
      ],
    );
  }
}

class CompConfigDisplay extends StatelessWidget {
  final CompConfig config;
  const CompConfigDisplay(this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      children: <TableRow>[
        TableRow(children: [
          Text(AppLocalizations.of(context)!.type),
          SelectableText(config.scoring.subject)
        ]),
        TableRow(children: [
          Text(AppLocalizations.of(context)!.unit),
          SelectableText(config.scoring.unit)
        ]),
        TableRow(children: [
          Text("${AppLocalizations.of(context)!.penalties}?"),
          SelectableText(config.scoring.enablePenalties.toString())
        ]),
        TableRow(children: [
          Text(AppLocalizations.of(context)!.point_type),
          SelectableText(config.scoring.pointType)
        ]),
        TableRow(children: [
          Text(AppLocalizations.of(context)!.raw_dp),
          SelectableText(config.scoring.rawdp.toString())
        ]),
        TableRow(children: [
          Text(AppLocalizations.of(context)!.point_dp),
          SelectableText(config.scoring.pointdp.toString())
        ]),
        TableRow(children: [
          Text(AppLocalizations.of(context)!.conversion),
          SelectableText(config.conversionFunction.toString())
        ])
      ],
    );
  }
}

class CompetitionCreateForm extends ConsumerStatefulWidget {
  const CompetitionCreateForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CompetitionCreateFormState();
}

class _CompetitionCreateFormState extends ConsumerState<CompetitionCreateForm> {
  int _stepperIndex = 0;
  bool _loading = false;

  final _genFormKey = GlobalKey<FormState>();
  final _confFormKey = GlobalKey<FormState>();
  final _qConfFormKey = GlobalKey<FormState>();

  final _shortController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  RangeValues _ages = const RangeValues(0, 100);

  final CompetitionConfig _config = CompetitionConfig();
  final CompetitionConfig _qConfig = CompetitionConfig();

  Future<void> create() async {
    setState(() {
      _loading = true;
    });
    AmseApi api = ref.read(apiProvider);
    CompAssign assign = CompAssign(
        autoAssign: true,
        criteria: CompAssignCriteria(
            mode: "age", ge: _ages.start.toInt(), le: _ages.end.toInt()));

    Comp comp = Comp(
      short: _shortController.text,
      config: CompConfig(
          conversionFunction: {"mode": "simple", "factor": 1, "offset": 0},
          scoring: CompScoring(
              unit: _config.unit!,
              subject: _config.subject!,
              pointType: _config.pointType!,
              enablePenalties: _config.penalties,
              pointdp: _config.pointDP,
              rawdp: _config.rawDP),
          assign: assign),
      qConfig: CompConfig(
          conversionFunction: {"mode": "simple", "factor": 1, "offset": 0},
          scoring: CompScoring(
              unit: _qConfig.unit!,
              subject: _qConfig.subject!,
              pointType: _qConfig.pointType!,
              enablePenalties: _qConfig.penalties,
              pointdp: _qConfig.pointDP,
              rawdp: _qConfig.rawDP),
          assign: assign),
      name: _nameController.text,
      description: _descriptionController.text,
    );
    try {
      await api.competitions.create(comp);
      if (mounted) {
        setState(() {
          _loading = false;
        });
        GoRouter.of(context).pop();
        ref.read(competitionProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.comp_create_error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _stepperIndex,
      controlsBuilder: (context, details) {
        String continueText = (details.stepIndex == 2)
            ? AppLocalizations.of(context)!.save.toUpperCase()
            : AppLocalizations.of(context)!.continueText.toUpperCase();
        return Row(
          children: [
            if (_loading) const CircularProgressIndicator(),
            TextButton(
                onPressed: details.onStepContinue, child: Text(continueText)),
            if (details.stepIndex != 0)
              TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(AppLocalizations.of(context)!.back.toUpperCase()))
          ],
        );
      },
      onStepContinue: () {
        bool valid;
        switch (_stepperIndex) {
          case 0:
            valid = _genFormKey.currentState!.validate();
            break;
          case 1:
            valid = _confFormKey.currentState!.validate();
            break;
          case 2:
            valid = _qConfFormKey.currentState!.validate();
            break;
          default:
            valid = false;
        }

        if (valid && _stepperIndex != 2) {
          setState(() {
            _stepperIndex += 1;
          });
        } else if (valid && _stepperIndex == 2) {
          create();
        }
      },
      onStepCancel: () {
        setState(() {
          _stepperIndex -= 1;
        });
      },
      steps: <Step>[
        Step(
          title: Text(AppLocalizations.of(context)!.general),
          content: Form(
            key: _genFormKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.short),
                  ),
                  maxLength: 4,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  controller: _shortController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length > 4) {
                      return AppLocalizations.of(context)!.generic_val;
                    }
                    return null;
                  },
                ),
                const Padding(padding: EdgeInsets.all(15)),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.name),
                  ),
                  controller: _nameController,
                ),
                const Padding(padding: EdgeInsets.all(15)),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.description),
                    border: const OutlineInputBorder(),
                  ),
                  controller: _descriptionController,
                  maxLines: 4,
                ),
                const Padding(padding: EdgeInsets.all(15)),
                RangeSlider(
                  values: _ages,
                  onChanged: (values) {
                    setState(() {
                      _ages = values;
                    });
                  },
                  labels: RangeLabels(_ages.start.toInt().toString(),
                      _ages.end.toInt().toString()),
                  divisions: 100,
                  max: 100,
                  min: 0,
                ),
              ],
            ),
          ),
        ),
        Step(
          title: Text(AppLocalizations.of(context)!.config),
          content: Form(
            key: _confFormKey,
            child: CompetitionConfigForm(config: _config),
          ),
        ),
        Step(
            title: Text(AppLocalizations.of(context)!.qualifying_config),
            content: Form(
                key: _qConfFormKey,
                child: CompetitionConfigForm(config: _qConfig)))
      ],
    );
  }
}

class CompetitionConfigForm extends StatefulWidget {
  final CompetitionConfig config;

  const CompetitionConfigForm({Key? key, required this.config})
      : super(key: key);

  @override
  State<CompetitionConfigForm> createState() => _CompetitionConfigFormState();
}

class _CompetitionConfigFormState extends State<CompetitionConfigForm> {
  List<DropdownMenuItem<String>> _dropdownMenuItemsFromStringList(
      List<String> list) {
    return list
        .map<DropdownMenuItem<String>>((s) => DropdownMenuItem(
              value: s,
              child: Text(s),
            ))
        .toList();
  }

  String? _dropdownValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.dropdown_val;
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.generic_val;
    }
    if (int.tryParse(value) == null) {
      return AppLocalizations.of(context)!.nan;
    }
    if (int.parse(value) > 10) {
      return AppLocalizations.of(context)!.too_big;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return Column(
      children: [
        DropdownButtonFormField<String>(
          items: _dropdownMenuItemsFromStringList(
              ["time", "rounds", "distance", "points", "other"]),
          onChanged: (value) {
            setState(() {
              config.subject = value ?? "";
            });
          },
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.comp_subject)),
          value: config.subject,
          validator: _dropdownValidator,
        ),
        const Padding(padding: EdgeInsets.all(15)),
        DropdownButtonFormField<String>(
          items: _dropdownMenuItemsFromStringList(
              ["ms", "sec", "min", "hrs", "m", "km", "unitless", "other"]),
          onChanged: (value) {
            setState(() {
              config.unit = value ?? "";
            });
          },
          decoration:
              InputDecoration(label: Text(AppLocalizations.of(context)!.unit)),
          value: config.unit,
          validator: _dropdownValidator,
        ),
        const Padding(padding: EdgeInsets.all(15)),
        DropdownButtonFormField<String>(
          items: _dropdownMenuItemsFromStringList(
              ["lower_is_better", "greater_is_better"]),
          onChanged: (value) {
            setState(() {
              config.pointType = value ?? "";
            });
          },
          value: config.pointType,
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.point_type)),
          validator: _dropdownValidator,
        ),
        const Padding(padding: EdgeInsets.all(15)),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text(AppLocalizations.of(context)!.penalties),
            ),
            Switch(
              value: config.penalties,
              onChanged: (value) {
                setState(() {
                  config.penalties = value;
                });
              },
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.all(15)),
        TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
          ],
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.raw_dp)),
          onChanged: (value) {
            setState(() {
              config.rawDP = int.tryParse(value) ?? 3;
            });
          },
          validator: _numberValidator,
          initialValue: config.rawDP.toString(),
        ),
        const Padding(padding: EdgeInsets.all(15)),
        TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
          ],
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.point_dp)),
          onChanged: (value) {
            setState(() {
              config.pointDP = int.tryParse(value) ?? 3;
            });
          },
          validator: _numberValidator,
          initialValue: config.pointDP.toString(),
        )
      ],
    );
  }
}

class CompetitionConfig {
  String? subject;
  String? unit;
  String? pointType;
  bool penalties = false;
  int rawDP = 3;
  int pointDP = 3;
}
