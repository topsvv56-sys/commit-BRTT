import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_brt_bub/config/app_colors.dart';
import 'package:flutter_application_brt_bub/localization/app_language.dart';
import 'package:flutter_application_brt_bub/models/ticket_model.dart';
import 'package:flutter_application_brt_bub/services/dynamic_qr_service.dart';

/// Widget ສະແດງ Dynamic QR Code ສຳລັບຕົ໋ວໂດຍສານ (ປ້ອງກັນການແຄບໜ້າຈໍດ້ວຍ Live Token & Animation)
class DynamicTicketQrView extends StatefulWidget {
  final TicketModel ticket;

  const DynamicTicketQrView({super.key, required this.ticket});

  @override
  State<DynamicTicketQrView> createState() => _DynamicTicketQrViewState();
}

class _DynamicTicketQrViewState extends State<DynamicTicketQrView>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _secondsRemaining = DynamicQrService.refreshIntervalSeconds;
  late String _currentDynamicPayload;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _updateDynamicPayload();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Timer ນັບຖອຍຫຼັງທຸກໆ 1 ວິນາທີເພື່ອປ່ຽນ Token ຕາມຮອບ
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final now = DateTime.now();
      final sec = now.second % DynamicQrService.refreshIntervalSeconds;
      final remaining = DynamicQrService.refreshIntervalSeconds - sec;

      setState(() {
        _secondsRemaining = remaining;
        if (remaining == DynamicQrService.refreshIntervalSeconds || remaining == 1) {
          _updateDynamicPayload();
        }
      });
    });
  }

  void _updateDynamicPayload() {
    _currentDynamicPayload = DynamicQrService.generateDynamicPayload(
      ticketId: widget.ticket.id,
      origin: widget.ticket.originStation,
      destination: widget.ticket.destinationStation,
      quantity: widget.ticket.quantity,
      expiresAt: widget.ticket.expiresAt,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUsed = widget.ticket.status == 'used';
    final bool isExpired =
        widget.ticket.status == 'expired' ||
        DateTime.now().isAfter(widget.ticket.expiresAt);

    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLang, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isUsed
                  ? AppColors.textGrey.withValues(alpha: 0.4)
                  : isExpired
                      ? AppColors.errorAccent.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.25),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header: Badge ບອກສະຖານະຂອງຕົ໋ວ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUsed
                          ? AppColors.textGrey
                          : isExpired
                              ? AppColors.errorAccent
                              : AppColors.successBadge,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUsed
                              ? Icons.check_circle_outline
                              : isExpired
                                  ? Icons.error_outline
                                  : Icons.verified,
                          size: 14,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isUsed
                              ? tr('ticket_status_used')
                              : isExpired
                                  ? tr('ticket_status_expired')
                                  : tr('ticket_status_valid'),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isUsed && !isExpired)
                    Row(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tr('live_qr_badge'),
                          style: const TextStyle(
                            color: AppColors.successDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ກ່ອງ QR Code ພ້ອມ Watermark ປ້ອງກັນ Screenshot
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: QrImageView(
                      data: isUsed || isExpired
                          ? 'BRT:INVALID:${widget.ticket.id}'
                          : _currentDynamicPayload,
                      version: QrVersions.auto,
                      size: 210,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: isUsed
                            ? AppColors.textGrey
                            : isExpired
                                ? AppColors.errorAccent
                                : AppColors.primary,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: isUsed
                            ? AppColors.textGrey
                            : isExpired
                                ? AppColors.errorAccent
                                : AppColors.textNavy,
                      ),
                    ),
                  ),
                  if (isUsed || isExpired)
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUsed ? Icons.done_all : Icons.cancel_outlined,
                              size: 54,
                              color: isUsed ? AppColors.textGrey : AppColors.errorAccent,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isUsed ? tr('ticket_already_scanned') : tr('ticket_expired_notice'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUsed ? AppColors.textGrey : AppColors.errorAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // ແຖບນັບຖອຍຫຼັງ Dynamic Token Rotation
              if (!isUsed && !isExpired) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _secondsRemaining / DynamicQrService.refreshIntervalSeconds,
                    backgroundColor: AppColors.scaffoldBg,
                    color: _secondsRemaining < 5
                        ? AppColors.errorAccent
                        : AppColors.primary,
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('dynamic_token_refresh'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${_secondsRemaining}s',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
