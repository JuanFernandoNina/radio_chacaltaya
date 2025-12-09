import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar eventos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 EventsScreen: Iniciando carga de eventos...');
      context.read<EventProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.amber[700],
          onRefresh: () async {
            print('🔄 EventsScreen: Refrescando eventos...');
            await context.read<EventProvider>().refresh();
          },
          child: CustomScrollView(
            slivers: [
              // Header moderno
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 32 : 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 255, 255, 255),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 0, 0)
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: isTablet ? 32 : 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: isTablet ? 28 : 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 22, 22, 22),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy', 'es')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: const Color.fromARGB(255, 68, 68, 68)
                                        .withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Selector de semana
              const SliverToBoxAdapter(
                child: WeekDaySelector(),
              ),

              // Título "Agenda de Hoy"
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 20,
                    isTablet ? 32 : 24,
                    isTablet ? 32 : 20,
                    isTablet ? 16 : 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Agenda de Hoy',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de eventos (CON DEBUGGING)
              Consumer<EventProvider>(
                builder: (context, provider, child) {
                  print('📊 EventsScreen Consumer Build:');
                  print('   - isLoading: ${provider.isLoading}');
                  print('   - Total events: ${provider.events.length}');
                  print('   - Selected date: ${provider.selectedDate}');
                  print(
                      '   - Events for selected date: ${provider.eventsForSelectedDate.length}');
                  print('   - Error: ${provider.error}');

                  final events = provider.eventsForSelectedDate;

                  // Mostrar error si existe
                  if (provider.error != null) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar eventos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => provider.refresh(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                            SizedBox(height: 16),
                            Text('Cargando eventos...'),
                          ],
                        ),
                      ),
                    );
                  }

                  if (events.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event_busy_rounded,
                                size: isTablet ? 80 : 64,
                                color: Colors.amber[300],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No hay eventos',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No hay eventos programados para este día',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(provider.selectedDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Mostrar eventos
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 20,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = events[index];
                          print(
                              '📅 Mostrando evento: ${event.title} - ${event.eventDate}');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: EventCard(event: event, isTablet: isTablet),
                          );
                        },
                        childCount: events.length,
                      ),
                    ),
                  );
                },
              ),

              // Título "Recordatorios"
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 20,
                    isTablet ? 40 : 32,
                    isTablet ? 32 : 20,
                    isTablet ? 16 : 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recordatorios',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de recordatorios (CON DEBUGGING)
              Consumer<EventProvider>(
                builder: (context, provider, child) {
                  print('🔔 Recordatorios: ${provider.reminders.length}');
                  final reminders = provider.reminders;

                  if (reminders.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 20,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications_off_outlined,
                                  color: Colors.grey[400]),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'No hay recordatorios próximos',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 20,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final reminder = reminders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReminderCard(
                                event: reminder, isTablet: isTablet),
                          );
                        },
                        childCount: reminders.length,
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

// Widget: Selector de días
class WeekDaySelector extends StatelessWidget {
  const WeekDaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        final selectedDate = provider.selectedDate;
        final today = DateTime.now();
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

        return Container(
          height: isTablet ? 110 : 100,
          margin: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = startOfWeek.add(Duration(days: index));
              final isSelected = date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;
              final isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;
              final hasEvents = provider.hasEventsOnDate(date);

              return GestureDetector(
                onTap: () {
                  print(
                      '📅 Seleccionado: ${DateFormat('dd/MM/yyyy').format(date)}');
                  provider.selectDate(date);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isTablet ? 70 : 60,
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.amber[600]!, Colors.amber[400]!],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isToday ? Colors.amber[700]! : Colors.grey[200]!,
                      width: isToday ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE', 'es')
                            .format(date)
                            .substring(0, 3)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[600],
                        ),
                      ),
                      if (hasEvents) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.amber[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Widget: Tarjeta de evento
class EventCard extends StatelessWidget {
  final Event event;
  final bool isTablet;

  const EventCard({super.key, required this.event, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber[600]!, Colors.amber[500]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showEventDetails(context, event),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                // Hora
                if (event.startTime != null)
                  Container(
                    width: isTablet ? 70 : 64,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          event.startTime!.split(':')[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 22 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          event.startTime!.split(':')[1],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(width: isTablet ? 16 : 12),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: isTablet ? 15 : 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Avatar o ícono
                Container(
                  width: isTablet ? 56 : 48,
                  height: isTablet ? 56 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: event.imageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            event.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.event,
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.event,
                          color: Colors.white,
                          size: isTablet ? 28 : 24,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EventDetailsSheet(event: event),
    );
  }
}

// Widget: Tarjeta de recordatorio
class ReminderCard extends StatelessWidget {
  final Event event;
  final bool isTablet;

  const ReminderCard({super.key, required this.event, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: Colors.amber[700],
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: isTablet ? 14 : 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM', 'es').format(event.eventDate),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (event.timeRange.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.timeRange,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modal: Detalles del evento
class EventDetailsSheet extends StatelessWidget {
  final Event event;

  const EventDetailsSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),

            // Imagen
            if (event.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  event.imageUrl!,
                  height: isTablet ? 280 : 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: isTablet ? 280 : 200,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),
            ],

            // Título
            Text(
              event.title,
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: isTablet ? 20 : 16),

            // Fecha
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 20, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy', 'es')
                          .format(event.eventDate),
                      style: TextStyle(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hora
            if (event.timeRange.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 20, color: Colors.amber[700]),
                    const SizedBox(width: 12),
                    Text(
                      event.timeRange,
                      style: TextStyle(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Descripción
            if (event.description != null && event.description!.isNotEmpty) ...[
              SizedBox(height: isTablet ? 28 : 20),
              Text(
                'Descripción',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description!,
                style: TextStyle(
                  fontSize: isTablet ? 17 : 16,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
            ],

            SizedBox(height: isTablet ? 32 : 24),

            // Botón cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
