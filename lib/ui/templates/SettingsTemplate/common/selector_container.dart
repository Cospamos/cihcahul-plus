import 'package:cihcahul_plus/core/models/selector_entry.dart';
import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:cihcahul_plus/ui/widgets/scroll_bar.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

class SelectorContainer extends StatefulWidget {
  final String name;
  final String selectorId;
  final String? description;
  final List<SelectorEntry> data;
  final SelectorEntry defaultData;
  final String selecotrMessage;

  const SelectorContainer({
    super.key,
    required this.defaultData,
    required this.name,
    required this.selectorId,
    this.description,
    required this.data,
    required this.selecotrMessage,
  });

  @override
  State<SelectorContainer> createState() => _SelectorContainerState();
}

class _SelectorContainerState extends State<SelectorContainer> {
  late final Variable? v;
  late List<SelectorEntry> filtered;
  late Fuzzy<SelectorEntry> fuse;

  @override
  void initState() {
    super.initState();
    v =
        ReactiveStore.get(widget.selectorId) ??
        ReactiveStore.createAndGet(
          name: widget.selectorId,
          value: widget.defaultData,
          toSave: true,
        );
    filtered = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final description = widget.description;
    final name = widget.name;
    late OverlayEntry entry;
    bool isEntry = false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: description != null && description.isNotEmpty ? 20 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: context.theme.textTheme.bodyLarge!.copyWith(
                    color: context.theme.textPrimary,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    softWrap: true,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: context.theme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            filtered = widget.data;
            entry = OverlayEntry(
              builder: (overlayContext) {
                isEntry = true;
                return Positioned.fill(
                  child: Material(
                    color: Colors.black45,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        entry.remove();
                        isEntry = false;
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 100, bottom: 100),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: GestureDetector(
                                onTap: () {
                                  entry.remove();
                                  isEntry = false;
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 15,
                                    bottom: 15,
                                    left: 5,
                                    right: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.theme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 300,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: (isLight)
                                    ? overlayContext.theme.primary
                                    : overlayContext.theme.primaryContainer,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  bottomLeft: Radius.circular(32),
                                ),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.selecotrMessage,
                                    style: Theme.of(overlayContext)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color:
                                              overlayContext.theme.textPrimary,
                                        ),
                                  ),
                                  SizedBox(
                                    height: 35,
                                    child: TextField(
                                      onChanged: (query) {
                                        fuse = Fuzzy<SelectorEntry>(
                                          widget.data,
                                          options: FuzzyOptions(
                                            keys: [
                                              WeightedKey(
                                                name: 'name',
                                                getter: (e) => e.name,
                                                weight: 1.0,
                                              ),
                                              WeightedKey(
                                                name: 'id',
                                                getter: (e) => e.id,
                                                weight: 1.0,
                                              ),
                                            ],
                                            threshold: 0.4,
                                          ),
                                        );
                                        filtered = query.trim().isEmpty
                                            ? widget.data
                                            : fuse
                                                  .search(query)
                                                  .map((r) => r.item)
                                                  .toList();
                                        entry.markNeedsBuild();
                                      },
                                      style: context.theme.textTheme.bodyMedium!
                                          .copyWith(
                                            color: Colors.white,
                                          ),
                                      decoration: InputDecoration(
                                        hintText: 'Introduce textul...',
                                        hintStyle: context
                                            .theme
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: (isLight) ? Colors.white : context.theme.surface,
                                            ),
                                        suffixIcon: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 0,
                                          left: 8,
                                          right: 0,
                                        ),
                                        filled: true,
                                        fillColor: (isLight) ? context.theme.primaryContainer : context.theme.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: ScrollBar(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 25),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ...filtered.map(
                                                (e) => GestureDetector(
                                                  onTap: () {
                                                    v!.set(
                                                      SelectorEntry(
                                                        id: e.id,
                                                        name: e.name,
                                                      ),
                                                    );
                                                    entry.remove();
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border:
                                                          e.id == v!.get().id
                                                          ? Border.all(
                                                              color:
                                                                  overlayContext
                                                                      .theme
                                                                      .surface,
                                                              width: 2,
                                                            )
                                                          : Border(),
                                                    ),
                                                    child: Text(
                                                      e.name,
                                                      style: Theme.of(overlayContext)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            color: overlayContext
                                                                .theme
                                                                .textSecondaryVariant,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
            Overlay.of(context).insert(entry);
          },
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                if (isEntry) {
                  entry.remove();
                  isEntry = false;
                } else {
                  ReactiveStore.get("settings_toggle")?.set(false);
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.theme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.theme.surfaceVariant,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(v?.get().name),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
