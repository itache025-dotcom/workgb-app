import 'package:flutter/material.dart';
import '../temas/cores_novo.dart';

class BottomNavNovo extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isProfessional;
  final int unreadMessages;
  final int newLeads;

  const BottomNavNovo({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isProfessional = false,
    this.unreadMessages = 0,
    this.newLeads = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (isProfessional) {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: CoresNovo.blueContainer,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: CoresNovo.navyPrimary),
            label: 'Início',
          ),
          NavigationDestination(
            icon: _buildBadgeIcon(Icons.chat_bubble_outline, unreadMessages, CoresNovo.navyPrimary, Colors.white),
            selectedIcon: _buildBadgeIcon(Icons.chat_bubble, unreadMessages, CoresNovo.navyPrimary, Colors.white),
            label: 'Mensagens',
          ),
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: CoresNovo.navyPrimary),
            label: 'Meu Negócio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: CoresNovo.navyPrimary),
            label: 'Perfil',
          ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      elevation: 8,
      indicatorColor: CoresNovo.blueContainer,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: CoresNovo.navyPrimary),
          label: 'Feed',
        ),
        const NavigationDestination(
          icon: Icon(Icons.search),
          selectedIcon: Icon(Icons.search, color: CoresNovo.navyPrimary),
          label: 'Pesquisar',
        ),
        NavigationDestination(
          icon: _buildBadgeIcon(Icons.chat_bubble_outline, unreadMessages, CoresNovo.navyPrimary, Colors.white),
          selectedIcon: _buildBadgeIcon(Icons.chat_bubble, unreadMessages, CoresNovo.navyPrimary, Colors.white),
          label: 'Conversas',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: CoresNovo.navyPrimary),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildBadgeIcon(IconData icon, int count, Color badgeColor, Color textColor) {
    if (count == 0) return Icon(icon);
    
    return Badge(
      label: Text(
        count > 9 ? '9+' : '$count',
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      backgroundColor: badgeColor,
      child: Icon(icon),
    );
  }
}
