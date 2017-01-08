from .common import *
from .celery import *

MEDIA_URL = "TAIGA_HOST/media/"
STATIC_URL = "TAIGA_HOST/static/"
ADMIN_MEDIA_PREFIX = "TAIGA_HOST/static/admin/"
SITES["front"]["scheme"] = "TAIGA_SITE_SCHEME"
SITES["front"]["domain"] = "TAIGA_SITE_DOMAIN"

SECRET_KEY = "TAIGA_SECRET_KEY"

DEBUG = False
TEMPLATE_DEBUG = False
PUBLIC_REGISTER_ENABLED = TAIGA_PUBLIC_REGISTER_ENABLED

DEFAULT_FROM_EMAIL = "TAIGA_FROM_EMAIL"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

# Uncomment and populate with proper connection parameters
# for enable email sending.
EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_USE_TLS = TAIGA_SMTP_USE_TLS
EMAIL_HOST = "TAIGA_SMTP_HOSTNAME"
EMAIL_HOST_USER = "TAIGA_SMTP_HOST_USER"
EMAIL_HOST_PASSWORD = "TAIGA_SMTP_HOST_PASSWORD"
EMAIL_PORT = TAIGA_SMTP_PORT

# Uncomment and populate with proper connection parameters
# for enable github login/singin.
GITHUB_API_CLIENT_ID = "TAIGA_GITHUB_API_CLIENT_ID"
GITHUB_API_CLIENT_SECRET = "TAIGA_GITHUB_API_CLIENT_SECRET"

EVENTS_PUSH_BACKEND = "taiga.events.backends.rabbitmq.EventsPushBackend"
EVENTS_PUSH_BACKEND_OPTIONS = {"url": "amqp://taiga:TAIGA_RABBITMQ_PASSWORD@localhost:5672/taiga"}

# To run celery with taiga
BROKER_URL = 'amqp://guest:guest@localhost:5672//'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'
CELERY_ENABLED = True