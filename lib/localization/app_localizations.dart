import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'app_title': 'Closet Virtual',
      'home': 'Inicio',
      'add': 'Agregar',
      'generate': 'Generar',
      'closet': 'Closet',
      'profile': 'Perfil',
      'create': 'Crear',
      'history': 'Historial',
      'laundry': 'Lavar',
      'settings': 'Configuración',
      'logout': 'Cerrar Sesión',
      'notifications': 'Notificaciones',
      'general_notifications': 'Notificaciones generales',
      'outfit_notifications': 'Notificaciones de outfits',
      'laundry_notifications': 'Recordatorios de lavado',
      'appearance': 'Apariencia',
      'theme': 'Tema',
      'language': 'Idioma',
      'data': 'Datos',
      'auto_save': 'Guardado automático',
      'export_data': 'Exportar datos',
      'import_data': 'Importar datos',
      'privacy': 'Privacidad',
      'privacy_policy': 'Política de privacidad',
      'terms_of_service': 'Términos de servicio',
      'about': 'Acerca de',
      'app_version': 'Versión de la app',
      'developer': 'Desarrollador',
      'contact': 'Contacto',
      'reset_settings': 'Restablecer configuración',
      'settings_saved': 'Configuración guardada correctamente',
      'dark_theme_applied': 'Tema oscuro aplicado',
      'light_theme_applied': 'Tema claro aplicado',
      'language_changed': 'Idioma cambiado a',
      'error_saving': 'Error al guardar la configuración',
      'cancel': 'Cancelar',
      'close': 'Cerrar',
      'save': 'Guardar',
      'reset': 'Restablecer',
      'confirm': 'Confirmar',
      'yes': 'Sí',
      'no': 'No',
      'language_changed_to_spanish': 'Idioma cambiado a Español',
      'language_changed_to_english': 'Idioma cambiado a Inglés',
      'language_changed_to_french': 'Idioma cambiado a Francés',
      'export_function_in_development': 'Función en desarrollo',
      'import_function_in_development': 'Función en desarrollo',
      'settings_reset': 'Configuración restablecida',
      'toggle_all_notifications': 'Activar/desactivar todas las notificaciones',
      'alerts_about_outfits_and_suggestions': 'Alertas sobre outfits y sugerencias',
      'reminders_to_wash_dirty_clothes': 'Recordatorios para lavar la ropa sucia',
      'choose_app_theme': 'Elige el tema de la aplicación',
      'select_app_language': 'Selecciona el idioma de la aplicación',
      'automatically_save_your_changes': 'Guarda automáticamente tus cambios',
      'download_a_copy_of_your_data': 'Descarga una copia de tus datos',
      'restore_data_from_a_file': 'Restaura datos desde un archivo',
      'read_our_privacy_policy': 'Lee nuestra política de privacidad',
      'read_our_terms_of_service': 'Lee nuestros términos de servicio',
      'send_us_a_message': 'Envíanos un mensaje',
      'export_data_confirmation_message': '¿Quieres exportar todos tus datos? Esto incluirá tu perfil, prendas y outfits.',
      'import_data_confirmation_message': '¿Quieres importar datos desde un archivo? Esto sobrescribirá tus datos actuales.',
      'export': 'Exportar',
      'import': 'Importar',
      'privacy_policy_content': 'Tu privacidad es importante para nosotros. Esta aplicación recopila solo la información necesaria para funcionar correctamente...',
      'terms_of_service_content': 'Al usar esta aplicación, aceptas nuestros términos de servicio...',
      'developer_message': 'Desarrollado con ❤️ por EudexCode para su amada y talentosa esposa.',
      'email': 'Email',
      'website': 'Sitio web',
      'reset_settings_confirmation_message': '¿Estás seguro de que quieres restablecer toda la configuración a los valores predeterminados?',
      'automatic_theme': 'Automático',
      'light_theme': 'Claro',
      'dark_theme': 'Oscuro',
      'my_profile': 'Mi Perfil',
      'view_profile': 'Ver Perfil',
      'full_name': 'Nombre Completo',
      'phone': 'Teléfono',
      'age': 'Edad',
      'height': 'Altura',
      'weight': 'Peso',
      'please_enter_name': 'Por favor, ingrese su nombre',
      'invalid_age': 'Edad inválida',
      'invalid_height': 'Altura inválida',
      'invalid_weight': 'Peso inválido',
      'profile_updated_successfully': 'Perfil actualizado correctamente',
      'error_saving_profile': 'Error al guardar el perfil',
      'welcome_message': '¡Bienvenido a tu closet virtual!',
      'add_new_category': 'Agregar Nueva Categoría',
      'generate_outfits_message': '¡Aquí puedes generar atuendos con tu ropa!',
      'history_title': 'Historial',
      'laundry_title': 'Lavar',
      'profile_title': 'Perfil',
      'history_screen_title': 'Historial de Outfits',
      'history_screen_empty_title': 'No hay outfits en el historial',
      'history_screen_empty_subtitle': 'Los outfits que uses aparecerán aquí',
      'history_screen_used_items_title': 'Prendas utilizadas:',
      'history_screen_no_items_registered': 'No hay prendas registradas',
      'history_screen_reuse_function_in_development': 'Función en desarrollo',
      'history_screen_reuse_button_label': 'Reutilizar',
      'history_screen_delete_button_label': 'Eliminar',
      'history_screen_delete_dialog_title': 'Eliminar Outfit',
      'history_screen_delete_dialog_content': '¿Estás seguro de que quieres eliminar este outfit del historial?',
      'history_screen_delete_dialog_cancel_button': 'Cancelar',
      'history_screen_delete_dialog_confirm_button': 'Eliminar',
      'history_screen_outfit_deleted': 'Outfit eliminado del historial',
      'history_screen_error_deleting_outfit': 'Error al eliminar el outfit',
      'laundry_screen_title': 'Lavandería',
      'laundry_screen_dirty_clothes_count': 'prendas sucias',
      'laundry_screen_wash_selected': 'Lavar Seleccionadas',
      'laundry_screen_wash_all': 'Lavar Todas',
      'laundry_screen_item_washed': 'Prenda lavada correctamente',
      'laundry_screen_error_washing_item': 'Error al lavar la prenda',
      'laundry_screen_select_at_least_one': 'Selecciona al menos una prenda',
      'laundry_screen_error_washing_selected': 'Error al lavar las prendas',
      'laundry_screen_error_washing_all': 'Error al lavar todas las prendas',
      'laundry_screen_wash_individual_tooltip': 'Lavar individualmente',
      'add_new_clothing': 'Subir Nueva Prenda',
      'select_image_first': 'Selecciona una imagen primero',
      'then_add_clothing_info': 'Después podrás agregar la información de la prenda',
      'create_clothing_description': 'Crea nuevos tipos, subtipos, estilos o colores para organizar mejor tu ropa',
      'what_do_you_want_to_add': '¿Qué quieres agregar?',
      'type': 'Tipo',
      'subtype': 'Subtipo',
      'style': 'Estilo',
      'color': 'Color',
      'select_image': 'Seleccionar Imagen',
      'tap_buttons_below': 'Toca los botones de abajo para seleccionar una imagen',
      'camera': 'Cámara',
      'gallery': 'Galería',
      'remove_background': 'Remover Fondo',
      'processing': 'Procesando...',
      'garment_information': 'Información de la Prenda',
      'garment_name': 'Nombre de la prenda',
      'save_garment': 'Guardar Prenda',
      'add_photo': 'Agregar Foto',
      'change': 'Cambiar',
      'parent_type': 'Tipo Padre:',
      'select_parent_type': 'Selecciona el tipo padre',
      // 'please_enter_name': 'Por favor ingresa un nombre',
      'please_select_parent_type': 'Por favor selecciona un tipo padre',
      'add_type': 'Agregar Tipo',
      'existing_types': 'Tipos existentes',
      'existing_subtypes': 'Subtipos existentes',
      'existing_styles': 'Estilos existentes',
      'existing_colors': 'Colores existentes',
      'colors': 'Colores',
      'please_select_image': 'Por favor selecciona una imagen',
      'garment_added_successfully': 'Prenda agregada correctamente',
      'error_saving_garment': 'Error al guardar la prenda',
      'category_added_successfully': 'agregado correctamente',
      'error_adding_category': 'Error al agregar',
      'invalid_category': 'Categoría no válida',
      'parent_type_not_found': 'No se encontró el tipo padre seleccionado',
      'today': 'Hoy',
      'yesterday': 'Ayer',
      'days_ago': 'Hace',
      'days': 'días',
      'outfit_without_name': 'Outfit sin nombre',
      'no_name': 'Sin nombre',
      'no_dirty_clothes': '¡No hay prendas sucias!',
      'all_clothes_clean': 'Todas tus prendas están limpias',
    },
    'en': {
      'app_title': 'Virtual Closet',
      'home': 'Home',
      'add': 'Add',
      'generate': 'Generate',
      'closet': 'Closet',
      'profile': 'Profile',
      'create': 'Create',
      'history': 'History',
      'laundry': 'Laundry',
      'settings': 'Settings',
      'logout': 'Log Out',
      'notifications': 'Notifications',
      'general_notifications': 'General notifications',
      'outfit_notifications': 'Outfit notifications',
      'laundry_notifications': 'Laundry reminders',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'language': 'Language',
      'data': 'Data',
      'auto_save': 'Auto save',
      'export_data': 'Export data',
      'import_data': 'Import data',
      'privacy': 'Privacy',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'about': 'About',
      'app_version': 'App Version',
      'developer': 'Developer',
      'contact': 'Contact',
      'reset_settings': 'Reset Settings',
      'settings_saved': 'Settings saved successfully',
      'dark_theme_applied': 'Dark theme applied',
      'light_theme_applied': 'Light theme applied',
      'language_changed': 'Language changed to',
      'error_saving': 'Error saving settings',
      'cancel': 'Cancel',
      'close': 'Close',
      'save': 'Save',
      'reset': 'Reset',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'language_changed_to_spanish': 'Language changed to Spanish',
      'language_changed_to_english': 'Language changed to English',
      'language_changed_to_french': 'Language changed to French',
      'export_function_in_development': 'Function in development',
      'import_function_in_development': 'Function in development',
      'settings_reset': 'Settings reset',
      'toggle_all_notifications': 'Enable/disable all notifications',
      'alerts_about_outfits_and_suggestions': 'Alerts about outfits and suggestions',
      'reminders_to_wash_dirty_clothes': 'Reminders to wash dirty clothes',
      'choose_app_theme': 'Choose the app theme',
      'select_app_language': 'Select the app language',
      'automatically_save_your_changes': 'Automatically save your changes',
      'download_a_copy_of_your_data': 'Download a copy of your data',
      'restore_data_from_a_file': 'Restore data from a file',
      'read_our_privacy_policy': 'Read our privacy policy',
      'read_our_terms_of_service': 'Read our terms of service',
      'send_us_a_message': 'Send us a message',
      'export_data_confirmation_message': 'Do you want to export all your data? This will include your profile, clothes and outfits.',
      'import_data_confirmation_message': 'Do you want to import data from a file? This will overwrite your current data.',
      'export': 'Export',
      'import': 'Import',
      'privacy_policy_content': 'Your privacy is important to us. This app collects only the information necessary to function properly...',
      'terms_of_service_content': 'By using this app, you accept our terms of service...',
      'developer_message': 'Developed with ❤️ by EudexCode for his beloved and talented wife.',
      'email': 'Email',
      'website': 'Website',
      'reset_settings_confirmation_message': 'Are you sure you want to reset all settings to default values?',
      'automatic_theme': 'Automatic',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'my_profile': 'My Profile',
      'view_profile': 'View Profile',
      'full_name': 'Full Name',
      'phone': 'Phone',
      'age': 'Age',
      'height': 'Height',
      'weight': 'Weight',
      'please_enter_name': 'Please enter your name',
      'invalid_age': 'Invalid age',
      'invalid_height': 'Invalid height',
      'invalid_weight': 'Invalid weight',
      'profile_updated_successfully': 'Profile updated successfully',
      'error_saving_profile': 'Error saving profile',
      'welcome_message': 'Welcome to your virtual closet!',
      'add_new_category': 'Add New Category',
      'generate_outfits_message': 'Here you can generate outfits with your clothes!',
      'history_title': 'History',
      'laundry_title': 'Laundry',
      'profile_title': 'Profile',
      'history_screen_title': 'Outfit History',
      'history_screen_empty_title': 'No outfits in history',
      'history_screen_empty_subtitle': 'Your outfits will appear here',
      'history_screen_used_items_title': 'Used Items:',
      'history_screen_no_items_registered': 'No items registered',
      'history_screen_reuse_function_in_development': 'Function in development',
      'history_screen_reuse_button_label': 'Reuse',
      'history_screen_delete_button_label': 'Delete',
      'history_screen_delete_dialog_title': 'Delete Outfit',
      'history_screen_delete_dialog_content': 'Are you sure you want to delete this outfit from history?',
      'history_screen_delete_dialog_cancel_button': 'Cancel',
      'history_screen_delete_dialog_confirm_button': 'Delete',
      'history_screen_outfit_deleted': 'Outfit deleted from history',
      'history_screen_error_deleting_outfit': 'Error deleting outfit',
      'laundry_screen_title': 'Laundry',
      'laundry_screen_dirty_clothes_count': 'dirty clothes',
      'laundry_screen_wash_selected': 'Wash Selected',
      'laundry_screen_wash_all': 'Wash All',
      'laundry_screen_item_washed': 'Item washed successfully',
      'laundry_screen_error_washing_item': 'Error washing item',
      'laundry_screen_select_at_least_one': 'Select at least one item',
      'laundry_screen_error_washing_selected': 'Error washing selected items',
      'laundry_screen_error_washing_all': 'Error washing all items',
      'laundry_screen_wash_individual_tooltip': 'Wash individually',
      'add_new_clothing': 'Upload New Item',
      'select_image_first': 'Select an image first',
      'then_add_clothing_info': 'Then you can add the item information',
      'create_clothing_description': 'Create new types, subtypes, styles or colors to better organize your clothes',
      'what_do_you_want_to_add': 'What do you want to add?',
      'type': 'Type',
      'subtype': 'Subtype',
      'style': 'Style',
      'color': 'Color',
      'select_image': 'Select Image',
      'tap_buttons_below': 'Tap the buttons below to select an image',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'remove_background': 'Remove Background',
      'processing': 'Processing...',
      'garment_information': 'Garment Information',
      'garment_name': 'Garment Name',
      'save_garment': 'Save Garment',
      'add_photo': 'Add Photo',
      'change': 'Change',
      'parent_type': 'Parent Type:',
      'select_parent_type': 'Select parent type',
      // 'please_enter_name': 'Please enter a name',
      'please_select_parent_type': 'Please select a parent type',
      'add_type': 'Add Type',
      'existing_types': 'Existing Types',
      'existing_subtypes': 'Existing Subtypes',
      'existing_styles': 'Existing Styles',
      'existing_colors': 'Existing Colors',
      'colors': 'Colors',
      'please_select_image': 'Please select an image',
      'garment_added_successfully': 'Garment added successfully',
      'error_saving_garment': 'Error saving garment',
      'category_added_successfully': 'added successfully',
      'error_adding_category': 'Error adding',
      'invalid_category': 'Invalid category',
      'parent_type_not_found': 'Parent type not found',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      'days': 'days',
      'outfit_without_name': 'Outfit without name',
      'no_name': 'No name',
      'no_dirty_clothes': 'No dirty clothes!',
      'all_clothes_clean': 'All your clothes are clean',
    },
    'fr': {
      'app_title': 'Garde-Robe Virtuel',
      'home': 'Accueil',
      'add': 'Ajouter',
      'generate': 'Générer',
      'closet': 'Garde-Robe',
      'profile': 'Profil',
      'create': 'Créer',
      'history': 'Historique',
      'laundry': 'Lavage',
      'settings': 'Paramètres',
      'logout': 'Déconnexion',
      'notifications': 'Notifications',
      'general_notifications': 'Notifications générales',
      'outfit_notifications': 'Notifications d\'ensembles',
      'laundry_notifications': 'Rappels de lavage',
      'appearance': 'Apparence',
      'theme': 'Thème',
      'language': 'Langue',
      'data': 'Données',
      'auto_save': 'Sauvegarde automatique',
      'export_data': 'Exporter les données',
      'import_data': 'Importer les données',
      'privacy': 'Confidentialité',
      'privacy_policy': 'Politique de confidentialité',
      'terms_of_service': 'Conditions d\'utilisation',
      'about': 'À propos',
      'app_version': 'Version de l\'app',
      'developer': 'Développeur',
      'contact': 'Contact',
      'reset_settings': 'Réinitialiser les paramètres',
      'settings_saved': 'Paramètres sauvegardés avec succès',
      'dark_theme_applied': 'Thème sombre appliqué',
      'light_theme_applied': 'Thème clair appliqué',
      'language_changed': 'Langue changée en',
      'error_saving': 'Erreur lors de la sauvegarde des paramètres',
      'cancel': 'Annuler',
      'close': 'Fermer',
      'save': 'Sauvegarder',
      'reset': 'Réinitialiser',
      'confirm': 'Confirmer',
      'yes': 'Oui',
      'no': 'Non',
      'language_changed_to_spanish': 'Langue changée en Espagnol',
      'language_changed_to_english': 'Langue changée en Anglais',
      'language_changed_to_french': 'Langue changée en Français',
      'export_function_in_development': 'Fonction en développement',
      'import_function_in_development': 'Fonction en développement',
      'settings_reset': 'Paramètres réinitialisés',
      'toggle_all_notifications': 'Activer/désactiver toutes les notifications',
      'alerts_about_outfits_and_suggestions': 'Alertes sur les ensembles et suggestions',
      'reminders_to_wash_dirty_clothes': 'Rappels pour laver les vêtements sales',
      'choose_app_theme': 'Choisir le thème de l\'application',
      'select_app_language': 'Sélectionner la langue de l\'application',
      'automatically_save_your_changes': 'Sauvegarder automatiquement vos modifications',
      'download_a_copy_of_your_data': 'Télécharger une copie de vos données',
      'restore_data_from_a_file': 'Restaurer les données depuis un fichier',
      'read_our_privacy_policy': 'Lire notre politique de confidentialité',
      'read_our_terms_of_service': 'Lire nos conditions d\'utilisation',
      'send_us_a_message': 'Envoyez-nous un message',
      'export_data_confirmation_message': 'Voulez-vous exporter toutes vos données ? Cela inclura votre profil, vos vêtements et vos ensembles.',
      'import_data_confirmation_message': 'Voulez-vous importer des données depuis un fichier ? Cela remplacera vos données actuelles.',
      'export': 'Exporter',
      'import': 'Importer',
      'privacy_policy_content': 'Votre confidentialité est importante pour nous. Cette application ne collecte que les informations nécessaires pour fonctionner correctement...',
      'terms_of_service_content': 'En utilisant cette application, vous acceptez nos conditions d\'utilisation...',
      'developer_message': 'Développé avec ❤️ par EudexCode pour sa femme bien-aimée et talentueuse.',
      'email': 'Email',
      'website': 'Site web',
      'reset_settings_confirmation_message': 'Êtes-vous sûr de vouloir réinitialiser tous les paramètres aux valeurs par défaut ?',
      'automatic_theme': 'Automatique',
      'light_theme': 'Clair',
      'dark_theme': 'Sombre',
      'my_profile': 'Mon Profil',
      'view_profile': 'Voir le Profil',
      'full_name': 'Nom Complet',
      'phone': 'Téléphone',
      'age': 'Âge',
      'height': 'Taille',
      'weight': 'Poids',
      'please_enter_name': 'Veuillez entrer votre nom',
      'invalid_age': 'Âge invalide',
      'invalid_height': 'Taille invalide',
      'invalid_weight': 'Poids invalide',
      'profile_updated_successfully': 'Profil mis à jour avec succès',
      'error_saving_profile': 'Erreur lors de la sauvegarde du profil',
      'welcome_message': 'Bienvenue dans votre garde-robe virtuelle !',
      'add_new_category': 'Ajouter une nouvelle catégorie',
      'generate_outfits_message': 'Ici, vous pouvez générer des tenues avec vos vêtements !',
      'history_title': 'Historique',
      'laundry_title': 'Lavage',
      'profile_title': 'Profil',
      'history_screen_title': 'Historique des tenues',
      'history_screen_empty_title': 'Aucune tenue dans l\'historique',
      'history_screen_empty_subtitle': 'Vos tenues apparaîtront ici',
      'history_screen_used_items_title': 'Articles utilisés :',
      'history_screen_no_items_registered': 'Aucun article enregistré',
      'history_screen_reuse_function_in_development': 'Fonction en développement',
      'history_screen_reuse_button_label': 'Réutiliser',
      'history_screen_delete_button_label': 'Supprimer',
      'history_screen_delete_dialog_title': 'Supprimer la tenue',
      'history_screen_delete_dialog_content': 'Êtes-vous sûr de vouloir supprimer cette tenue de l\'historique ?',
      'history_screen_delete_dialog_cancel_button': 'Annuler',
      'history_screen_delete_dialog_confirm_button': 'Supprimer',
      'history_screen_outfit_deleted': 'Tenue supprimée de l\'historique',
      'history_screen_error_deleting_outfit': 'Erreur lors de la suppression de la tenue',
      'laundry_screen_title': 'Lavage',
      'laundry_screen_dirty_clothes_count': 'vêtements sales',
      'laundry_screen_wash_selected': 'Laver la sélection',
      'laundry_screen_wash_all': 'Tout laver',
      'laundry_screen_item_washed': 'Article lavé avec succès',
      'laundry_screen_error_washing_item': 'Erreur lors du lavage de l\'article',
      'laundry_screen_select_at_least_one': 'Sélectionnez au moins un article',
      'laundry_screen_error_washing_selected': 'Erreur lors du lavage des articles sélectionnés',
      'laundry_screen_error_washing_all': 'Erreur lors du lavage de tous les articles',
      'laundry_screen_wash_individual_tooltip': 'Laver individuellement',
      'add_new_clothing': 'Télécharger un nouvel article',
      'select_image_first': 'Sélectionnez une image d\'abord',
      'then_add_clothing_info': 'Ensuite, vous pouvez ajouter les informations sur l\'article',
      'create_clothing_description': 'Créez de nouveaux types, sous-types, styles ou couleurs pour mieux organiser vos vêtements',
      'what_do_you_want_to_add': 'Que voulez-vous ajouter ?',
      'type': 'Type',
      'subtype': 'Sous-type',
      'style': 'Style',
      'color': 'Couleur',
      'select_image': 'Sélectionner une image',
      'tap_buttons_below': 'Appuyez sur les boutons ci-dessous pour sélectionner une image',
      'camera': 'Caméra',
      'gallery': 'Galerie',
      'remove_background': 'Supprimer le fond',
      'processing': 'En traitement...',
      'garment_information': 'Information sur la pièce',
      'garment_name': 'Nom de la pièce',
      'save_garment': 'Enregistrer la pièce',
      'add_photo': 'Ajouter une photo',
      'change': 'Changer',
      'parent_type': 'Type parent:',
      'select_parent_type': 'Sélectionner le type parent',
      // 'please_enter_name': 'Veuillez entrer un nom',
      'please_select_parent_type': 'Veuillez sélectionner un type parent',
      'add_type': 'Ajouter un type',
      'existing_types': 'Types existants',
      'existing_subtypes': 'Sous-types existants',
      'existing_styles': 'Styles existants',
      'existing_colors': 'Couleurs existantes',
      'colors': 'Couleurs',
      'please_select_image': 'Veuillez sélectionner une image',
      'garment_added_successfully': 'Pièce ajoutée avec succès',
      'error_saving_garment': 'Erreur lors de l\'enregistrement de la pièce',
      'category_added_successfully': 'ajouté avec succès',
      'error_adding_category': 'Erreur d\'ajout',
      'invalid_category': 'Catégorie invalide',
      'parent_type_not_found': 'Type parent non trouvé',
      'today': 'Aujourd\'hui',
      'yesterday': 'Hier',
      'days_ago': 'il y a',
      'days': 'jours',
      'outfit_without_name': 'Ensemble sans nom',
      'no_name': 'Sans nom',
      'no_dirty_clothes': 'Aucun vêtement sale !',
      'all_clothes_clean': 'Tous vos vêtements sont propres',
    },
  };

  String get(String key) {
    final languageCode = locale.languageCode;
    return _localizedValues[languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  String get appTitle => get('app_title');
  String get home => get('home');
  String get add => get('add');
  String get generate => get('generate');
  String get closet => get('closet');
  String get profile => get('profile');
  String get create => get('create');
  String get history => get('history');
  String get laundry => get('laundry');
  String get settings => get('settings');
  String get logout => get('logout');
  String get notifications => get('notifications');
  String get generalNotifications => get('general_notifications');
  String get outfitNotifications => get('outfit_notifications');
  String get laundryNotifications => get('laundry_notifications');
  String get appearance => get('appearance');
  String get theme => get('theme');
  String get language => get('language');
  String get data => get('data');
  String get autoSave => get('auto_save');
  String get exportData => get('export_data');
  String get importData => get('import_data');
  String get privacy => get('privacy');
  String get privacyPolicy => get('privacy_policy');
  String get termsOfService => get('terms_of_service');
  String get about => get('about');
  String get appVersion => get('app_version');
  String get developer => get('developer');
  String get contact => get('contact');
  String get resetSettings => get('reset_settings');
  String get settingsSaved => get('settings_saved');
  String get darkThemeApplied => get('dark_theme_applied');
  String get lightThemeApplied => get('light_theme_applied');
  String get languageChanged => get('language_changed');
  String get errorSaving => get('error_saving');
  String get cancel => get('cancel');
  String get close => get('close');
  String get save => get('save');
  String get reset => get('reset');
  String get confirm => get('confirm');
  String get yes => get('yes');
  String get no => get('no');
  
  // Getters adicionales para settings_screen.dart
  String get languageChangedToSpanish => get('language_changed_to_spanish');
  String get languageChangedToEnglish => get('language_changed_to_english');
  String get languageChangedToFrench => get('language_changed_to_french');
  String get exportFunctionInDevelopment => get('export_function_in_development');
  String get importFunctionInDevelopment => get('import_function_in_development');
  String get settingsReset => get('settings_reset');
  String get toggleAllNotifications => get('toggle_all_notifications');
  String get alertsAboutOutfitsAndSuggestions => get('alerts_about_outfits_and_suggestions');
  String get remindersToWashDirtyClothes => get('reminders_to_wash_dirty_clothes');
  String get chooseAppTheme => get('choose_app_theme');
  String get selectAppLanguage => get('select_app_language');
  String get automaticallySaveYourChanges => get('automatically_save_your_changes');
  String get downloadACopyOfYourData => get('download_a_copy_of_your_data');
  String get restoreDataFromAFile => get('restore_data_from_a_file');
  String get readOurPrivacyPolicy => get('read_our_privacy_policy');
  String get readOurTermsOfService => get('read_our_terms_of_service');
  String get sendUsAMessage => get('send_us_a_message');
  String get exportDataConfirmationMessage => get('export_data_confirmation_message');
  String get importDataConfirmationMessage => get('import_data_confirmation_message');
  String get export => get('export');
  String get import => get('import');
  String get privacyPolicyContent => get('privacy_policy_content');
  String get termsOfServiceContent => get('terms_of_service_content');
  String get developerMessage => get('developer_message');
  String get email => get('email');
  String get website => get('website');
  String get resetSettingsConfirmationMessage => get('reset_settings_confirmation_message');
  
  // Getters para nombres de temas
  String get automaticTheme => get('automatic_theme');
  String get lightTheme => get('light_theme');
  String get darkTheme => get('dark_theme');
  
  // Getters para home screen
  String get myProfile => get('my_profile');
  String get viewProfile => get('view_profile');
  
  // Getters para profile screen
  String get fullName => get('full_name');
  String get phone => get('phone');
  String get age => get('age');
  String get height => get('height');
  String get weight => get('weight');
  String get pleaseEnterName => get('please_enter_name');
  String get invalidAge => get('invalid_age');
  String get invalidHeight => get('invalid_height');
  String get invalidWeight => get('invalid_weight');
  String get profileUpdatedSuccessfully => get('profile_updated_successfully');
  String get errorSavingProfile => get('error_saving_profile');
  String get welcomeMessage => get('welcome_message');
  String get addNewCategory => get('add_new_category');
  String get generateOutfitsMessage => get('generate_outfits_message');
  String get historyTitle => get('history_title');
  String get laundryTitle => get('laundry_title');
  String get profileTitle => get('profile_title');
  String get historyScreenTitle => get('history_screen_title');
  String get historyScreenEmptyTitle => get('history_screen_empty_title');
  String get historyScreenEmptySubtitle => get('history_screen_empty_subtitle');
  String get historyScreenUsedItemsTitle => get('history_screen_used_items_title');
  String get historyScreenNoItemsRegistered => get('history_screen_no_items_registered');
  String get historyScreenReuseFunctionInDevelopment => get('history_screen_reuse_function_in_development');
  String get historyScreenReuseButtonLabel => get('history_screen_reuse_button_label');
  String get historyScreenDeleteButtonLabel => get('history_screen_delete_button_label');
  String get historyScreenDeleteDialogTitle => get('history_screen_delete_dialog_title');
  String get historyScreenDeleteDialogContent => get('history_screen_delete_dialog_content');
  String get historyScreenDeleteDialogCancelButton => get('history_screen_delete_dialog_cancel_button');
  String get historyScreenDeleteDialogConfirmButton => get('history_screen_delete_dialog_confirm_button');
  String get historyScreenOutfitDeleted => get('history_screen_outfit_deleted');
  String get historyScreenErrorDeletingOutfit => get('history_screen_error_deleting_outfit');
  String get laundryScreenTitle => get('laundry_screen_title');
  String get laundryScreenDirtyClothesCount => get('laundry_screen_dirty_clothes_count');
  String get laundryScreenWashSelected => get('laundry_screen_wash_selected');
  String get laundryScreenWashAll => get('laundry_screen_wash_all');
  String get laundryScreenItemWashed => get('laundry_screen_item_washed');
  String get laundryScreenErrorWashingItem => get('laundry_screen_error_washing_item');
  String get laundryScreenSelectAtLeastOne => get('laundry_screen_select_at_least_one');
  String get laundryScreenErrorWashingSelected => get('laundry_screen_error_washing_selected');
  String get laundryScreenErrorWashingAll => get('laundry_screen_error_washing_all');
  String get laundryScreenWashIndividualTooltip => get('laundry_screen_wash_individual_tooltip');
  String get addNewClothing => get('add_new_clothing');
  String get selectImageFirst => get('select_image_first');
  String get thenAddClothingInfo => get('then_add_clothing_info');
  String get createClothingDescription => get('create_clothing_description');
  String get whatDoYouWantToAdd => get('what_do_you_want_to_add');
  String get type => get('type');
  String get subtype => get('subtype');
  String get style => get('style');
  String get color => get('color');
  String get selectImage => get('select_image');
  String get tapButtonsBelow => get('tap_buttons_below');
  String get camera => get('camera');
  String get gallery => get('gallery');
  String get removeBackground => get('remove_background');
  String get processing => get('processing');
  String get garmentInformation => get('garment_information');
  String get garmentName => get('garment_name');
  String get saveGarment => get('save_garment');
  String get addPhoto => get('add_photo');
  String get change => get('change');
  String get parentType => get('parent_type');
  String get selectParentType => get('select_parent_type');
  // String get pleaseEnterName => get('please_enter_name');
  String get pleaseSelectParentType => get('please_select_parent_type');
  String get addType => get('add_type');
  String get existingTypes => get('existing_types');
  String get existingSubtypes => get('existing_subtypes');
  String get existingStyles => get('existing_styles');
  String get existingColors => get('existing_colors');
  String get colors => get('colors');
  String get pleaseSelectImage => get('please_select_image');
  String get garmentAddedSuccessfully => get('garment_added_successfully');
  String get errorSavingGarment => get('error_saving_garment');
  String get categoryAddedSuccessfully => get('category_added_successfully');
  String get errorAddingCategory => get('error_adding_category');
  String get invalidCategory => get('invalid_category');
  String get parentTypeNotFound => get('parent_type_not_found');
  String get today => get('today');
  String get yesterday => get('yesterday');
  String get daysAgo => get('days_ago');
  String get days => get('days');
  String get outfitWithoutName => get('outfit_without_name');
  String get noName => get('no_name');
  String get noDirtyClothes => get('no_dirty_clothes');
  String get allClothesClean => get('all_clothes_clean');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
