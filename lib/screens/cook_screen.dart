import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../widgets/game_sheet.dart';

// ============================================================
// Furnace / Cooking production sheet  (screen 04)
// ============================================================

class CookScreen extends StatefulWidget {
  const CookScreen({super.key});

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> {
  // Demo data – wire to a real provider in production.
  final List<_QueueEntry> _queue = [
    _QueueEntry(
      name: 'Roast Meat',
      subtitle: 'Cooking now',
      progress: 0.72,
      timeLabel: '0:18',
    ),
    _QueueEntry(
      name: 'Roast Meat ×2',
      subtitle: 'Queued',
      progress: 0.0,
      timeLabel: '0:40',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GameSheet(
      height: 368,
      header: SheetHeader(
        iconGradient: const [Color(0xFFFF8C42), Color(0xFFE85F22)],
        iconWidget:
            const Icon(Icons.local_fire_department, color: Colors.white, size: 24),
        title: 'Furnace',
        subtitle: 'Cooking 3 of 6 · +12 gold each',
        badge: const SheetBadge(
          label: 'Lv 3',
          color: Color(0xFFFFE0D2),
          textColor: Color(0xFFC24A1E),
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._queue.map((e) => _QueueRow(entry: e)),
          _EmptySlotRow(rawMeatCount: 50),
          const SizedBox(height: 14),
          CtaButton(
            gradient: const [Color(0xFFFF8C42), Color(0xFFF0682A)],
            shadowColor: const Color(0xFFC24E1B),
            icon: Icons.local_fire_department,
            label: 'Cook all · 4 raw → 4 roast',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Sales / Trading Post sheet  (screen 05)
// ============================================================

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const customers = [
      _CustomerEntry(
        name: 'Hungry Trapper',
        wants: 'wants 3 × Roast Meat',
        totalCoins: 48,
        eachLabel: '16 each',
        avatarGradient: [Color(0xFF5DA0E8), AppColors.blueD],
        locked: false,
      ),
      _CustomerEntry(
        name: 'Caravan Cook',
        wants: 'wants 5 × Raw Meat',
        totalCoins: 30,
        eachLabel: '6 each',
        avatarGradient: [Color(0xFFF2796F), Color(0xFFD6453F)],
        locked: false,
      ),
      _CustomerEntry(
        name: 'Frost Merchant',
        wants: 'wants 2 × Gold Ingot',
        totalCoins: 0,
        eachLabel: 'needs Lv 9',
        avatarGradient: [Color(0xFFA9B6C4), Color(0xFF76869A)],
        locked: true,
      ),
    ];

    return GameSheet(
      height: 436,
      header: SheetHeader(
        iconGradient: const [Color(0xFF52C06E), Color(0xFF358A4C)],
        iconWidget: const Icon(Icons.store, color: Colors.white, size: 22),
        title: 'Trading Post',
        subtitle: '3 customers waiting',
        badge: const SheetBadge(
          label: 'Open',
          color: Color(0xFFDCEBFA),
          textColor: AppColors.blueD,
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...customers.map((c) => _CustomerRow(entry: c)),
          const SizedBox(height: 4),
          const _Receipt(totalCoins: 78),
          const SizedBox(height: 12),
          CtaButton(
            gradient: const [Color(0xFF52C06E), AppColors.cashD],
            shadowColor: const Color(0xFF2C7A43),
            icon: Icons.handshake_outlined,
            label: 'Serve customers · +78',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Cook queue rows
// ============================================================

class _QueueEntry {
  final String name;
  final String subtitle;
  final double progress;
  final String timeLabel;
  const _QueueEntry({
    required this.name,
    required this.subtitle,
    required this.progress,
    required this.timeLabel,
  });
}

class _QueueRow extends StatelessWidget {
  final _QueueEntry entry;
  const _QueueRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.snow2, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE08A33), Color(0xFFB5641F)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x24000000), offset: Offset(0, -2), blurRadius: 0),
              ],
            ),
            child:
                const Icon(Icons.lunch_dining, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppTextStyles.hudValue
                      .copyWith(fontSize: 14.5, color: AppColors.ink),
                ),
                Text(
                  entry.subtitle,
                  style: AppTextStyles.micro
                      .copyWith(fontSize: 11, color: AppColors.ink3),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.snow3,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: FractionallySizedBox(
                    widthFactor: entry.progress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.flame, AppColors.fire],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Text(
            entry.timeLabel,
            style: AppTextStyles.hudValueSm.copyWith(color: AppColors.ink2),
          ),
        ],
      ),
    );
  }
}

class _EmptySlotRow extends StatelessWidget {
  final int rawMeatCount;
  const _EmptySlotRow({super.key, required this.rawMeatCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFA9B6C4), Color(0xFF76869A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empty slot',
                  style: AppTextStyles.hudValue
                      .copyWith(fontSize: 14.5, color: AppColors.ink3),
                ),
                Text(
                  'Add raw meat · you have $rawMeatCount',
                  style: AppTextStyles.micro
                      .copyWith(fontSize: 11, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          Text(
            '＋',
            style: AppTextStyles.titleMd.copyWith(color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Sales customer rows
// ============================================================

class _CustomerEntry {
  final String name;
  final String wants;
  final int totalCoins;
  final String eachLabel;
  final List<Color> avatarGradient;
  final bool locked;
  const _CustomerEntry({
    required this.name,
    required this.wants,
    required this.totalCoins,
    required this.eachLabel,
    required this.avatarGradient,
    required this.locked,
  });
}

class _CustomerRow extends StatelessWidget {
  final _CustomerEntry entry;
  const _CustomerRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: entry.locked ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.wRadiusLg),
          boxShadow: AppShadows.sh1,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: entry.avatarGradient,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x24000000),
                      offset: Offset(0, -2),
                      blurRadius: 0),
                ],
              ),
              child:
                  const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: AppTextStyles.hudValue
                        .copyWith(fontSize: 14.5, color: AppColors.ink),
                  ),
                  Text(
                    entry.wants,
                    style: AppTextStyles.micro
                        .copyWith(fontSize: 11, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.locked)
                  Text('locked',
                      style: AppTextStyles.hudValueSm
                          .copyWith(color: AppColors.ink3))
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Color(0xFFFFE873), AppColors.goldD],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.totalCoins}',
                        style: AppTextStyles.hudValue
                            .copyWith(fontSize: 16, color: AppColors.cashD),
                      ),
                    ],
                  ),
                Text(
                  entry.eachLabel,
                  style: AppTextStyles.micro
                      .copyWith(fontSize: 10.5, color: AppColors.ink3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  final int totalCoins;
  const _Receipt({super.key, required this.totalCoins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF6EE), Color(0xFFDCEFE2)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.wRadiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sell to all available',
            style: AppTextStyles.hudValue
                .copyWith(fontSize: 15, color: AppColors.ink),
          ),
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    colors: [Color(0xFFFFE873), AppColors.goldD],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$totalCoins',
                style: AppTextStyles.statXl.copyWith(color: AppColors.cashD),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
