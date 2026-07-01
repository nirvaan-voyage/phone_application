import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_bottom_sheet.dart';
import 'travel_details_screen.dart';
import 'placeholder_screen.dart';

// ── Auth-aware navigation helper ───────────────────────────────────────────
Future<void> _navOrLogin(
  BuildContext context,
  WidgetRef ref,
  Widget destination,
) async {
  final isLoggedIn = ref.read(authProvider).isLoggedIn;

  if (!isLoggedIn) {
    final didSignIn = await showAuthSheet(context);
    // If login succeeded, continue to the original destination
    if (didSignIn && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    }
    // If login was dismissed, do nothing — user stays where they are
    return;
  }

  // Already logged in — go straight there
  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }
}

void _goToHomeAfterAuth(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const MainAppScreen()),
    (route) => false,
  );
}

// ── Shared gradient presets ────────────────────────────────────────────────
// Blue palette: lightest #EEF4FB → darkest #0F2744
const List<List<Color>> _tagGradients = [
  [Color(0xFF5B92BE), Color(0xFF1D3F63)],
  [Color(0xFF8FB8D9), Color(0xFF2A5480)],
  [Color(0xFF3D6B9E), Color(0xFF0F2744)],
  [Color(0xFFC5D8EE), Color(0xFF3D6B9E)],
  [Color(0xFF2A5480), Color(0xFF0F2744)],
  [Color(0xFF5B92BE), Color(0xFF2A5480)],
];

class MainAppScreen extends ConsumerStatefulWidget {
  const MainAppScreen({super.key});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late final AnimationController _tabAnim;

  @override
  void initState() {
    super.initState();
    _tabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _tabAnim.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentTab) return;
    _tabAnim.forward(from: 0);
    setState(() => _currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: FadeTransition(
        opacity: CurvedAnimation(
            parent: _tabAnim, curve: Curves.easeOut),
        child: IndexedStack(
          index: _currentTab,
          children: const [
            _HomeTab(),
            _ExploreTab(),
            _ItineraryTab(),
            _GuidesTab(),
            _ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentTab,
        onTap: _onTabTap,
      ),
    );
  }
}

// ── Bottom Navigation ──────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav(
      {required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
    (Icons.map_rounded, Icons.map_outlined, 'Trips'),
    (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Guides'),
    (Icons.person_rounded, Icons.person_outlined, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final (active, inactive, label) = _items[i];
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? active : inactive,
                        size: 22,
                        color: isActive
                            ? Colors.white
                            : AppColors.hint,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOME TAB
// ═══════════════════════════════════════════════════════════════════════════
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero header ─────────────────────────────────────
          _HeroHeader(auth: auth),

          const SizedBox(height: 24),

          // ── Categories ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 14),
            child: Text('Discover',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _CategoryPill(
                    icon: Icons.place_rounded,
                    label: 'Destinations',
                    gradientIndex: 0),
                _CategoryPill(
                    icon: Icons.map_rounded,
                    label: 'Itineraries',
                    gradientIndex: 1),
                _CategoryPill(
                    icon: Icons.menu_book_rounded,
                    label: 'Guides',
                    gradientIndex: 2),
                _CategoryPill(
                    icon: Icons.flight_rounded,
                    label: 'Flights',
                    gradientIndex: 3),
                _CategoryPill(
                    icon: Icons.hotel_rounded,
                    label: 'Hotels',
                    gradientIndex: 4),
                _CategoryPill(
                    icon: Icons.train_rounded,
                    label: 'Trains',
                    gradientIndex: 5),
                _CategoryPill(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Shows',
                    gradientIndex: 0),
                _CategoryPill(
                    icon: Icons.groups_rounded,
                    label: 'Collab',
                    gradientIndex: 1),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.34,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.primary),
                Text(
                  'Swipe',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Plan Journey CTA ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PlanJourneyCTA(),
          ),

          const SizedBox(height: 28),

          // ── Top Destinations ─────────────────────────────────
          _SectionHeader(
              title: 'Top Destinations', onSeeAll: () {}),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _FeaturedCard(
                  name: 'Manali',
                  tag: 'Mountains',
                  imageUrl:
                      'assets/images/manali.jpg',
                  rating: '4.9',
                  gradientIndex: 0,
                ),
                _FeaturedCard(
                  name: 'Udaipur',
                  tag: 'Heritage',
                  imageUrl:
                      'assets/images/udaipur.jpg',
                  rating: '4.8',
                  gradientIndex: 2,
                ),
                _FeaturedCard(
                  name: 'Kerala',
                  tag: 'Backwaters',
                  imageUrl:
                      'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=600',
                  rating: '4.9',
                  gradientIndex: 4,
                ),
                _FeaturedCard(
                  name: 'Ladakh',
                  tag: 'Adventure',
                  imageUrl:
                      'assets/images/ladakh.jpg',
                  rating: '4.7',
                  gradientIndex: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Popular Itineraries ───────────────────────────────
          _SectionHeader(
              title: 'Popular Itineraries', onSeeAll: () {}),
          const SizedBox(height: 14),
          ...const [
            _ItineraryCard(
              title: '7-Day Himalayan Trail',
              subtitle: 'Manali → Spiti → Kaza',
              duration: '7 Days',
              price: '₹18,500',
              tag: 'Adventure',
              gradientIndex: 0,
            ),
            _ItineraryCard(
              title: 'Kerala Backwaters',
              subtitle: 'Kochi → Alleppey → Munnar',
              duration: '5 Days',
              price: '₹12,000',
              tag: 'Relaxation',
              gradientIndex: 4,
            ),
            _ItineraryCard(
              title: 'Rajasthan Royal Tour',
              subtitle: 'Jaipur → Jodhpur → Udaipur',
              duration: '6 Days',
              price: '₹15,200',
              tag: 'Cultural',
              gradientIndex: 1,
            ),
          ],

          const SizedBox(height: 28),

          _SectionHeader(title: 'Guide', onSeeAll: () {}),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SmartGuideMatchCard(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 156,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _MiniGuideCard(name: 'Aarav', city: 'Delhi', specialty: 'Heritage'),
                _MiniGuideCard(name: 'Mira', city: 'Goa', specialty: 'Beaches'),
                _MiniGuideCard(name: 'Kabir', city: 'Jaipur', specialty: 'Culture'),
                _MiniGuideCard(name: 'Tara', city: 'Manali', specialty: 'Adventure'),
                _MiniGuideCard(name: 'Ishan', city: 'Mumbai', specialty: 'Food'),
                _MiniGuideCard(name: 'Naina', city: 'Kochi', specialty: 'Nature'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _SectionHeader(title: 'Shows & Events', onSeeAll: () {}),
          const SizedBox(height: 14),
          SizedBox(
            height: 136,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _EventTypeCard(icon: Icons.mic_rounded, title: 'Stand-up', subtitle: 'Comedy nights'),
                _EventTypeCard(icon: Icons.movie_rounded, title: 'Movies', subtitle: 'Cinema tickets'),
                _EventTypeCard(icon: Icons.music_note_rounded, title: 'Concerts', subtitle: 'Live music'),
                _EventTypeCard(icon: Icons.sports_cricket_rounded, title: 'Sports', subtitle: 'Match tickets'),
                _EventTypeCard(icon: Icons.theater_comedy_rounded, title: 'Theatre', subtitle: 'Stage shows'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _SectionHeader(title: 'Plan Together', onSeeAll: () {}),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CollaborationSection(),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ── Hero Header ─────────────────────────────────────────────────────────────
class _HeroHeader extends ConsumerWidget {
  const _HeroHeader({required this.auth});
  final AuthState auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a3a5c), Color(0xFF3D6B9E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isLoggedIn
                                  ? 'Welcome back,'
                                  : 'Hello, Traveller 👋',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                            Text(
                              auth.isLoggedIn
                                  ? auth.name?.trim().isNotEmpty == true
                                      ? auth.name!
                                      : auth.userEmail?.split('@').first ??
                                          'User'
                                  : 'Where to next?',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (!auth.isLoggedIn) {
                            await showAuthSheet(context);
                          }
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white
                                .withValues(alpha: 0.15),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            auth.isLoggedIn
                                ? Icons.person_rounded
                                : Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Search bar
                  Container(
  height: 52,
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.25),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF3D3B8E).withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.08),
        blurRadius: 6,
        spreadRadius: -2,
        offset: const Offset(-2, -2),
      ),
    ],
  ),
  child: Row(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: 22),
      ),
      Expanded(
        child: Text(
          'Search destinations, guides...',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          'Search',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),
),

                  const SizedBox(height: 16),

                  // Stats row
// Stats row
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: const [
      _StatBadge(
        value: '500+',
        label: 'Destinations',
      ),
      SizedBox(width: 8),
      _StatBadge(
        value: '200+',
        label: 'Itineraries',
      ),
      SizedBox(width: 8),
      _StatBadge(
        value: '4.9★',
        label: 'Rated',
      ),
    ],
  ),
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPLORE TAB
// ═══════════════════════════════════════════════════════════════════════════
class _ExploreTab extends StatefulWidget {
  const _ExploreTab();

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  int _activeFilter = 0;
  final _filters = [
    'All', 'Mountains', 'Beaches', 'Heritage', 'Wildlife', 'Spiritual'
  ];

  static const _places = [
    ('Manali', 'Mountains', '4.9',
        'assets/images/manali.jpg'),
    ('Goa', 'Beaches', '4.7',
        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400'),
    ('Hampi', 'Heritage', '4.8',
        'assets/images/hampi.jpg'),
    ('Ranthambore', 'Wildlife', '4.6',
        'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=400'),
    ('Varanasi', 'Spiritual', '4.9',
        'assets/images/varanasi.jpg'),
    ('Andaman', 'Beaches', '4.8',
        'assets/images/andaman.jpg'),
    ('Spiti', 'Mountains', '4.9',
        'assets/images/spiti.jpg'),
    ('Mysore', 'Heritage', '4.7',
        'assets/images/mysore.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _activeFilter == 0
        ? _places
        : _places
            .where((p) => p.$2 == _filters[_activeFilter])
            .toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text('Explore India',
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text('Discover your next adventure',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textLight)),
          ),

          // Search
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
  height: 48,
  decoration: BoxDecoration(
color: const Color(0xFF3D6B9E).withValues(alpha: 0.07),
borderRadius: BorderRadius.circular(14),
border: Border.all(
  color: const Color(0xFF5B92BE).withValues(alpha: 0.25),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF3D3B8E).withValues(alpha: 0.08),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.7),
        blurRadius: 6,
        spreadRadius: -2,
        offset: const Offset(-2, -2),
      ),
    ],
  ),
  child: Row(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(Icons.search_rounded,
            color: const Color(0xFF2A5480).withValues(alpha: 0.7),
            size: 20),
      ),
      Text(
        'Search destinations, guides...', // change text per tab
        style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF2A5480).withValues(alpha: 0.45)),
      ),
    ],
  ),
),
          ),

          const SizedBox(height: 16),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () =>
                    setState(() => _activeFilter = i),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _activeFilter == i
                        ? const LinearGradient(colors: [
                            AppColors.primaryDark,
                            AppColors.primary
                          ])
                        : null,
                    color: _activeFilter == i
                        ? null
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _activeFilter == i
                            ? AppColors.primary
                                .withValues(alpha: 0.3)
                            : Colors.black
                                .withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _filters[i],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _activeFilter == i
                          ? Colors.white
                          : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grid
          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _ExploreGridCard(
                name: filtered[i].$1,
                tag: filtered[i].$2,
                rating: filtered[i].$3,
                imageUrl: filtered[i].$4,
                gradientIndex: i % _tagGradients.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ITINERARY TAB
// ═══════════════════════════════════════════════════════════════════════════
class _ItineraryTab extends ConsumerWidget {
  const _ItineraryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isLoggedIn;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text('Itineraries',
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text('Curated trips for every traveller',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textLight)),
          ),

          // Create CTA
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () async {
                if (!isLoggedIn) {
                  final ok = await showAuthSheet(context);
                  if (ok && context.mounted) {
                    _goToHomeAfterAuth(context);
                  }
                  return;
                }
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const TravelDetailsScreen()),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1a3a5c),
                      Color(0xFF3D6B9E)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary
                          .withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Transform.rotate(
                        angle: math.pi / 6,
                        child: Icon(
                          Icons.map_rounded,
                          size: 100,
                          color: Colors.white
                              .withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(
                                      14),
                            ),
                            child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Build Your Dream Trip',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Personalised AI itinerary planner',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white60,
                              size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text('Pre-built Itineraries',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              children: const [
                _ItineraryCard(
                  title: '7-Day Himalayan Trail',
                  subtitle: 'Manali → Spiti → Kaza',
                  duration: '7 Days',
                  price: '₹18,500',
                  tag: 'Adventure',
                  gradientIndex: 0,
                ),
                _ItineraryCard(
                  title: 'Kerala Backwaters',
                  subtitle: 'Kochi → Alleppey → Munnar',
                  duration: '5 Days',
                  price: '₹12,000',
                  tag: 'Relaxation',
                  gradientIndex: 4,
                ),
                _ItineraryCard(
                  title: 'Rajasthan Royal Tour',
                  subtitle: 'Jaipur → Jodhpur → Udaipur',
                  duration: '6 Days',
                  price: '₹15,200',
                  tag: 'Cultural',
                  gradientIndex: 1,
                ),
                _ItineraryCard(
                  title: 'Northeast Discovery',
                  subtitle: 'Shillong → Cherrapunji → Dawki',
                  duration: '8 Days',
                  price: '₹22,000',
                  tag: 'Nature',
                  gradientIndex: 2,
                ),
                _ItineraryCard(
                  title: 'Golden Triangle',
                  subtitle: 'Delhi → Agra → Jaipur',
                  duration: '4 Days',
                  price: '₹9,800',
                  tag: 'Heritage',
                  gradientIndex: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GUIDES TAB
// ═══════════════════════════════════════════════════════════════════════════
class _GuidesTab extends ConsumerWidget {
  const _GuidesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text('Travel Blog',
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text('Stories, routes, tips, and city guides',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textLight)),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14),
                    child: Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  Text('Search guides...',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.hint)),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _BlogFilter(label: 'All'),
                _BlogFilter(label: 'Adventure'),
                _BlogFilter(label: 'Budget'),
                _BlogFilter(label: 'Food'),
                _BlogFilter(label: 'Culture'),
                _BlogFilter(label: 'Safety'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _BlogPostCard(
              title: 'How to plan a peaceful 7-day Himachal route',
              category: 'Adventure',
              readTime: '6 min read',
              excerpt:
                  'A practical mountain itinerary with rest days, scenic stops, and safer transfers.',
              gradientIndex: 0,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _BlogPostCard(
              title: 'Kerala beyond the usual backwater trip',
              category: 'Nature',
              readTime: '8 min read',
              excerpt:
                  'Slow travel ideas across Kochi, Alleppey, Munnar, local food, and monsoon timing.',
              gradientIndex: 4,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _BlogPostCard(
              title: 'Rajasthan on a student budget',
              category: 'Budget',
              readTime: '5 min read',
              excerpt:
                  'Where to stay, what to skip, and how to stretch your budget across Jaipur and Udaipur.',
              gradientIndex: 1,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _BlogPostCard(
              title: 'Solo travel safety checklist for India',
              category: 'Safety',
              readTime: '7 min read',
              excerpt:
                  'Simple rules for arrivals, transport, sharing plans, and avoiding stressful surprises.',
              gradientIndex: 3,
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE TAB
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn) {
      return SafeArea(
        child: Column(
          children: [
            // Mini header
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Profile',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
              ),
            ),

            const Spacer(),

            // Greyscale avatar
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade400
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded,
                    size: 60,
                    color: Colors.grey.shade600),
              ),
            ),

            const SizedBox(height: 20),

            Text('Sign in to your account',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(
              'Access bookings, saved trips,\nand personalised recommendations',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textLight,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  // Sign In
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primary
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(16),
                        onTap: () async {
                          final didSignIn = await showAuthSheet(context);
                          if (didSignIn && context.mounted) {
                            _goToHomeAfterAuth(context);
                          }
                        },
                        child: Center(
                          child: Text('Sign In',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Create Account
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary,
                          width: 1.5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(16),
                        onTap: () async {
                          final didSignIn = await showAuthSheet(
                            context,
                            startInCreateAccount: true,
                          );
                          if (didSignIn && context.mounted) {
                            _goToHomeAfterAuth(context);
                          }
                        },
                        child: Center(
                          child: Text('Create Account',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      AppColors.primary)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      );
    }

    // Logged in profile
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header banner
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1a3a5c),
                    Color(0xFF3D6B9E)
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding:
                  const EdgeInsets.fromLTRB(20, 32, 20, 32),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                          .withValues(alpha: 0.2),
                      border: Border.all(
                          color: Colors.white
                              .withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: const Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.name?.trim().isNotEmpty == true
                        ? auth.name!
                        : auth.userEmail?.split('@').first ?? 'Traveller',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  Text(
                    auth.userEmail ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white60),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu items
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Column(
                children: [
_ProfileTile(
    icon: Icons.receipt_long_rounded,
    label: 'My Bookings',
    gradientIndex: 0,
    subtitle: 'View all your trips'),
_ProfileTile(
    icon: Icons.bookmark_rounded,
    label: 'Saved Trips',
    gradientIndex: 1,
    subtitle: 'Places you want to visit'),
_ProfileTile(
    icon: Icons.map_rounded,
    label: 'My Itineraries',
    gradientIndex: 2,
    subtitle: 'Your custom travel plans'),
_ProfileTile(
    icon: Icons.star_rounded,
    label: 'Reviews & Ratings',
    gradientIndex: 3,
    subtitle: 'Trips you have reviewed'),
_ProfileTile(
    icon: Icons.card_travel_rounded,
    label: 'Travel Preferences',
    gradientIndex: 0,
    subtitle: 'Customise your experience'),
_ProfileTile(
    icon: Icons.people_rounded,
    label: 'Travel Companions',
    gradientIndex: 1,
    subtitle: 'Friends and family'),
_ProfileTile(
    icon: Icons.wallet_rounded,
    label: 'Payments & Wallet',
    gradientIndex: 2,
    subtitle: 'Manage payment methods'),
_ProfileTile(
    icon: Icons.notifications_rounded,
    label: 'Notifications',
    gradientIndex: 3,
    subtitle: 'Alerts and updates'),
_ProfileTile(
    icon: Icons.help_outline_rounded,
    label: 'Help & Support',
    gradientIndex: 4,
    subtitle: 'FAQs and contact us'),
_ProfileTile(
    icon: Icons.settings_rounded,
    label: 'Settings',
    gradientIndex: 5,
    subtitle: 'App preferences'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: GestureDetector(
                onTap: () =>
                    ref.read(authProvider.notifier).logout(),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Colors.red.shade400,
                          size: 20),
                      const SizedBox(width: 10),
                      Text('Log Out',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('See all',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends ConsumerWidget {
  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.gradientIndex,
  });
  final IconData icon;
  final String label;
  final int gradientIndex;

  static const _destinations = {
    'Destinations': (Icons.place_rounded, 'Browse Destinations'),
    'Itineraries':  (Icons.map_rounded,   'Itineraries'),
    'Guides':       (Icons.menu_book_rounded, 'Travel Guides'),
    'Flights':      (Icons.flight_rounded,  'Book Flights'),
    'Hotels':       (Icons.hotel_rounded,   'Find Hotels'),
    'Trains':       (Icons.train_rounded,   'Book Trains'),
    'Shows':        (Icons.confirmation_number_rounded, 'Shows & Events'),
    'Collab':       (Icons.groups_rounded, 'Plan Together'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final info = _destinations[label];
        if (info == null) return;
        _navOrLogin(
          context,
          ref,
          PlaceholderScreen(title: info.$2, icon: info.$1),
        );
      },
      child: Container(
        width: 92,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF3D6B9E).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF5B92BE).withValues(alpha: 0.30),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D3F63).withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: -2,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Icon(icon,
                  color: const Color(0xFF2A5480).withValues(alpha: 0.85),
                  size: 26),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark),
                textAlign: TextAlign.center,
                maxLines: 1),
          ],
        ),
      ),
    );
  }
}

class _PlanJourneyCTA extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final isLoggedIn = ref.read(authProvider).isLoggedIn;
        if (!isLoggedIn) {
          final ok = await showAuthSheet(context);
          if (ok && context.mounted) {
            _goToHomeAfterAuth(context);
          }
          return;
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TravelDetailsScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
  BoxShadow(
    color: const Color(0xFF1D3F63)
        .withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Container(
                height: 110,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
  Color(0xFF2A5480),
  Color(0xFF0F2744)
],
                  ),
                ),
              ),
              Positioned(
                right: -20,
                bottom: -20,
                child: Transform.rotate(
                  angle: -math.pi / 8,
                  child: Icon(Icons.flight_rounded,
                      size: 120,
                      color: Colors.white
                          .withValues(alpha: 0.08)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Plan Your Journey',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartGuideMatchCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _navOrLogin(
        context,
        ref,
        const PlaceholderScreen(
          title: 'Smart Guide Match',
          icon: Icons.auto_awesome_rounded,
          subtitle: 'Let Nirvaan choose the best guide for your trip.',
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A5480), Color(0xFF0F2744)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Smart Guide Match',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 3),
                  Text('Let the app choose a guide for your route and style',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white70,
                          height: 1.35)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MiniGuideCard extends ConsumerWidget {
  const _MiniGuideCard({
    required this.name,
    required this.city,
    required this.specialty,
  });

  final String name;
  final String city;
  final String specialty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _navOrLogin(
        context,
        ref,
        PlaceholderScreen(
          title: '$name - Guide',
          icon: Icons.badge_rounded,
          subtitle: '$specialty guide in $city',
        ),
      ),
      child: Container(
        width: 126,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(name,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Text(city,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textLight)),
            const Spacer(),
            Text(specialty,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _EventTypeCard extends ConsumerWidget {
  const _EventTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _navOrLogin(
        context,
        ref,
        PlaceholderScreen(
          title: title,
          icon: icon,
          subtitle: 'Book tickets for $subtitle',
        ),
      ),
      child: Container(
        width: 136,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const Spacer(),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _CollaborationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _CollabChip(icon: Icons.business_center_rounded, label: 'Business trips'),
        _CollabChip(icon: Icons.school_rounded, label: 'School trips'),
        _CollabChip(icon: Icons.groups_rounded, label: 'Friends'),
        _CollabChip(icon: Icons.family_restroom_rounded, label: 'Family'),
        _CollabChip(icon: Icons.celebration_rounded, label: 'Events'),
      ],
    );
  }
}

class _CollabChip extends ConsumerWidget {
  const _CollabChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _navOrLogin(
        context,
        ref,
        PlaceholderScreen(
          title: label,
          icon: icon,
          subtitle: 'Invite people and plan together.',
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(width: 7),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.name,
    required this.tag,
    required this.imageUrl,
    required this.rating,
    required this.gradientIndex,
  });
  final String name;
  final String tag;
  final String imageUrl;
  final String rating;
  final int gradientIndex;

  @override
  Widget build(BuildContext context) {
    final colors = _tagGradients[
        gradientIndex % _tagGradients.length];

    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
imageUrl.startsWith('assets/')
    ? Image.asset(imageUrl, fit: BoxFit.cover)
    : Image.network(imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
          ),
        )),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: colors),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 11, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(rating,
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItineraryCard extends ConsumerWidget {
  const _ItineraryCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.price,
    required this.tag,
    required this.gradientIndex,
  });
  final String title;
  final String subtitle;
  final String duration;
  final String price;
  final String tag;
  final int gradientIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final colors = _tagGradients[
        gradientIndex % _tagGradients.length];
    final isLoggedIn = ref.watch(authProvider).isLoggedIn;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
child: IntrinsicHeight(
        child: Row(
          children: [
            // Color accent strip
            Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          // Icon
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[0].withValues(alpha: 0.15),
                      colors[1].withValues(alpha: 0.15),
                    ]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.route_rounded,
                  color: colors[0], size: 24),
            ),
          ),
          // Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.schedule_rounded,
                        size: 11, color: colors[0]),
                    const SizedBox(width: 3),
                    Text(duration,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: colors[0],
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              colors[0]
                                  .withValues(alpha: 0.15),
                              colors[1]
                                  .withValues(alpha: 0.15),
                            ]),
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(tag,
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colors[0])),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          // Price + Book
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoggedIn) ...[
                  Text(price,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  const SizedBox(height: 6),
                ],
                GestureDetector(
onTap: () => _navOrLogin(
  context,
  ref,
  PlaceholderScreen(
    title: 'Book $title',
    icon: Icons.receipt_long_rounded,
    subtitle: 'Complete your booking for $title',
  ),
),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: colors),
                      borderRadius:
                          BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0]
                              .withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text('Book',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
),
    );
  }
}

class _ExploreGridCard extends StatelessWidget {
  const _ExploreGridCard({
    required this.name,
    required this.tag,
    required this.rating,
    required this.imageUrl,
    required this.gradientIndex,
  });
  final String name;
  final String tag;
  final String rating;
  final String imageUrl;
  final int gradientIndex;

  @override
  Widget build(BuildContext context) {
    final colors = _tagGradients[
        gradientIndex % _tagGradients.length];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
imageUrl.startsWith('assets/')
    ? Image.asset(imageUrl, fit: BoxFit.cover)
    : Image.network(imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors)))),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 10, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(rating,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(tag,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogFilter extends StatelessWidget {
  const _BlogFilter({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isAll = label == 'All';
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isAll ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAll ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAll ? Colors.white : AppColors.textMid,
        ),
      ),
    );
  }
}

class _BlogPostCard extends ConsumerWidget {
  const _BlogPostCard({
    required this.title,
    required this.category,
    required this.readTime,
    required this.excerpt,
    required this.gradientIndex,
  });

  final String title;
  final String category;
  final String readTime;
  final String excerpt;
  final int gradientIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = _tagGradients[gradientIndex % _tagGradients.length];

    return GestureDetector(
      onTap: () => _navOrLogin(
        context,
        ref,
        PlaceholderScreen(
          title: title,
          icon: Icons.article_rounded,
          subtitle: '$readTime - $category',
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              excerpt,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: colors[0]),
                const SizedBox(width: 4),
                Text(
                  readTime,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: colors[0],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Read',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 15, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _GuideCard extends ConsumerWidget {
  const _GuideCard({
    required this.title,
    required this.category,
    required this.readTime,
    required this.gradientIndex,
  });
  final String title;
  final String category;
  final String readTime;
  final int gradientIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final colors = _tagGradients[
        gradientIndex % _tagGradients.length];

    return GestureDetector(
onTap: () => _navOrLogin(
  context,
  ref,
  PlaceholderScreen(
    title: title,
    icon: Icons.article_rounded,
    subtitle: '$readTime • $category',
  ),
),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:
                        colors[0].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                  Icons.article_rounded,
                  color: Colors.white,
                  size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                colors[0].withValues(
                                    alpha: 0.15),
                                colors[1].withValues(
                                    alpha: 0.15),
                              ]),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Text(category,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w600,
                                color: colors[0])),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule_rounded,
                          size: 11,
                          color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Text(readTime,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  AppColors.textLight)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  colors[0].withValues(alpha: 0.12),
                  colors[1].withValues(alpha: 0.12),
                ]),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 16, color: colors[0]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.gradientIndex,
    this.subtitle,
  });
  final IconData icon;
  final String label;
  final int gradientIndex;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final colors = _tagGradients[
        gradientIndex % _tagGradients.length];

    return GestureDetector(
      onTap: () => _navOrLogin(
        context,
        ref,
        PlaceholderScreen(
          title: label,
          icon: icon,
          subtitle: subtitle,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3D6B9E)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF5B92BE)
                      .withValues(alpha: 0.25),
                ),
              ),
              child: Icon(icon,
                  color: const Color(0xFF2A5480)
                      .withValues(alpha: 0.8),
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textLight)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.hint),
          ],
        ),
      ),
    );
  }
}
