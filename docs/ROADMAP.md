# Roadmap de SIDCA

## Fase 0 — Fundaciones

Objetivo: fijar arquitectura, convenciones y seguridad antes de integrar fuentes.

- [x] Crear repositorio SIDCA.
- [x] Definir visión y arquitectura inicial.
- [x] Diseñar esquema central v1.
- [ ] Crear proyecto Supabase.
- [ ] Crear proyecto Cloudflare Workers.
- [ ] Configurar secretos fuera de GitHub.
- [ ] Configurar entornos `dev`, `staging` y `prod`.
- [ ] Añadir CI para validar TypeScript, SQL y tests.

## Fase 1 — Núcleo de inteligencia

Objetivo: almacenar inteligencia con trazabilidad.

- [ ] `sources`
- [ ] `threats`
- [ ] `indicators`
- [ ] `observations`
- [ ] relaciones indicador-amenaza
- [ ] `campaigns`
- [ ] relaciones campaña-indicador
- [ ] historial y timestamps confiables
- [ ] índices para búsquedas de reputación

Resultado: SIDCA puede registrar qué se observó, quién lo observó, cuándo y cómo se relaciona.

## Fase 2 — API base

Objetivo: exponer el núcleo sin acceso directo a PostgreSQL.

- [ ] Worker `/v1/health`
- [ ] Worker `/v1/analyze`
- [ ] endpoint de reputación
- [ ] validación de payloads
- [ ] autenticación servicio-a-servicio
- [ ] rate limiting
- [ ] observabilidad y errores estructurados
- [ ] versionado de contratos API

## Fase 3 — Reportes comunitarios

Objetivo: convertir reportes en evidencia útil sin permitir manipulación.

- [ ] `user_reports`
- [ ] evidencia de reporte
- [ ] deduplicación
- [ ] idempotencia
- [ ] reputación del reportante
- [ ] detección de abuso
- [ ] moderación
- [ ] flujo `pending -> accepted/rejected/duplicate/needs_review`
- [ ] privacidad y retención de datos

## Fase 4 — Recolección externa

Objetivo: alimentar SIDCA automáticamente.

- [ ] framework común de collectors
- [ ] registro de ejecuciones
- [ ] health por fuente
- [ ] normalización de indicadores
- [ ] deduplicación
- [ ] Cloudflare Cron
- [ ] Cloudflare Queues
- [ ] políticas de reintento y dead-letter

Empezar con pocas fuentes de alta calidad antes de ampliar cobertura.

## Fase 5 — Risk Engine v1

Objetivo: producir decisiones explicables.

Entradas:
- reputación de fuente
- cantidad de observaciones independientes
- actualidad de observaciones
- confirmaciones externas
- reputación de reportantes
- severidad del tipo de amenaza
- contradicciones y disputas

Salidas:
- `risk_score`
- `confidence_score`
- estado
- razones estructuradas
- versión del algoritmo

## Fase 6 — Protection Engine

Objetivo: traducir inteligencia en acciones defensivas.

- [ ] reglas de advertencia
- [ ] bloqueo cuando la confianza lo permita
- [ ] recomendaciones al usuario
- [ ] expiración de reglas
- [ ] prioridad
- [ ] compatibilidad por cliente/plataforma

## Fase 7 — Campañas y correlación avanzada

- [ ] agrupación por infraestructura
- [ ] objetivos/marcas suplantadas
- [ ] similitud de mensajes
- [ ] ventanas temporales
- [ ] relaciones entre teléfonos, dominios, URLs y hashes
- [ ] creación asistida de campañas
- [ ] revisión humana

## Fase 8 — Consola SIDCA

- [ ] dashboard operativo
- [ ] revisión de reportes
- [ ] investigación de indicadores
- [ ] vista de campañas
- [ ] gestión de fuentes
- [ ] auditoría
- [ ] métricas de falsos positivos

## Fase 9 — Integración AIA Mobile

Solo cuando los contratos de SIDCA sean estables:

- [ ] cliente API en Android
- [ ] análisis URL
- [ ] reputación de teléfonos
- [ ] reportes
- [ ] detección SMS/mensajes
- [ ] cache local
- [ ] Play Integrity
- [ ] experiencia de protección en tiempo real

## Fase 10 — Escalamiento

- [ ] particionado/retención de observaciones si el volumen lo exige
- [ ] cache selectiva
- [ ] Hyperdrive
- [ ] métricas y SLO
- [ ] backups/restauración probados
- [ ] disaster recovery
- [ ] API para futuros productos

## Orden inmediato de trabajo

1. Crear Supabase.
2. Ejecutar `0001_core_schema.sql`.
3. Crear Worker base en Cloudflare.
4. Conectar Worker -> PostgreSQL.
5. Implementar `/v1/health`.
6. Implementar creación/consulta de indicadores y observaciones.
7. Añadir reports solo después de que la ingesta central esté probada.
