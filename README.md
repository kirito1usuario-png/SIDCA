# SIDCA

**Sistema de Inteligencia y Defensa Contra Amenazas**

SIDCA es una plataforma central de inteligencia, análisis y defensa contra amenazas digitales. Su objetivo es recolectar señales de múltiples fuentes, normalizarlas, correlacionarlas, estimar riesgo y confianza, mantener conocimiento histórico y exponer una API segura para clientes como AIA Mobile.

## Principios

- SIDCA es independiente de cualquier aplicación cliente.
- Un reporte no equivale a una amenaza confirmada.
- Riesgo y confianza son valores distintos.
- Toda decisión importante debe poder rastrearse hasta evidencia y fuentes.
- Los indicadores mantienen historial; no se sobrescribe el pasado.
- IA complementa señales técnicas, no sustituye evidencia determinista.
- Secretos y credenciales nunca se almacenan en el repositorio.

## Arquitectura objetivo

```text
Fuentes externas ─┐
Reportes usuarios ├─> Ingesta -> Normalización -> Correlación -> Risk Engine
OSINT / feeds ────┘                                      |
                                                        v
                                               Supabase PostgreSQL
                                                        |
                                                        v
Cloudflare Workers <-> SIDCA API <-> clientes (AIA Mobile, consola, futuros productos)
```

## Componentes

- **SIDCA Intelligence**: indicadores, amenazas, observaciones, campañas y relaciones.
- **SIDCA Reports**: reportes de usuarios, evidencia y reputación del reportante.
- **SIDCA Risk Engine**: cálculo de riesgo y confianza con trazabilidad.
- **SIDCA Protection**: reglas y acciones de protección.
- **SIDCA Collectors**: conectores a fuentes externas y feeds.
- **SIDCA API**: acceso seguro para aplicaciones clientes.
- **SIDCA Console**: administración y revisión humana (fase posterior).

## Infraestructura prevista

- **GitHub**: código, documentación, migraciones y CI/CD.
- **Cloudflare Workers**: API pública, validación, rate limiting y lógica de borde.
- **Cloudflare Queues / Cron**: ingesta y procesamiento asíncrono/programado.
- **Cloudflare Hyperdrive**: acceso optimizado desde Workers a PostgreSQL.
- **Supabase PostgreSQL**: base central de inteligencia.
- **Supabase Storage**: evidencia binaria cuando sea necesario.

## Estado

Proyecto en fase de arquitectura inicial. El primer objetivo es estabilizar el modelo de datos central antes de integrar clientes.

Ver:

- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `supabase/migrations/0001_core_schema.sql`
