mkdir -p /tmp/pi-eval-stub && echo "" > /tmp/pi-eval-stub/httpx.py
PYTHONPATH=/tmp/pi-eval-stub python3 -c 'from app.loader import resolve; print(resolve("order.refunded","acme","production").__name__)' > answer.txt
