#!/bin/bash
# =============================================================================
# generate-errors-blacklist.sh
# Generar errores intencionalmente para monitoreo en New Relic
# Ejecutar desde AWS CloudShell
# =============================================================================

ALB_DNS="alb-proyecto03-1517493111.us-east-1.elb.amazonaws.com"
TOKEN="token-secreto-blacklist-2026"

echo "=============================================="
echo " GENERADOR DE ERRORES - New Relic Errors Inbox"
echo " Target: http://$ALB_DNS"
echo "=============================================="
echo ""

# ---------------------------------------------------------
# 1. Error 401 - Request sin token
# ---------------------------------------------------------
echo "--- Error 401: POST sin token de autorización ---"
curl -s -X POST http://$ALB_DNS/blacklists \
  -H "Content-Type: application/json" \
  -d '{"email":"error@test.com","app_uuid":"test-uuid"}' | python3 -m json.tool
echo ""

# ---------------------------------------------------------
# 2. Error 400 - Request sin campo email
# ---------------------------------------------------------
echo "--- Error 400: POST sin campo email ---"
curl -s -X POST http://$ALB_DNS/blacklists \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"app_uuid":"test-uuid"}' | python3 -m json.tool
echo ""

# ---------------------------------------------------------
# 3. Error 400 - Request sin campo app_uuid
# ---------------------------------------------------------
echo "--- Error 400: POST sin campo app_uuid ---"
curl -s -X POST http://$ALB_DNS/blacklists \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"error@test.com"}' | python3 -m json.tool
echo ""

# ---------------------------------------------------------
# 4. Error 404 - Endpoint inexistente
# ---------------------------------------------------------
echo "--- Error 404: GET a endpoint inexistente ---"
curl -s http://$ALB_DNS/noexiste
echo ""
echo ""

# ---------------------------------------------------------
# 5. Error 405 - Método no permitido
# ---------------------------------------------------------
echo "--- Error 405: POST al health check (método no permitido) ---"
curl -s -X POST http://$ALB_DNS/
echo ""
echo ""

# ---------------------------------------------------------
# 6. Múltiples errores 401 (50 requests sin token)
# ---------------------------------------------------------
echo "--- Generando 50 errores 401 (sin token) ---"
for i in $(seq 1 50); do
  curl -s -X POST http://$ALB_DNS/blacklists \
    -H "Content-Type: application/json" \
    -d '{"email":"error@test.com","app_uuid":"test-uuid"}' > /dev/null
done
echo "50 errores 401 enviados"
echo ""

# ---------------------------------------------------------
# 7. Múltiples errores 400 (50 requests sin email)
# ---------------------------------------------------------
echo "--- Generando 50 errores 400 (sin email) ---"
for i in $(seq 1 50); do
  curl -s -X POST http://$ALB_DNS/blacklists \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"app_uuid":"test-uuid"}' > /dev/null
done
echo "50 errores 400 enviados"
echo ""

# ---------------------------------------------------------
# 8. Múltiples errores 404 (30 requests)
# ---------------------------------------------------------
echo "--- Generando 30 errores 404 ---"
for i in $(seq 1 30); do
  curl -s http://$ALB_DNS/noexiste > /dev/null
done
echo "30 errores 404 enviados"
echo ""

echo "=============================================="
echo " ERRORES GENERADOS EXITOSAMENTE"
echo "=============================================="
echo ""
echo " Espera 3-5 minutos y revisa en New Relic:"
echo "   -> APM -> Errors -> Error rate"
echo "   -> Errors Inbox"
echo "=============================================="
