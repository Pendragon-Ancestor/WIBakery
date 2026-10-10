import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../orders/providers/order_provider.dart';
import '../../../app/router.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  String _selectedStatus = 'all';

  final List<Map<String, String>> _statusFilters = [
    {'key': 'all', 'label': 'Semua'},
    {'key': 'pending', 'label': 'Menunggu'},
    {'key': 'processing', 'label': 'Diproses'},
    {'key': 'ready', 'label': 'Siap'},
    {'key': 'completed', 'label': 'Selesai'},
    {'key': 'cancelled', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
    });
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedStatus == 'all') return orders;
    return orders.where((o) => o.status.toLowerCase() == _selectedStatus).toList();
  }

  void _showChangeStatusDialog(OrderModel order) {
    final provider = context.read<OrderProvider>();
    String nextStatus = 'processing';
    String statusDesc = 'Pesanan sedang dipanggang / disiapkan';

    if (order.status == 'pending') {
      nextStatus = 'processing';
      statusDesc = 'Pesanan dikonfirmasi & sedang disiapkan oleh bakery';
    } else if (order.status == 'processing') {
      nextStatus = 'ready';
      statusDesc = 'Pesanan telah siap untuk diambil / dikirim';
    } else if (order.status == 'ready') {
      nextStatus = 'completed';
      statusDesc = 'Pesanan telah selesai diserahkan ke pelanggan';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Update Status: ${order.orderNumber}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status saat ini: ${order.statusLabel}'),
            const SizedBox(height: 12),
            const Text(
              'Pilih tindakan:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            if (order.status != 'completed' && order.status != 'cancelled') ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.arrow_forward_ios,
                    size: 18, color: AppColors.primary),
                title: Text(
                  order.status == 'pending'
                      ? 'Proses Pesanan'
                      : order.status == 'processing'
                          ? 'Siap Diambil/Dikirim'
                          : 'Selesaikan Pesanan',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await provider.updateOrderStatus(
                    order.orderId!,
                    nextStatus,
                    statusDesc,
                  );
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status pesanan berhasil diupdate ke ${_getStatusLabel(nextStatus)}'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cancel_outlined,
                    size: 18, color: AppColors.error),
                title: const Text(
                  'Batalkan Pesanan',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  _confirmCancelOrder(order);
                },
              ),
            ] else ...[
              const Text('Pesanan ini sudah selesai atau dibatalkan.'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pembatalan'),
        content: Text('Yakin ingin membatalkan pesanan ${order.orderNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await context.read<OrderProvider>().updateOrderStatus(
                    order.orderId!,
                    'cancelled',
                    'Pesanan dibatalkan oleh pihak admin bakery',
                  );
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesanan telah dibatalkan'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'processing':
        return 'Sedang Diproses';
      case 'ready':
        return 'Siap Diambil/Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'ready':
        return Colors.purple;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status filter horizontal chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final f = _statusFilters[index];
                final isSelected = _selectedStatus == f['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f['label']!),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedStatus = f['key']!);
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    backgroundColor: AppColors.surfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Orders List
        Expanded(
          child: Consumer<OrderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final orders = _filterOrders(provider.allOrders);

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedStatus == 'all'
                            ? 'Belum ada pesanan masuk'
                            : 'Tidak ada pesanan dengan status ini',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.loadAllOrders(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final statusColor = _getStatusColor(order.status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      elevation: 1.5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.orderDetail,
                            arguments: order.orderId,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order number & Status pill
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt_long,
                                          size: 18, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        order.orderNumber,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      order.statusLabel,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Customer name & date
                              Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.userName ?? 'Pelanggan',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.access_time,
                                      size: 14, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.orderDate.length >= 16
                                        ? order.orderDate.substring(0, 16).replaceAll('T', ' ')
                                        : order.orderDate,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(height: 20),

                              // Items preview
                              if (order.items != null && order.items!.isNotEmpty) ...[
                                Text(
                                  order.items!
                                      .map((i) => '${i.quantity}x ${i.productName ?? 'Produk'}')
                                      .join(', '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Total & Actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Pembayaran',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                      Text(
                                        order.formattedTotalPrice,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Action button
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _showChangeStatusDialog(order),
                                    icon: const Icon(Icons.edit_note,
                                        size: 16, color: Colors.white),
                                    label: const Text(
                                      'Kelola Status',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
