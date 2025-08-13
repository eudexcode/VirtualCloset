-- Agregar columnas faltantes a la tabla user_settings
-- Ejecuta esto en el SQL Editor de Supabase

-- Agregar columna para notificaciones de outfits
ALTER TABLE public.user_settings 
ADD COLUMN IF NOT EXISTS outfit_notifications_enabled BOOLEAN DEFAULT true;

-- Agregar columna para notificaciones de lavado
ALTER TABLE public.user_settings 
ADD COLUMN IF NOT EXISTS laundry_notifications_enabled BOOLEAN DEFAULT true;

-- Verificar que todas las columnas existan
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'user_settings' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Actualizar registros existentes para tener valores por defecto
UPDATE public.user_settings 
SET 
    outfit_notifications_enabled = COALESCE(outfit_notifications_enabled, true),
    laundry_notifications_enabled = COALESCE(laundry_notifications_enabled, true)
WHERE outfit_notifications_enabled IS NULL 
   OR laundry_notifications_enabled IS NULL;
