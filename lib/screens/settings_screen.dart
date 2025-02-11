import 'package:flutter/material.dart';
import 'package:notetaking/core/LocaleManager.dart';
import 'package:notetaking/core/ThemeManager.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final localManager = Provider.of<LocalManager>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Tema değiştirme seçeneği
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(localManager.translate('dark_theme')),
            Switch(
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (value){
                themeManager.toggleTheme();
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Dil değiştirme seçeneği

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(localManager.translate('language')),
            const SizedBox(width: 10),
            DropdownButton<Locale>(
              value: localManager.currentLocale,
              onChanged: (Locale? newLocale){
                if(newLocale != null){
                  localManager.changedLocale(newLocale);
                }
              },
              items: const[
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('tr'),
                  child: Text('Türkçe'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}