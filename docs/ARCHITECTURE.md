# Arquitectura de SIDCA

## 1. Objetivo

SIDCA será el sistema central de inteligencia y defensa contra amenazas. Los clientes consumen sus decisiones mediante API; ningún cliente define el modelo central ni accede directamente a la base de datos.

## 2. Flujo principal

```text
[Fuentes]
   |
   v
[Collectors / Reports API]
   |
   v
[Normalización]
   |
   v
[Observaciones y evidencia]
   |
   v
[Correlación]
   |
   +--> [Indicadores]
   +--> [Amenazas]
   +--> [Campañas]
   |
   v
[Risk Engine]
   |
   v
[Protection Engine]
   |
   v
[SIDCA API]
   |
   +--> AIA Mobile
   +--> Console
   +--> futuros clientes
```

## 3. Conceptos del dominio

### Source
Origen de una observación: feed, API, comunidad SIDCA, analista, motor automático u otra fuente.

### Indicator
Observable concreto: URL, dominio, IP, teléfono, email, hash, paquete de app, remitente SMS, wallet, etc.

### Observation
Hecho registrado por una fuente sobre un indicador en un momento concreto. Conserva procedencia y evidencia.

### Threat
Clase o familia de amenaza: phishing, smishing, vishing, malware, troyano, ransomware, spyware, fraude, suplantación, malvertising, robo de credenciales, etc.

### Campaign
Agrupa indicadores, observaciones y amenazas que forman parte de una misma operación o patrón coordinado.

### User Report
Declaración de un usuario. Nace como evidencia no verificada y nunca confirma por sí sola una amenaza.

### Risk Assessment
Resultado versionado del motor: riesgo, confianza, razones, algoritmo/modelo y fecha.

### Protection Rule
Acción defensiva vinculada a tipos de amenaza o condiciones concretas.

## 4. Estados recomendados

### Indicador
- `unknown`
- `benign`
- `suspicious`
- `malicious`
- `inactive`
- `disputed`

### Reporte
- `pending`
- `accepted`
- `rejected`
- `duplicate`
- `needs_review`

### Campaña
- `suspected`
- `active`
- `inactive`
- `archived`

## 5. Riesgo vs confianza

SIDCA nunca debe confundir ambos valores.

- **risk_score (0-100)**: impacto/peligrosidad estimada si la señal es verdadera.
- **confidence_score (0-100)**: fuerza de la evidencia disponible.

Ejemplo: un APK con conducta potencialmente destructiva puede tener riesgo 95 pero confianza 40 mientras falta evidencia.

## 6. Infraestructura

### Cloudflare
Workers será la capa pública. Responsabilidades:
- API HTTPS.
- autenticación/autorización.
- validación.
- rate limiting y anti-abuso.
- integración con Play Integrity para clientes Android cuando corresponda.
- publicación en colas.
- consultas rápidas al motor y a PostgreSQL.

Queues procesará tareas costosas fuera de la petición del usuario. Cron ejecutará recolectores periódicos.

### Supabase
PostgreSQL será la fuente de verdad. Storage se reservará para evidencia binaria. El acceso administrativo directo estará restringido; aplicaciones cliente no reciben credenciales privilegiadas.

### GitHub
Mantendrá código, migraciones, tests, documentación y pipelines. Ningún `.env`, token, contraseña o clave privada se versionará.

## 7. Seguridad y privacidad

- Minimización de datos personales.
- Normalización y hashing cuando el valor original no sea imprescindible.
- Evidencia binaria aislada del dato relacional.
- Auditoría de cambios sensibles.
- Rate limiting por identidad y señal técnica.
- Idempotencia para evitar reportes/ingestas duplicadas.
- Moderación y reputación de reportantes.
- Separación entre evidencia, inferencia y decisión.
- Trazabilidad de cada decisión hacia sus observaciones y fuentes.

## 8. API objetivo inicial

```text
GET  /v1/health
POST /v1/analyze
POST /v1/reports
GET  /v1/indicators/:type/:value/reputation
GET  /v1/threats/:id
GET  /v1/campaigns/:id
```

Los endpoints administrativos y de ingesta de feeds serán privados.

## 9. Regla arquitectónica principal

**SIDCA no debe diseñarse alrededor de AIA Mobile.** AIA Mobile se adaptará a los contratos de SIDCA cuando el núcleo sea estable.
