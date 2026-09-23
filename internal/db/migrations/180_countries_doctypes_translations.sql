-- Migracion 180: Paises y tipos de documento como contenido traducible
--
-- Las tablas countries y document_types tienen nombre en espanol (spanish_name,
-- idioma fuente) y en ingles (name). Se registran como fuentes unificadas
-- (entity_type 'country' / 'document_type', dominio '__GLOBAL__') y se siembra
-- la traduccion inglesa desde la columna 'name'. Idiomas adicionales se pueden
-- traducir desde el modulo de traducciones.
-- Idempotente: ON CONFLICT en ambas inserciones.

-- Fuentes: paises
INSERT INTO content_translation_sources (
  translation_key, node_domain, entity_type, entity_id, field_name,
  source_language, source_text, source_hash, context, is_active, updated_at
)
SELECT 'country:' || iso2 || ':name', '__GLOBAL__', 'country', iso2, 'name',
       'es', spanish_name, md5(spanish_name),
       jsonb_build_object('label', spanish_name), true, NOW()
FROM countries
WHERE is_active = true
ON CONFLICT (translation_key) DO UPDATE SET
  source_text = EXCLUDED.source_text,
  source_hash = EXCLUDED.source_hash;

-- Traducciones EN: paises (la columna 'name' ya es el nombre en ingles)
INSERT INTO content_translations (translation_key, language, value, source_hash, updated_at)
SELECT 'country:' || iso2 || ':name', 'en', name, md5(spanish_name), NOW()
FROM countries
WHERE is_active = true AND COALESCE(name, '') <> ''
ON CONFLICT (translation_key, language) DO UPDATE SET
  value = EXCLUDED.value,
  source_hash = EXCLUDED.source_hash,
  updated_at = NOW();

-- Fuentes: tipos de documento
INSERT INTO content_translation_sources (
  translation_key, node_domain, entity_type, entity_id, field_name,
  source_language, source_text, source_hash, context, is_active, updated_at
)
SELECT 'document_type:' || code || ':name', '__GLOBAL__', 'document_type', code, 'name',
       'es', spanish_name, md5(spanish_name),
       jsonb_build_object('label', spanish_name), true, NOW()
FROM document_types
ON CONFLICT (translation_key) DO UPDATE SET
  source_text = EXCLUDED.source_text,
  source_hash = EXCLUDED.source_hash;

-- Traducciones EN: tipos de documento
INSERT INTO content_translations (translation_key, language, value, source_hash, updated_at)
SELECT 'document_type:' || code || ':name', 'en', name, md5(spanish_name), NOW()
FROM document_types
WHERE COALESCE(name, '') <> ''
ON CONFLICT (translation_key, language) DO UPDATE SET
  value = EXCLUDED.value,
  source_hash = EXCLUDED.source_hash,
  updated_at = NOW();

-- Fuentes: presets de nodo (name + description), dominio global
INSERT INTO content_translation_sources (
  translation_key, node_domain, entity_type, entity_id, field_name,
  source_language, source_text, source_hash, context, is_active, updated_at
)
SELECT 'node_preset:' || id || ':name', '__GLOBAL__', 'node_preset', id, 'name',
       'es', name, md5(name),
       jsonb_build_object('label', name, 'category', category), true, NOW()
FROM node_presets
WHERE is_active = true
ON CONFLICT (translation_key) DO UPDATE SET
  source_text = EXCLUDED.source_text,
  source_hash = EXCLUDED.source_hash;

INSERT INTO content_translation_sources (
  translation_key, node_domain, entity_type, entity_id, field_name,
  source_language, source_text, source_hash, context, is_active, updated_at
)
SELECT 'node_preset:' || id || ':description', '__GLOBAL__', 'node_preset', id, 'description',
       'es', description, md5(description),
       jsonb_build_object('label', name, 'category', category), true, NOW()
FROM node_presets
WHERE is_active = true
ON CONFLICT (translation_key) DO UPDATE SET
  source_text = EXCLUDED.source_text,
  source_hash = EXCLUDED.source_hash;

-- Traducciones EN: presets de nodo (name + description)
INSERT INTO content_translations (translation_key, language, value, source_hash, updated_at)
SELECT s.translation_key, 'en', v.value, s.source_hash, NOW()
FROM content_translation_sources s
JOIN (VALUES
  ('node_preset:adventista:name', 'Seventh-day Adventists'),
  ('node_preset:adventista:description', 'Outposts, self-supporting, Sabbath Lock (Friday-Saturday at sundown). Las Delicias Foundation.'),
  ('node_preset:amish:name', 'Amish / Mennonites'),
  ('node_preset:amish:description', 'Animal traction, no cell phones, Ordnung. Fixed NFC totem at the barter barn.'),
  ('node_preset:hutterita:name', 'Hutterites'),
  ('node_preset:hutterita:description', 'Communal colonies, goods in common, ~100 people/colony. Departmental accounting without personal accounts.'),
  ('node_preset:bruderhof:name', 'Bruderhof'),
  ('node_preset:bruderhof:description', 'Common goods (Acts 2:44), regenerative agriculture + manufacturing. Departmental energy audit.'),
  ('node_preset:cuakero:name', 'Quakers'),
  ('node_preset:cuakero:description', 'Spiritual consensus, simplicity, land as stewardship not property.'),
  ('node_preset:catholic_land:name', 'Catholic Land Movement'),
  ('node_preset:catholic_land:description', 'Catholic family homesteading. Rerum Novarum, Mater et Magistra.'),
  ('node_preset:monasterio:name', 'Monasteries (Trappist/Orthodox)'),
  ('node_preset:monasterio:description', 'Liturgical, organic agriculture, manual work without mechanization. Mount Athos, Trappists.'),
  ('node_preset:twelve_tribes:name', 'Twelve Tribes'),
  ('node_preset:twelve_tribes:description', 'Messianic Rastafari, common goods, Ital diet, organic agriculture.'),
  ('node_preset:baye_fall:name', 'Muridiyya / Baye Fall (Senegal)'),
  ('node_preset:baye_fall:description', 'Work is prayer. Oasis in the Sahel, organic agriculture, solar.'),
  ('node_preset:kibbutz:name', 'Kibbutz Lotan (Eco-Judaism)'),
  ('node_preset:kibbutz:description', 'Desert permaculture, Tikkun Olam, Shabbat as an eco-Jewish concept, eco-kashrut.'),
  ('node_preset:iskcon:name', 'ISKCON / Hare Krishna'),
  ('node_preset:iskcon:description', 'Simple living high thinking, cow protection, dietary filters (no meat, eggs, garlic, onion, coffee, alcohol).'),
  ('node_preset:plum_village:name', 'Plum Village (Buddhists)'),
  ('node_preset:plum_village:description', 'Organic Happy Farms, mindfulness in agriculture, veganism, Engaged Buddhism.'),
  ('node_preset:sikh:name', 'Sikh - Khalsa Garden'),
  ('node_preset:sikh:description', 'Organic langar, seva (selfless service), farming for the community.'),
  ('node_preset:bahai:name', 'Bahai - Adasiyyih'),
  ('node_preset:bahai:description', 'Agriculture as the fundamental base of the community. Abdu l-Baha farm model.'),
  ('node_preset:andino:name', 'Andean - Ayllu/Ayni/Minka'),
  ('node_preset:andino:description', 'Andean reciprocity: ayni (reciprocal work), minka (collective work), chhalaku barter.'),
  ('node_preset:mesoamericano:name', 'Mesoamerican - Milpa/Toltecayotl'),
  ('node_preset:mesoamericano:description', 'Milpa (corn+beans+squash), metepantle, food sovereignty.'),
  ('node_preset:ubuntu:name', 'Ubuntu / Ujamaa (Tanzania)'),
  ('node_preset:ubuntu:description', 'African communalism, equality, villagization. I am because we are.'),
  ('node_preset:findhorn:name', 'Findhorn (Scotland)'),
  ('node_preset:findhorn:description', 'Co-creation with nature intelligences, devas, organic-biodynamic CSA.'),
  ('node_preset:ecosalde_espiritual:name', 'Spiritual Eco-villages'),
  ('node_preset:ecosalde_espiritual:description', 'Yoga, permaculture, ceremonies, retreats. InanItah, PachaMama, WuWei.'),
  ('node_preset:pagano:name', 'Wiccan / Druid / Pagan'),
  ('node_preset:pagano:description', 'Wheel of the Year (8 sabbats), farming by seasonal cycles.'),
  ('node_preset:transition_town:name', 'Transition Towns'),
  ('node_preset:transition_town:description', 'Permaculture, local currency, relocalization, community resilience.'),
  ('node_preset:gen_ecoaldea:name', 'GEN - Secular Eco-village'),
  ('node_preset:gen_ecoaldea:description', 'Sociocracy, cayapas (community work), FRNE, permaculture.'),
  ('node_preset:feria_conuquera:name', 'Feria Conuquera (reference)'),
  ('node_preset:feria_conuquera:description', 'Real existing node. First Saturday of each month. DO NOT modify.'),
  ('node_preset:vacio:name', 'Empty (no preconfigured data)'),
  ('node_preset:vacio:description', 'Install the node without any preconfiguration. Everything is configured manually.'),
  ('node_preset:camphill:name', 'Camphill (Anthroposophical)'),
  ('node_preset:camphill:description', 'Communities where people with disabilities and therapists live together. Biodynamic agriculture, associative economics accounting, work as therapy.'),
  ('node_preset:oasis_sufi:name', 'Sufi Oasis'),
  ('node_preset:oasis_sufi:description', 'Rural Sufi zawiyas, dhikr in the fields, organic agriculture, integrated charity (sadaqah).'),
  ('node_preset:granjas_halal:name', 'Halal Farms'),
  ('node_preset:granjas_halal:description', 'Organic halal agriculture, dhabiha, no alcohol or non-halal meat. Muslim producer community.'),
  ('node_preset:convivencialidad:name', 'Conviviality (Ivan Illich)'),
  ('node_preset:convivencialidad:description', 'Convivial tools, deschooling, anti-consumption, appropriate technology. Communities that reject growth.')
) AS v(translation_key, value) ON v.translation_key = s.translation_key
ON CONFLICT (translation_key, language) DO UPDATE SET
  value = EXCLUDED.value,
  source_hash = EXCLUDED.source_hash,
  updated_at = NOW();
