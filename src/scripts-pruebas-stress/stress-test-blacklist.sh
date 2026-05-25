#!/bin/bash
# =============================================================================
# stress-test-blacklist.sh
# Pruebas de stress para el microservicio Blacklist - Entrega 4
# Ejecutar desde AWS CloudShell o cualquier terminal Ubuntu/Linux
# =============================================================================

ALB_DNS="alb-proyecto03-1517493111.us-east-1.elb.amazonaws.com"
TOKEN="token-secreto-blacklist-2026"

echo "=============================================="
echo " STRESS TEST - Blacklist Microservice"
echo " Target: http://$ALB_DNS"
echo "=============================================="
echo ""

# ---------------------------------------------------------
# 1. Instalar Apache Bench si no está disponible
# ---------------------------------------------------------
if ! command -v ab &> /dev/null; then
    echo "[SETUP] Instalando Apache Bench..."
    if command -v apt &> /dev/null; then
        sudo apt update -qq && sudo apt install -y apache2-utils
    elif command -v yum &> /dev/null; then
        sudo yum install -y httpd-tools
    else
        echo "[ERROR] No se pudo instalar ab. Instálalo manualmente."
        exit 1
    fi
    echo "[SETUP] Apache Bench instalado correctamente."
    echo ""
fi

# ---------------------------------------------------------
# 2. Verificar que el servicio responde
# ---------------------------------------------------------
echo "[CHECK] Verificando que el servicio responde..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/)
if [ "$HTTP_CODE" != "200" ]; then
    echo "[ERROR] El servicio no responde (HTTP $HTTP_CODE). Abortando."
    exit 1
fi
echo "[CHECK] Servicio OK (HTTP $HTTP_CODE)"
echo ""

# ---------------------------------------------------------
# 3. Crear archivo de datos para POST
# ---------------------------------------------------------
echo '{"email":"stress@test.com","app_uuid":"550e8400-e29b-41d4-a716-446655440000","blocked_reason":"Stress test entrega 4"}' > /tmp/post_data.json

# ---------------------------------------------------------
# 4. ESCENARIO 1: GET / (Health Check)
#    1000 requests, 50 concurrentes
# ---------------------------------------------------------
echo "=============================================="
echo " ESCENARIO 1: GET / (Health Check)"
echo " 1000 requests | 50 concurrentes"
echo "=============================================="
ab -n 1000 -c 50 \
   http://$ALB_DNS/
echo ""

# ---------------------------------------------------------
# 5. ESCENARIO 2: POST /blacklists (Crear entrada)
#    500 requests, 20 concurrentes
# ---------------------------------------------------------
echo "=============================================="
echo " ESCENARIO 2: POST /blacklists"
echo " 500 requests | 20 concurrentes"
echo "=============================================="
ab -n 500 -c 20 \
   -T "application/json" \
   -H "Authorization: Bearer $TOKEN" \
   -p /tmp/post_data.json \
   http://$ALB_DNS/blacklists
echo ""

# ---------------------------------------------------------
# 6. ESCENARIO 3: GET /blacklists/<email> (Consulta)
#    500 requests, 30 concurrentes
# ---------------------------------------------------------
echo "=============================================="
echo " ESCENARIO 3: GET /blacklists/stress@test.com"
echo " 500 requests | 30 concurrentes"
echo "=============================================="
ab -n 500 -c 30 \
   -H "Authorization: Bearer $TOKEN" \
   http://$ALB_DNS/blacklists/stress@test.com
echo ""

# ---------------------------------------------------------
# 7. ESCENARIO 4: Peticiones sin token (generar errores 401)
#    200 requests, 10 concurrentes
# ---------------------------------------------------------
echo "=============================================="
echo " ESCENARIO 4: POST sin token (errores 401)"
echo " 200 requests | 10 concurrentes"
echo "=============================================="
ab -n 200 -c 10 \
   -T "application/json" \
   -p /tmp/post_data.json \
   http://$ALB_DNS/blacklists
echo ""

# ---------------------------------------------------------
# 8. ESCENARIO 5: Endpoint inexistente (errores 404)
#    200 requests, 10 concurrentes
# ---------------------------------------------------------
echo "=============================================="
echo " ESCENARIO 5: GET /noexiste (errores 404)"
echo " 200 requests | 10 concurrentes"
echo "=============================================="
ab -n 200 -c 10 \
   http://$ALB_DNS/noexiste
echo ""

# ---------------------------------------------------------
# 9. ESCENARIO 6: Carga alta simultánea
#    2000 requests, 100 concurrentes
# ---------------------------------------------------------
echo "=============================================="
echo " ESCENARIO 6: GET / (Carga alta)"
echo " 2000 requests | 100 concurrentes"
echo "=============================================="
ab -n 2000 -c 100 \
   http://$ALB_DNS/
echo ""

# ---------------------------------------------------------
# Limpieza
# ---------------------------------------------------------
rm -f /tmp/post_data.json

echo "=============================================="
echo " STRESS TEST COMPLETADO"
echo "=============================================="
echo ""
echo " Espera 3-5 minutos y revisa New Relic:"
echo " -> APM & Services -> blacklist-microservice-proyecto04"
echo ""
echo " Evidencias a capturar en New Relic:"
echo "   1. Summary -> Web transactions time"
echo "   2. Summary -> Apdex score"
echo "   3. Transactions -> Most time consuming"
echo "   4. Databases -> Response time"
echo "   5. Errors -> Error rate"
echo "   6. Alerts -> Configurar alerta"
echo "=============================================="
